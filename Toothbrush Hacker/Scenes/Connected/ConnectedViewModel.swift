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
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let toothbrushConnection: BleDeviceConnection
    let batteryMonitor: DeviceBatteryMonitor
    
    var subs: Set<AnyCancellable> = []

    init(
        toothbrushConnection: BleDeviceConnection,
        batteryMonitor: DeviceBatteryMonitor
    ) {
        self.toothbrushConnection = toothbrushConnection
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
        Task {
            do {
                try await toothbrushConnection.cancelConnection()
            } catch {
                show(alertMessage: "Error while disconnecting")
            }
        }
    }
    
    func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
}
