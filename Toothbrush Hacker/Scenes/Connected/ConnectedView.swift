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
        ),
        toothbrushPropertyReader: ToothbrushPropertyReader(
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
        VStack(spacing: 16) {
            Text("Connected")
                .font(.title.bold())
            DeviceInfoLabel("Manufacturer Name:", value: model.manufacturerName ?? "--")
            DeviceInfoLabel("Model Number:", value: model.modelNumber ?? "--")
            DeviceInfoLabel("Serial Number:", value: model.serialNumber ?? "--")
            DeviceInfoLabel("Software Revision:", value: model.softwareRevision ?? "--")
            DeviceInfoLabel("Firmware Revision:", value: model.firmwareRevision ?? "--")
            DeviceInfoLabel("Hardware Revision:", value: model.hardwareRevision ?? "--")
            DeviceInfoLabel("System Id:", value: model.systemId != nil ? "\(model.systemId!)" : "--")
            DeviceInfoLabel("IEEE Certification:", value: model.ieeeCertification != nil ? "\(model.ieeeCertification!)" : "--")
            DeviceInfoLabel("PnP Id:", value: model.pnpId != nil ? "\(model.pnpId!)" : "--")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            CardBackground()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func DeviceInfoLabel(_ label: String, value: String) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .font(.caption.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
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
