//
//  Toothbrush_HackerApp.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/26/23.
//

import SwiftUI

@main
struct Toothbrush_HackerApp: App {
    
    @StateObject var model = AppModel(
        bleConnector: BleService.instance
    )
    
    var body: some Scene {
        WindowGroup {
            if model.connectedState == .disconnected {
                ScannerView()
            } else {
                ConnectedView()
            }
        }
    }
}
