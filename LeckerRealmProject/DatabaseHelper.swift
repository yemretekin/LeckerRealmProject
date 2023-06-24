//
//  DatabaseHelper.swift
//  LeckerRealmProject
//
//  Created by Emre Tekin on 16.06.2023.
//

import RealmSwift
import UIKit

class DatabaseHelper{

    static let shared = DatabaseHelper()

    private var realm = try! Realm()

    func getDatabasePath() -> URL?{
        return Realm.Configuration.defaultConfiguration.fileURL
    }
    
    func saveFlowers(rFlower: RealFlower){
        try! realm.write({
            realm.add(rFlower)
        })
    }

    func deleteFlowers(rFlowers: RealFlower){
            self.realm.writeAsync {
                self.realm.delete(rFlowers)
            }
        }

    func getAllFlowers() -> [RealFlower]{
        return Array(realm.objects(RealFlower.self))
    }
}

