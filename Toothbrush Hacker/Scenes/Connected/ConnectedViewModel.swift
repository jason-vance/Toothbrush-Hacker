//
//  ConnectedViewModel.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation

@MainActor
class ConnectedViewModel: ObservableObject {
    
    let bleConnector: BleConnector
    
    init(bleConnector: BleConnector) {
        self.bleConnector = bleConnector
    }
    
    func disconnect() {
        bleConnector.cancelConnection()
    }
}
