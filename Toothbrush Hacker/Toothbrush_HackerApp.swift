//
//  Toothbrush_HackerApp.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/26/23.
//

import SwiftUI

@main
struct Toothbrush_HackerApp: App {
    
    @StateObject var model = AppModel.instance
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay {
                    if model.connectedState == .connecting {
                        ZStack {
                            Rectangle()
                                .background(.ultraThinMaterial)
                                .ignoresSafeArea()
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                }
                .alert(model.alertMessage, isPresented: $model.showAlert) {}
        }
    }
    
    @ViewBuilder func ContentView() -> some View {
        if model.connectedState != .connected {
            ScannerView(
                onDeviceSelected: { model.connect(device: $0) }
            )
        } else {
            ConnectedView()
        }
    }
}
