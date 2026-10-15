//
//  AppDelegate+Firebase.swift
//  iTorrent
//
//  Created by Даниил Виноградов on 20.04.2024.
//

import Foundation
#if canImport(FirebaseCore)
import FirebaseCore
#endif

/// False when the build has no real GoogleService-Info.plist (builds without the
/// author's Firebase secrets, like OMetaVR's). Firebase would crash on a placeholder.
let isFirebaseAvailable: Bool = {
    guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path)
    else { return false }
    return plist["GOOGLE_APP_ID"] != nil
}()

extension AppDelegate {
    func registerFirebase() {
#if canImport(FirebaseCore)
        guard isFirebaseAvailable else { return }
        FirebaseApp.configure()
#endif
    }
}
