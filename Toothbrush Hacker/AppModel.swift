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
    
    @Published var connectedState: ConnectedState = .disconnected
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    var toothbrushConnection: BleDeviceConnection? = nil {
        didSet {
            toothbrushConnection?.$connectedState
                .receive(on: RunLoop.main)
                .sink { self.connectedState = $0 }
                .store(in: &subs)
        }
    }
    
    var subs: Set<AnyCancellable> = []
    
    static let instance: AppModel = AppModel()
    
    private init() {}
    
    func connect(device: DiscoveredPeripheral) {
        toothbrushConnection = BleDeviceConnection.getOrCreate(from: device.peripheral)
        Task {
            do {
                try await toothbrushConnection!.connect()
            } catch {
                show(alertMessage: "Failed to connect")
            }
        }
    }
    
    func show(alertMessage: String) {
        showAlert = true
        self.alertMessage = alertMessage
    }
}
