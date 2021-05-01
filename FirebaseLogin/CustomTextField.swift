//
//  CustomTextField.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 28.04.2021.
//
//

import SwiftUI

struct CustomTextField: View {

    var label: String
    var placeholder: String
    @Binding var value: String
    var options: Set<Option> = []

    enum Option {
        // Secure field for a password
        case secure
        // Show "Eye" button to show and hide characters in secure field
        case unsecureButton
    }

    @State private var unsecureValue = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color(.secondaryLabel))

            VStack {
                if options.contains(.secure) {
                    HStack {
                        if unsecureValue {
                            TextField(placeholder, text: $value)
                        } else {
                            SecureField(placeholder, text: $value)
                        }

                        // Show "Eye" button if the secure field has a value and option unsecureButton is set
                        if !value.isEmpty && options.contains(.unsecureButton) {
                            Button(action: { unsecureValue.toggle() }, label: {
                                Image(systemName: unsecureValue ? "eye.fill" : "eye.slash.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(Color(.label))
                                        .frame(width: 16, height: 20, alignment: .trailing)
                            })
                        }
                    }
                } else {
                    TextField(placeholder, text: $value)
                }
            }
                    .frame(height: 20)
                    .padding(.top, 4)

            Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.secondaryLabel))
        }
                .onChange(of: value) {
                    // If the value variable is empty hide characters in the secure field so that
                    //  new value is hidden by default
                    if $0.isEmpty {
                        unsecureValue = false
                    }
                }
    }
}

class CustomTextField_Previews: PreviewProvider {

    static var previews: some View {
        CustomTextField(label: "Email", placeholder: "Mandatory", value: Binding.constant(""))
                .padding()
    }

    #if DEBUG
    @objc class func injected() {
        UIApplication.shared.windows.first?.rootViewController =
                UIHostingController(rootView: CustomTextField(label: "Password", placeholder: "Mandatory", value: Binding.constant(""), options: [.secure, .unsecureButton]).padding())
    }
    #endif
}
