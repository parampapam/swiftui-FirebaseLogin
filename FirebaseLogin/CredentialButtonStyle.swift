//
// Created by Роман Поспелов on 29.04.2021.
//

import SwiftUI

struct CredentialButtonStyle: ButtonStyle {

    // TODO: Change color for the login button
    private let backgroundColor: Color = .black
    private let foregroundColor: Color = .white

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
                .padding(.vertical, 10)
                .padding(.horizontal, 32)
                .fixedSize()
                .foregroundColor(foregroundColor)
                .background(backgroundColor.cornerRadius(6))
    }
}
