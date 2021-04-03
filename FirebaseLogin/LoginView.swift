//
//  ContentView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var signedIn = false
    
    var body: some View {
        VStack {
            if !signedIn {
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                Button(action: { login() }) {
                    Text("Sign in")
                }
            } else {
                Text("You are Signed In")
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("Close")))
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                showAlert = true
                alertMessage = error?.localizedDescription ?? ""
            } else {
                signedIn = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
