//
//  ConnectedView.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import SwiftUI

struct ConnectedView: View {
    
    @StateObject var model = ConnectedViewModel(
        toothbrushConnection: AppModel.instance.toothbrushConnection!,
        batteryMonitor: BleDeviceBatteryMonitor(
            deviceCommunicator: BleDeviceCommunicator(
                connection: AppModel.instance.toothbrushConnection!
            )
        )
    )
    
    var body: some View {
        VStack {
            Text("Connected!")
                .padding()
            Button("Disconnect") {
                model.disconnect()
            }
        }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
