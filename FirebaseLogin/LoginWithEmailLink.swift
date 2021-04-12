//
//  LoginWithEmailLink.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 07.04.2021.
//

import SwiftUI

struct LoginWithEmailLink: View {
    @EnvironmentObject private var userProfile: UserProfile
    
    @State private var email: String = ""
    @Binding var alertItem: AlertItem?
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding(6)
                .border(Color.gray.opacity(0.2))
            
            Button(action: { sendEmailLink() } ) {
                Text("Send Link")
            }
            .padding(.top)
        }
        .padding()
    }
    
    func sendEmailLink() {
        userProfile.sendSignInLink(withEmail: email) { (error) in
            if let error = error {
                alertItem = AlertItem(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

struct LoginWithEmailLink_Previews: PreviewProvider {
    static var previews: some View {
        LoginWithEmailLink(alertItem: Binding.constant(AlertItem(title: "", message: "")))
    }
}
