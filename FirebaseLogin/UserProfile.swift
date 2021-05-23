//
// Created by Роман Поспелов on 03.04.2021.
//

import Foundation
import CryptoKit
import Firebase
import AuthenticationServices
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit


class UserProfile: ObservableObject {

    @Published private(set) var signedIn: Bool = false
    @Published private(set) var sentLinkTo: String?

    var userDisplayName: String? {
        auth.currentUser?.displayName
    }

    var userEmail: String? {
        auth.currentUser?.email
    }

    private var auth: Auth
    private var handler: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    private var googleDelegate: GoogleDelegate?

    enum SignInError: Error {
        case invalidState(String)
        case noToken(String)
    }

    class GoogleDelegate: NSObject, GIDSignInDelegate {

        var completion: ((Error?) -> Void)?

        override init() {
            super.init()

            // Initialize sing in with Google
            GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
            GIDSignIn.sharedInstance().delegate = self
        }

        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            guard error == nil else {
                if (error as NSError).code != GIDSignInErrorCode.canceled.rawValue {
                    completion?(error)
                }
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            Auth.auth().signIn(with: credential) { (result, error) in
                self.completion?(error)
            }
        }
    }

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        auth = Auth.auth()

        // Set login and logout handler for refreshes user data
        handler = auth.addStateDidChangeListener { (_, user) in
            self.refresh(user: user)
        }
    }

    // Refreshes user data after login or logout
    private func refresh(user: User?) {
        signedIn = user != nil
        sentLinkTo = nil
    }

    // Make a random nonce string for different a authorization requests
    // (from https://firebase.google.com/docs/auth/ios/apple)
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    // Hashing function using CryptoKit
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }


    // User logout
    func signOut(completion: @escaping (Error?) -> Void) {
        var signOutError: Error?
        do {
            try auth.signOut()
        } catch {
            signOutError = error
        }
        completion(signOutError)
    }


    // User login with email and password
    func signIn(withEmail: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: withEmail, password: password) { (_, error) in
            completion(error)
        }
    }


    // Passwordless login: sending email link
    func sendSignInLink(withEmail: String, completion: @escaping (Error?) -> Void) {

        // Create object which is used to set and retrieve settings related to handling the authentication process
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://romanpospelov.page.link/demo_login")  // Dynamic link which configured in the Firebase Console
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)

        auth.sendSignInLink(toEmail: withEmail, actionCodeSettings: actionCodeSettings) { error in
            if error == nil {
                print("Send link to email: \(withEmail)")
                self.sentLinkTo = withEmail
            }
            completion(error)
        }
    }

    // Passwordless login: sign in with email link
    func signIn(url: URL, completion: @escaping (Error?) -> Void) {
        print("handle url")
        if let email = sentLinkTo {
            print("email: \(email)")
            let link = url.absoluteString
            print("link: \(link)")
            if auth.isSignIn(withEmailLink: link) {
                auth.signIn(withEmail: email, link: link) { (_, error) in
                    completion(error)
                }
            }
        }
    }


    // Login with AppleID: prepare a request for Apple ID authorization
    func prepareAppleIDAuthorizationRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    // Login with AppleID: complete of an authorization attempt
    func signIn(with appleIDCredential: ASAuthorizationAppleIDCredential, completion: @escaping (Error?) -> Void) {
        guard let nonce = currentNonce else {
            completion(SignInError.invalidState("Invalid state: A login callback was received, but no login request was sent."))
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            completion(SignInError.invalidState("Invalid state: A login callback was received, but no login request was sent."))
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(SignInError.noToken("Unable to serialize token string from data: \(appleIDToken.debugDescription)"))
            return
        }

        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        auth.signIn(with: credential) { (_, error) in
            completion(error)
        }
    }


    // Login with Google
    func signInWithGoogle(completion: @escaping (Error?) -> Void) {
        if googleDelegate == nil {
            googleDelegate = GoogleDelegate()
        }
        googleDelegate!.completion = completion
        GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
        GIDSignIn.sharedInstance()?.signIn()
    }


    // Login with Facebook
    func signInWithFB(completion: @escaping (Error?) -> Void) {

        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: nil) { (result, error) in
            if result?.isCancelled ?? false {
                return
            }

            guard error == nil else {
                completion(error)
                return
            }

            guard let accessToken = AccessToken.current else {
                completion(SignInError.noToken("Failed to get token: \(AccessToken.debugDescription())"))
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            self.auth.signIn(with: credential) { (_, error) in
                completion(error)
            }
        }
    }
}


// Support a description for UserProfile.SignInError
extension UserProfile.SignInError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidState(let description), .noToken(let description):
            return NSLocalizedString(description, comment: "Error")
        }
    }
}
