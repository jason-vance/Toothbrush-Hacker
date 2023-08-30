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
            device: AppModel.instance.toothbrushConnection!.peripheral
        ),
        deviceInfoReader: BleDeviceInformationReader(
            device: AppModel.instance.toothbrushConnection!.peripheral
        )
    )
    
    var body: some View {
        ScrollView {
            VStack {
                DeviceInformationCard()
                BatteryLevelCard()
                DisconnectButton()
            }
        }
        .background {
            Color.primary
                .opacity(0.1)
                .ignoresSafeArea()
        }
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
    }
    
    @ViewBuilder func DeviceInformationCard() -> some View {
        Text("Connected")
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                CardBackground()
            }
            .padding(.horizontal)
    }
    
    @ViewBuilder func BatteryLevelCard() -> some View {
        HStack {
            Text("Battery Level:")
            Spacer()
            Text(model.currentBatteryLevel?.formatted(.percent) ?? "--")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            CardBackground()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func DisconnectButton() -> some View {
        Button("Disconnect") {
            model.disconnect()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            CardBackground()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func CardBackground() -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.background)
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedView()
    }
}
