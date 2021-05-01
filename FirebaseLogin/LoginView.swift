//
//  MainView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {

    @EnvironmentObject private var userProfile: UserProfile
    @State private var alertItem: AlertItem?
    @State private var showLoginWithEmailAndPassword = false
    @State private var showLoginByEmailLink = false
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        if userProfile.signedIn {
            UserView()
        } else {
            VStack {
                Text("Firebase Login\nSample")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 44)

                Spacer()

                Text("Sign in")
                        .font(.title3.weight(.semibold))
                        .padding(.bottom, 18)

                Button(action: { showLoginWithEmailAndPassword = true }) {
                    Text("With Email & Password")
                }
                        .buttonStyle(LoginKindButtonStyle(backgroundColor: .orange, foregroundColor: .white))
                        .sheet(isPresented: $showLoginWithEmailAndPassword) {
                            CredentialPageView(title: "Login to Firebird\nwith Email and Password", showing: $showLoginWithEmailAndPassword) {
                                CustomTextField(label: "Email", placeholder: "Mandatory", value: $email)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .padding(.bottom, 18)

                                CustomTextField(label: "Password", placeholder: "Mandatory", value: $password, options: [.secure, .unsecureButton])
                                        .padding(.bottom, 44)

                                Button(action: {
                                    userProfile.signIn(withEmail: email, password: password) { error in
                                        if let error = error {
                                            alertItem = AlertItem(title: "Login with Password Error", message: error.localizedDescription)
                                        }
                                    }
                                }) {
                                    Text("Login")
                                }
                                        .buttonStyle(CredentialButtonStyle())

                            }
                        }

                Button(action: { showLoginByEmailLink = true }) {
                    Text("By Email Link")
                }
                        .buttonStyle(LoginKindButtonStyle(backgroundColor: .green, foregroundColor: .white))
                        .sheet(isPresented: $showLoginByEmailLink) {
                            CredentialPageView(title: "Login to Firebase\nby Email Link", showing: $showLoginByEmailLink) {
                                CustomTextField(label: "Email", placeholder: "Mandatory", value: $email)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .padding(.bottom, 44)

                                Button(action: {
                                    userProfile.sendSignInLink(withEmail: email) { (error) in
                                        if let error = error {
                                            alertItem = AlertItem(title: "Login by Link Error", message: error.localizedDescription)
                                        }
                                    }
                                }) {
                                    Text("Send Link")
                                }
                                        .buttonStyle(CredentialButtonStyle())
                            }
                        }

                SignInWithAppleButton(.continue,
                        onRequest: { request in
                            userProfile.prepareAppleIDAuthorizationRequest(request)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    userProfile.signIn(with: appleIDCredential) { error in
                                        if let error = error {
                                            alertItem = AlertItem(title: "Login with Apple Error", message: error.localizedDescription)
                                        }
                                    }
                                default:
                                    alertItem = AlertItem(title: "Login with Apple Error", message: "Oops! Something went wrong.")
                                }
                            case .failure(let error):
                                alertItem = AlertItem(title: "Login with Apple Error", message: error.localizedDescription)
                            }
                        }
                )
                        .frame(height: 44)

                Spacer()
            }
                    .padding(8)
                    .onOpenURL { url in
                        userProfile.signIn(url: url) { error in
                            if let error = error {
                                alertItem = AlertItem(title: "Error", message: error.localizedDescription)
                            }
                        }
                    }
                    .alert(item: $alertItem) {
                        Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("Close")))
                    }
        }
    }
}

class MainView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
                .environmentObject(UserProfile())
    }

    #if DEBUG
    @objc class func injected() {
        UIApplication.shared.windows.first?.rootViewController =
                UIHostingController(rootView: LoginView().environmentObject(UserProfile()))
    }
    #endif
}
