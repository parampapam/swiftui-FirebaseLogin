//
//  LoginWithAppleID.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 15.04.2021.
//

import SwiftUI
import AuthenticationServices

struct LoginWithApple: View {
    @EnvironmentObject private var userProfile: UserProfile

    var body: some View {

        VStack {
            SignInWithAppleButton(
                onRequest: { request in
                    userProfile.prepareAppleIDAuthorizationRequest(request)
                },
                onCompletion: { result in
                    userProfile.completeAppleIDAuthorization(result)
                }
            )
            .frame(maxHeight: 44)
        }
        .padding()
    }
}

struct LoginWithApple_Previews: PreviewProvider {
    static var previews: some View {
        LoginWithApple()
    }
}
