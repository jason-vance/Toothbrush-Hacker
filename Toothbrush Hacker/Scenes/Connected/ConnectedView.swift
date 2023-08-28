//
//  ConnectedView.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import SwiftUI

struct ConnectedView: View {
    
    @StateObject var model = ConnectedViewModel(
        connector: BleDeviceManager.instance,
        batteryMonitor: BleDeviceBatteryMonitor(deviceManager: BleDeviceManager.instance)
    )
    
    var body: some View {
        VStack {
            Text("Connected!")
                .padding()
            Button("Disconnect") {
                model.disconnect()
            }
        }
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
