//
//  ContentView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//

import SwiftUI
import Firebase

struct LoginWithEmailAndPasswordView: View {
    @EnvironmentObject private var userProfile: UserProfile

    @State private var email = ""
    @State private var password = ""
    @Binding var alertItem: AlertItem?

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding(6)
                .border(Color.gray.opacity(0.2))

            SecureField("Password", text: $password)
                .padding(6)
                .border(Color.gray.opacity(0.2))
                .padding(.bottom)

            Button(action: { login() }) {
                Text("Sign in")
            }
        }
        .padding()
    }

    func login() {
        userProfile.signIn(withEmail: email, password: password) { error in
            if let error = error {
                alertItem = AlertItem(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

struct LoginWithEmailAndPasswordView_Previews: PreviewProvider {

    static var previews: some View {
        LoginWithEmailAndPasswordView(alertItem: Binding.constant(AlertItem(title: "", message: "")))
    }
}
