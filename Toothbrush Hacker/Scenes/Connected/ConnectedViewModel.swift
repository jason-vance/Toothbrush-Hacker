//
//  ConnectedViewModel.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import Combine

@MainActor
class ConnectedViewModel: ObservableObject {
    
    @Published var currentBatteryLevel: Float = 0
    
    let bleConnector: BleConnector
    let batteryMonitor: BleDeviceBatteryMonitor
    
    var subs: Set<AnyCancellable> = []

    init(
        bleConnector: BleConnector,
        batteryMonitor: BleDeviceBatteryMonitor
    ) {
        self.bleConnector = bleConnector
        self.batteryMonitor = batteryMonitor
        
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        monitorBatteryLevel()
    }
    
    private func monitorBatteryLevel() {
        batteryMonitor.currentBatteryLevelPublisher
            .receive(on: RunLoop.main)
            .sink { self.currentBatteryLevel = $0 }
            .store(in: &subs)
    }
    
    func disconnect() {
        bleConnector.cancelConnection()
    }
}
