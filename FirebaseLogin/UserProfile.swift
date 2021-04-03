//
// Created by Роман Поспелов on 03.04.2021.
//

import Foundation
import Firebase

class UserProfile: ObservableObject {
    
    @Published private(set) var signedIn: Bool = false
       
    var userDisplayName: String? {
        Auth.auth().currentUser?.email
    }
    
    private var auth: Auth
    private var handler: AuthStateDidChangeListenerHandle?
    
    func refresh(user: User?) {
        if user != nil {
            signedIn = true
        } else {
            signedIn = false
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    init() {
        FirebaseApp.configure()
        
        auth = Auth.auth()
        handler = auth.addStateDidChangeListener { (auth, user) in  self.refresh(user: user) }
    }
    
    
    
//    func stateChangeHandler(auth: Auth, user User?) {
//
//    }
}
