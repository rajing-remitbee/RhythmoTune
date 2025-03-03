//
//  Appwrite.swift
//  RhythmoTune
//
//  Created by Rajin Gangadharan on 26/02/25.
//

import Foundation
import Appwrite
import JSONCodable

class Appwrite {
    var client: Client
    var account: Account
    
    public init() {
        self.client = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("67bd5300003544ce4f47")
        
        self.account = Account(client)
    }
    
    public func onRegister(_ email: String, _ password: String) async throws -> (userId: String, user: User<[String: AnyCodable]>) {
        let user = try await account.create(userId: ID.unique(), email: email, password: password)
        return (user.id, user)
    }
    
    public func onLogin(_ email: String, _ password: String) async throws -> (userId: String, session: Session) {
        let session = try await account.createEmailPasswordSession(email: email, password: password)
        return (session.userId, session)
    }
    
    public func onLogout() async throws {
        _ = try await account.deleteSession(sessionId: "current")
    }
    
}

