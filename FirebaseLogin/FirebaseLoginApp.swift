//
//  FirebaseLoginApp.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//

import SwiftUI
//import Firebase

@main
struct FirebaseLoginApp: App {

    @StateObject var userProfile = UserProfile()

//    init() {
//        FirebaseApp.configure()
//        userProfile = UserProfile()
//    }

    var body: some Scene {
        WindowGroup {
            MainView()
                    .environmentObject(userProfile)
        }
    }
}
