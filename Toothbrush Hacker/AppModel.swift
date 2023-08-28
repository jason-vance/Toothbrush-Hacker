//
//  AppModel.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import Combine

@MainActor
class AppModel: ObservableObject {
    
    @Published var connectedState: BleConnectedState = .disconnected
    
    let bleConnector: BleConnector
    
    var subs: Set<AnyCancellable> = []
    
    init(bleConnector: BleConnector) {
        self.bleConnector = bleConnector
        
        bleConnector.connectedStatePublisher
            .sink { self.connectedState = $0 }
            .store(in: &subs)
    }
}
