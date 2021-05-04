//
//  AlertItem.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 07.04.2021.
//

import Foundation
import SwiftUI

// This structure to create and display alert message via the alert(item) modifier
struct AlertItem: Identifiable {
    private(set) var id = UUID()
    var title: String
    var message: String?

    var alert: Alert {
        Alert(title: Text(title), message: message != nil ? Text(message!) : nil)
    }

    init(title: String, message: String?) {
        self.title = title
        self.message = message
    }

    init?(title: String, error: Error?) {
        guard let error = error else {
            return nil
        }
        self.title = title
        message = error.localizedDescription
    }
}

// To track the appearance of alert message in the View to display them through
// the alert(item) modifier of the View.
class AlertManager: ObservableObject {

    @Published var alertItem: AlertItem?

    func setAlert(title: String, message: String? = nil) {
        alertItem = AlertItem(title: title, message: message)
    }

    func setAlert(title: String, error: Error?) {
        alertItem = AlertItem(title: title, error: error)
    }
}