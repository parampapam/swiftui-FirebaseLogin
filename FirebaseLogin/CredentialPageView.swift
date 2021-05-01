//
//  BaseView.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 29.04.2021.
//
//

import SwiftUI

struct CredentialPageView<Content: View>: View {

    private var title: String
    private var content: Content
    @Binding var showing: Bool

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

            content

            Spacer()
        }
        .padding()
    }

    init (title: String, showing: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._showing = showing
        self.content = content()
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialPageView(title: "Login Page", showing: Binding.constant(true), content: { })
    }
}
