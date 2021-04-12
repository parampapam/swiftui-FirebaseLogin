//
// Created by Роман Поспелов on 03.04.2021.
//

import Foundation
import Firebase

class UserProfile: ObservableObject {
    
    @Published private(set) var signedIn: Bool = false
    @Published private(set) var sendedLinkTo: String?

       
    var userDisplayName: String? {
        auth.currentUser?.displayName ?? auth.currentUser?.email
    }
    
    private var auth: Auth
    private var handler: AuthStateDidChangeListenerHandle?

    
    
    init() {
        FirebaseApp.configure()
        auth = Auth.auth()
        
        // Set login and logout handler for refreshes user data
        handler = auth.addStateDidChangeListener { (auth, user) in  self.refresh(user: user) }
    }
    
    // Refreshes user data after login or logout
    private func refresh(user: User?) {
        signedIn = user != nil
        sendedLinkTo = nil
    }
    
    // User logout
    func signOut() {
        do {
            try auth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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
        
        // Create object which is used to set and retieve settings related to handling the authentication process
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://romanpospelov.page.link/demo_login")  // Dynamic link which configurred in the Firebase Console
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        auth.sendSignInLink(toEmail: withEmail, actionCodeSettings: actionCodeSettings) { error in
            if error == nil {
                print("Send link to email: \(withEmail)")
                self.sendedLinkTo = withEmail
            }
            completion(error)
        }
    }
    
    func signIn(url: URL, completion: @escaping (Error?) -> Void) {
        print("handle url")
        if let email = sendedLinkTo {
            print("email: \(email)")
            let link = url.absoluteString
            print("link: \(link)")
            if auth.isSignIn(withEmailLink: link) {
                auth.signIn(withEmail: email, link: link) { (result, error) in
                    completion(error)
                }
            }
        }
    }
}
