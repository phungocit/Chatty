//
//  User.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import FirebaseFirestoreSwift
import Foundation

struct User: Codable, Identifiable, Hashable {
    @DocumentID var uid: String?
    let fullName: String
    let email: String
    var profileImageUrl: String?

    var id: String {
        uid ?? UUID().uuidString
    }

    var firstName: String {
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: fullName)
        return components?.givenName ?? fullName
    }
}

extension User {
    static let MOCK_USER = User(uid: "WDjaUHo99ZajX129Kil09I5hqmI3", fullName: "Spiderman", email: "admin11@gmail.com", profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/swiftui-firebase-chat-837dc.appspot.com/o/profile_images%2F1DC90564-BD8F-4C47-ACA2-FB9A156B8C02?alt=media&token=aae8f8a9-4811-42d3-a26f-c2d169c9ad90")
}
