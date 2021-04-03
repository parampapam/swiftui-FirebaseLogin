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
            Text("Current user:")
            Text("\(userProfile.userDisplayName ?? "")")
            Button(action: { userProfile.signOut() } ){
                Text("Sign Out")
            }
            .padding(.top)
        }
        .padding()
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
