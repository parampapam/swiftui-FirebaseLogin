//
//  AlertItem.swift
//  FirebaseLogin
//
//  Created by Роман Поспелов on 07.04.2021.
//

import Foundation

struct AlertItem: Identifiable {
    private(set) var id = UUID()
    var title: String
    var message: String
}
