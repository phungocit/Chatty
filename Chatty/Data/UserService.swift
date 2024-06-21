//
//  UserService.swift
//  Chatty
//
//  Created by Phil Tran on 16/6/24.
//

import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift
import FirebaseFirestoreSwift
import Foundation

class UserService {
    @Published var currentUser: User?

    static let shared = UserService()

    init() {
        Task {
            try await fetchCurrentUser()
        }
    }

    @MainActor
    func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await Firestore.firestore().collection(CollectionPath.users).document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        currentUser = user
    }

    static func fetchAllUsers(limit: Int? = nil) async throws -> [User] {
        let query = FirestoreConstants.userCollection
        if let limit { query.limit(to: limit) }
        let snapshot = try await query.getDocuments()
        let users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
        return users
    }

    static func fetchUser(withUid uid: String, completion: @escaping (User) -> Void) {
        FirestoreConstants.userCollection.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            completion(user)
        }
    }

    @MainActor
    func updateUserProfileImage(withImageUrl imageUrl: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await Firestore.firestore().collection(CollectionPath.users).document(currentUid).updateData([
            "profileImageUrl": imageUrl,
        ])
        currentUser?.profileImageUrl = imageUrl
    }
}

extension UserService {
    static func getUsers(with uids: [String], completion: @escaping (UserNode) -> Void) {
        var users = [UserItem]()
        for uid in uids {
            let query = FirebaseConstants.UserRef.child(uid)
            query.observeSingleEvent(of: .value) { snapshot in
                guard let user = try? snapshot.data(as: UserItem.self) else { return }
                users.append(user)
                if users.count == uids.count {
                    completion(UserNode(users: users))
                }
            } withCancel: { _ in
                completion(.emptyNode)
            }
        }
    }

    static func paginateUsers(lastCursor: String?, pageSize: UInt) async throws -> UserNode {
        let mainSnapshot: DataSnapshot
        if lastCursor == nil {
            mainSnapshot = try await FirebaseConstants.UserRef.queryLimited(toLast: pageSize).getData()
        } else {
            mainSnapshot = try await FirebaseConstants.UserRef
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toLast: pageSize + 1)
                .getData()
        }

        guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
              let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyNode }

        let users = allObjects.compactMap { userSnapshot in
            let userDict = userSnapshot.value as? [String: Any] ?? [:]
            return UserItem(dictionary: userDict)
        }

        if users.count == mainSnapshot.childrenCount {
            let filteredUsers = lastCursor == nil ? users : users.filter { $0.uid != lastCursor }
            let userNode = UserNode(users: filteredUsers, currentCursor: first.key)
            return userNode
        }

        return .emptyNode
    }
}

struct UserNode {
    var users: [UserItem]
    var currentCursor: String?
    static let emptyNode = UserNode(users: [], currentCursor: nil)
}
