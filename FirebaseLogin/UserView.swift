//
//  UserView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//

import SwiftUI

struct UserView: View {

    @EnvironmentObject private var userProfile: UserProfile

    var body: some View {
        VStack {
            Text("Firebase Login\nSample")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(44)

            Text("You are logged in to Firebase")
                    .font(.title3.weight(.semibold))
                    .padding(.bottom, 44)

            Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color(.secondarySystemFill))
                    .shadow(radius: 10)
                    .clipShape(Circle())
                    .frame(height: 220)

            VStack {
                Text("\(userProfile.userDisplayName ?? "Noname User")")
                Text("\(userProfile.userEmail ?? "")")
            }
            .font(.title3.weight(.medium))
            .padding(.top)

            Spacer()

            Button(action: { userProfile.signOut() }) {
                Text("Sign Out")
            }
                    .padding(.top)
        }
                .padding()
    }
}

class UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }

    #if DEBUG
    @objc class func injected() {
        UIApplication.shared.windows.first?.rootViewController =
                UIHostingController(rootView: UserView().environmentObject(UserProfile()))
    }
    #endif
}
