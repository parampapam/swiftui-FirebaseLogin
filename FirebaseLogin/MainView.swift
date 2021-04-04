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

    var body: some View {
        if userProfile.signedIn {
            UserView()
        } else {
            LoginWithEmailAndPasswordView()
        }
    }
}

class MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }

    #if DEBUG
    @objc class func injected() {
        UIApplication.shared.windows.first?.rootViewController =
                UIHostingController(rootView: MainView())
    }
    #endif
}
