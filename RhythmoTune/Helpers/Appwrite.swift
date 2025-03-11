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
    var client: Client //Appwrite Client
    var account: Account //Appwrite Account
    
    var databases: Databases //Appwrite database
    var storage: Storage //Appwrite storage
    
    //Constructor
    public init() {
        self.client = Client().setEndpoint("https://cloud.appwrite.io/v1").setProject("67bd5300003544ce4f47") //Setup client
        self.account = Account(client) //Setup account
        self.databases = Databases(client) //Setup databases
        self.storage = Storage(client) //Setup storage
    }
    
    //Register Service
    public func onRegister(_ email: String, _ password: String) async throws -> (userId: String, user: User<[String: AnyCodable]>) {
        let user = try await account.create(userId: ID.unique(), email: email, password: password) //Register User
        return (user.id, user)
    }
    
    //Login Service
    public func onLogin(_ email: String, _ password: String) async throws -> (userId: String, session: Session) {
        let session = try await account.createEmailPasswordSession(email: email, password: password) //Login user and create session
        return (session.userId, session)
    }
    
    //Logout Service
    public func onLogout() async throws {
        _ = try await account.deleteSession(sessionId: "current") //Delete Session
    }
    
    
    //Fetch Artist Service
    public func fetchArtists() async throws -> [Artist] {
        let databaseId = "67c5436a0006be1cbf19"
        let collectionId = "67c54490002de5e9e6b3"
        
        let documents = try await self.databases.listDocuments(databaseId: databaseId, collectionId: collectionId) //Fetch Artists document
        
        //Iterate and fetch artists
        return documents.documents.compactMap { document in
            if let artistId = document.data["artistID"], let name = document.data["name"], let bio = document.data["bio"], let imageUrl = document.data["imageURL"] {
                return Artist(artistID: "\(artistId)", name: "\(name)", bio: "\(bio)", imageURL: "\(imageUrl)") //Artist Object
            } else {
                return nil
            }
        }
    }
    
    //Fetch Songs Service
    public func fetchSongs() async throws -> [Song] {
        let databaseId = "67c5436a0006be1cbf19"
        let collectionId = "67c54432002976f34945"
        
        let documents = try await self.databases.listDocuments(databaseId: databaseId, collectionId: collectionId) //Fetch Songs document
        
        //Iterate and fetch songs
        return documents.documents.compactMap { document in
            if let songId = document.data["songID"], let title = document.data["title"], let artist = document.data["artist"], let album = document.data["album"], let genre = document.data["genre"], let duration = document.data["duration"], let file = document.data["filepath"], let cover = document.data["coverArt"] {
                return Song(songID: "\(songId)", title: "\(title)", artist: "\(artist)", album: "\(album)", genre: "\(genre)", duration: Int("\(duration)") ?? 0, filepath: "\(file)", coverArt: "\(cover)") //Song Object
            } else {
                return nil
            }
        }
    }
    
    // Fetch Songs for Specific Artist Service
    public func fetchSongs(artist artistName: String) async throws -> [Song] {
        let databaseId = "67c5436a0006be1cbf19"
        let collectionId = "67c54432002976f34945"
        
        let documents = try await self.databases.listDocuments(
            databaseId: databaseId,
            collectionId: collectionId,
            queries: [Query.equal("artist", value: artistName)]
        )
        
        return documents.documents.compactMap { document in
            if let songId = document.data["songID"], let title = document.data["title"], let artist = document.data["artist"], let album = document.data["album"], let genre = document.data["genre"], let duration = document.data["duration"], let file = document.data["filepath"], let cover = document.data["coverArt"] {
                return Song(songID: "\(songId)", title: "\(title)", artist: "\(artist)", album: "\(album)", genre: "\(genre)", duration: Int("\(duration)") ?? 0, filepath: "\(file)", coverArt: "\(cover)")
            } else {
                return nil
            }
        }
    }
}

