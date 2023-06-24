//
//  RealFlower.swift
//  LeckerRealmProject
//
//  Created by Emre Tekin on 16.06.2023.
//

import Foundation
import RealmSwift

class RealFlower: Object {
    @Persisted var id: UUID?
    @Persisted var firstName: String
    @Persisted var imagePath: String

    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["firstName"]
    }
}

struct RealFlowerHashableWrapper: Hashable {
    let realFlower: RealFlower
    
    static func == (lhs: RealFlowerHashableWrapper, rhs: RealFlowerHashableWrapper) -> Bool {
        return lhs.realFlower.id == rhs.realFlower.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(realFlower.id)
    }
}
