//
//  MainView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit


struct LoginView: View {

    @Environment(\.colorScheme) private var colorScheme
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
            VStack(spacing: 14) {
                Text("Firebase Login\nSample")
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 44)

                Spacer()

                Text("Sign in")
                        .font(.title2.weight(.semibold))
                        .padding(.bottom, 18)

                Button(action: { showLoginWithEmailAndPassword = true }) {
                    Text("With Email & Password")
                }
                        .buttonStyle(LoginKindButtonStyle(backgroundColor: .orange, foregroundColor: .white))
                        .sheet(isPresented: $showLoginWithEmailAndPassword) {
                            CredentialPageView(title: "Login to Firebird\nwith Email and Password", showing: $showLoginWithEmailAndPassword) { am in
                                CustomTextField(label: "Email", placeholder: "Mandatory", value: $email)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .padding(.bottom, 18)

                                CustomTextField(label: "Password", placeholder: "Mandatory", value: $password, options: [.secure, .unsecureButton])
                                        .padding(.bottom, 44)

                                Button(action: {
                                    userProfile.signIn(withEmail: email, password: password) { error in
                                        am.setAlert(title: "Login with Password", error: error)
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
                            CredentialPageView(title: "Login to Firebase\nby Email Link", showing: $showLoginByEmailLink) { am in
                                CustomTextField(label: "Email", placeholder: "Mandatory", value: $email)
                                        .disableAutocorrection(true)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .padding(.bottom, 44)

                                Button(action: {
                                    userProfile.sendSignInLink(withEmail: email) { error in
                                        am.setAlert(title: "Login by Link", error: error)
                                    }
                                }) {
                                    Text("Send Link")
                                }
                                        .buttonStyle(CredentialButtonStyle())
                            }
                        }
                
                Button(action: {
                    userProfile.signInWithFB { error in
                        alertItem = AlertItem(title: "Sign in with Facebook", error: error)
                    }
                } ) {
                    HStack {
                        Image("FB Logo White")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
//                            .renderingMode(.none)
                            .frame(width: 22, height: 22)
                        Text("Login with Facebook")
                    }
                }
                        .buttonStyle(LoginKindButtonStyle(backgroundColor: Color("FB Background"), foregroundColor: .white))

                Button(action: {
                    userProfile.signInWithGoogle { error in
                        alertItem = AlertItem(title: "Sign in with Google", error: error)
                    }
                }) {
                    HStack {
                        Image(colorScheme == .dark ? "Google Dark Normal" : "Google Light Normal")
                                .resizable()
                                .frame(width: 30, height: 30)
                        Text("Sign in with Google")
                    }
                }
                        .buttonStyle(LoginKindButtonStyle(backgroundColor: Color("Google Background"), foregroundColor: .white))


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
                                        alertItem = AlertItem(title: "Login with Apple", error: error)
                                    }
                                default:
                                    alertItem = AlertItem(title: "Login with Apple", message: "Oops! Something went wrong.")
                                }
                            case .failure(let error):
                                alertItem = AlertItem(title: "Login with Apple", error: error)
                            }
                        }
                )
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black) // TODO: if the color scheme changes when app is open, the button appearance does not change. Need to fix it.
                        .frame(height: 44)
                

                Spacer()
            }
                    .padding(8)
                    .onOpenURL { url in
                        userProfile.signIn(url: url) { error in
                            alertItem = AlertItem(title: "Error", error: error)
                        }
                    }
                    .alert(item: $alertItem) {
                        $0.alert
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


