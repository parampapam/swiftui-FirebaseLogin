//
// Created by Роман Поспелов on 03.04.2021.
//

import Foundation
import CryptoKit
import Firebase
import AuthenticationServices

class UserProfile: ObservableObject {

    @Published private(set) var signedIn: Bool = false
    @Published private(set) var sentLinkTo: String?

    var userDisplayName: String? {
        auth.currentUser?.displayName ?? auth.currentUser?.email
    }

    private var auth: Auth
    private var handler: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    init() {
        FirebaseApp.configure()
        auth = Auth.auth()

        // Set login and logout handler for refreshes user data
        handler = auth.addStateDidChangeListener { (_, user) in  self.refresh(user: user) }
    }

    // Refreshes user data after login or logout
    private func refresh(user: User?) {
        signedIn = user != nil
        sentLinkTo = nil
    }

    // from https://firebase.google.com/docs/auth/ios/apple
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
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
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    // User logout
    func signOut() {
        do {
            try auth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    // User login with email and password
    func signIn(withEmail: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: withEmail, password: password) { ( _, error) in
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

    //
    func prepareAppleIDAuthorizationRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    //
    func completeAppleIDAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }

                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                        idToken: idTokenString, rawNonce: nonce)
                Auth.auth().signIn(with: credential) { (_, error) in
                    if error != nil {
                        // Error. If error.code == .MissingOrInvalidNonce, make sure
                        // you're sending the SHA256-hashed nonce as a hex string with
                        // your request to Apple.
                        print(error?.localizedDescription as Any)
                        return
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
}
