//
//  MainView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//
//

import SwiftUI

struct MainView: View {

    @EnvironmentObject private var userProfile: UserProfile
    @State private var alertItem: AlertItem?

    var body: some View {
        if userProfile.signedIn {
            UserView()
        } else {
            NavigationView {
                VStack {
                    Text("Sign in")
                        .padding(.bottom, 16)

                    NavigationLink(destination: LoginWithEmailAndPasswordView(alertItem: $alertItem)) {
                        Text("Email & Password")
                            .padding(8)
                    }

                    NavigationLink(destination: LoginWithEmailLink(alertItem: $alertItem)) {
                        Text("Email Link")
                            .padding(8)
                    }

                    NavigationLink(destination: LoginWithApple()) {
                        Text("With Apple")
                                .padding(8)
                    }
                }
            }
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
        MainView()
            .environmentObject(UserProfile())
    }

    #if DEBUG
    @objc class func injected() {
        UIApplication.shared.windows.first?.rootViewController =
            UIHostingController(rootView: MainView().environmentObject(UserProfile()))
    }
    #endif
}
