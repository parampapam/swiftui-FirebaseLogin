//
// Created by Роман Поспелов on 03.04.2021.
//

import Foundation
import Firebase

class UserProfile: ObservableObject {
    
    @Published private(set) var signedIn: Bool = false
       
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
        if user != nil {
            signedIn = true
        } else {
            signedIn = false
        }
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
}
