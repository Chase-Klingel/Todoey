//
//  AppDelegate.swift
//  Todoey
//
//  Created by Chase Klingel on 5/28/18.
//  Copyright © 2018 Chase Klingel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // print(Realm.Configuration.defaultConfiguration.fileURL)

        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                print(oldSchemaVersion)
                if (oldSchemaVersion < 2) {
                    // The enumerateObjects(ofType:_:) method iterates
                    // over every Person object stored in the Realm file
                    migration.enumerateObjects(ofType: Category.className()) { oldObject, newObject in
                        newObject!["backgroundColor"] = UIColor.randomFlat.hexValue()
                    }
                }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        return true
    }
}

