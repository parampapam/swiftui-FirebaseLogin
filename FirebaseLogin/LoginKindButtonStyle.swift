//
// Created by Роман Поспелов on 29.04.2021.
//

import SwiftUI

struct LoginKindButtonStyle: ButtonStyle {

    let backgroundColor: Color
    let foregroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundColor(foregroundColor)
                .background(backgroundColor.cornerRadius(6))
    }
}
