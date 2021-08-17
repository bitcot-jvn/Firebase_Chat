//
//  Channel.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 09/08/21.
//


import FirebaseFirestore

struct Channel {
    var id: String?
    var name: String

    init(name: String) {
        self.name = name
        self.id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        id = document.documentID
        self.name = name
    }
}

// MARK: - DatabaseRepresentation
extension Channel: DatabaseRepresentation {
    var representation: [String: Any] {
        var rep = ["name": name]
        
        if let id = id {
            rep["id"] = id
        }
        
        return rep
    }
}

// MARK: - Comparable
extension Channel: Comparable {
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.name < rhs.name
    }
}


protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}
