//
//  FirebaseLoginApp.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 03.04.2021.
//

import SwiftUI
import Firebase
import FBSDKCoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        var injectionBundlePath = "/Applications/InjectionIII.app/Contents/Resources"
        #if targetEnvironment(macCatalyst)
        injectionBundlePath = "\(injectionBundlePath)/macOSInjection.bundle"
        #elseif os(iOS)
        injectionBundlePath = "\(injectionBundlePath)/iOSInjection.bundle"
        #endif
        Bundle(path: injectionBundlePath)?.load()
        #endif

        ApplicationDelegate.shared.application(
                application,
                didFinishLaunchingWithOptions: launchOptions
        )

        return true
    }
}

@main
struct FirebaseLoginApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var userProfile = UserProfile()

    var body: some Scene {
        WindowGroup {
            LoginView()
                    .environmentObject(userProfile)
                    .onOpenURL { url in
                        ApplicationDelegate.shared.application(UIApplication.shared, open: url, sourceApplication: nil, annotation: UIApplication.OpenURLOptionsKey.annotation)
                    }
        }
    }

    init() {
        FirebaseApp.configure()
    }
}
