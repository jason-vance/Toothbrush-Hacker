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
    
    let connector: DeviceConnector
    let batteryMonitor: DeviceBatteryMonitor
    
    var subs: Set<AnyCancellable> = []

    init(
        connector: DeviceConnector,
        batteryMonitor: DeviceBatteryMonitor
    ) {
        self.connector = connector
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
        connector.cancelConnection()
    }
}
