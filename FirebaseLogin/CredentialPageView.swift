//
//  BaseView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 29.04.2021.
//
//

import SwiftUI

struct CredentialPageView<Content: View>: View {

    @ObservedObject private var alertManager = AlertManager()

    private var title: String
    private var content: (AlertManager) -> Content
    @Binding private var showing: Bool

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { showing = false }, label: {
                    Text("Cancel")
                })
            }

            Spacer()

            Text(title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

            Spacer()
                    .frame(height: 72)

            content(alertManager)

            Spacer()
        }
        .padding()
        .alert(item: $alertManager.alertItem) {
            $0.alert
        }
    }

    init (title: String, showing: Binding<Bool>, @ViewBuilder content: @escaping (AlertManager) -> Content) {
        self.title = title
        self._showing = showing
        self.content = content
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialPageView(title: "Login Page", showing: Binding.constant(true), content: { _ in
            Text("Hello, world!")
        })
    }
}
