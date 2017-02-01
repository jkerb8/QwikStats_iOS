//
//  DefaultPreferences.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/31/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import Foundation


class DefaultPreferences {
    
    static let PREF_USER_NAME = "username"
    static let PREF_PASSWORD = "password"
    static let PREF_ID = "id"
    static let PREF_TEAMNAME = "teamname"
    static let PREF_FIRST_TIME = "firsttime"
    static let PREF_UUID = "uuid"
    
    static func getDefaultPreferences() -> UserDefaults {
        return UserDefaults.standard
    }
    
    public static func setUserName(username: String) {
        let prefs = getDefaultPreferences()
        prefs.set(username, forKey: PREF_USER_NAME)
        prefs.synchronize()
    }
    
    public static func getUserName() -> String {
        let prefs = getDefaultPreferences()
        return prefs.string(forKey: PREF_USER_NAME)!
    }
    
    public static func setPassword(password: String) {
        let prefs = getDefaultPreferences()
        prefs.set(password, forKey: PREF_PASSWORD)
        prefs.synchronize()
    }
    
    public static func getPassword() -> String {
        let prefs = getDefaultPreferences()
        return prefs.string(forKey: PREF_PASSWORD)!
    }
    
    public static func setId(id: String) {
        let prefs = getDefaultPreferences()
        prefs.set(id, forKey: PREF_ID)
        prefs.synchronize()
    }
    
    public static func getId() -> String {
        let prefs = getDefaultPreferences()
        return prefs.string(forKey: PREF_ID)!
    }
    
    public static func setTeamName(teamname: String) {
        let prefs = getDefaultPreferences()
        prefs.set(teamname, forKey: PREF_TEAMNAME)
        prefs.synchronize()
    }
    
    public static func getTeamName() -> String {
        let prefs = getDefaultPreferences()
        return prefs.string(forKey: PREF_TEAMNAME)!
    }
    
    public static func setNotFirstTime(firsttime: Bool) {
        let prefs = getDefaultPreferences()
        prefs.set(firsttime, forKey: PREF_FIRST_TIME)
        prefs.synchronize()
    }
    
    public static func getNotFirstTime() -> Bool {
        let prefs = getDefaultPreferences()
        return prefs.bool(forKey: PREF_FIRST_TIME)
    }
    
    public static func setUUID(uuid: String) {
        let prefs = getDefaultPreferences()
        prefs.set(uuid, forKey: PREF_UUID)
        prefs.synchronize()
    }
    
    public static func getUUID() -> String {
        let prefs = getDefaultPreferences()
        return prefs.string(forKey: PREF_UUID)!
    }
}
