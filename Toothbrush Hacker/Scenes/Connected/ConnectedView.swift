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
        batteryMonitor: BlePeripheralBatteryMonitor(
            device: AppModel.instance.toothbrushConnection!.peripheral
        ),
        deviceBasicInfoReader: BlePeripheralDeviceInfoReader(
            device: AppModel.instance.toothbrushConnection!.peripheral
        ),
        deviceVersionInfoReader: BlePeripheralDeviceInfoReader(
            device: AppModel.instance.toothbrushConnection!.peripheral
        ),
        deviceExtendedInfoReader: BlePeripheralDeviceInfoReader(
            device: AppModel.instance.toothbrushConnection!.peripheral
//        ),
//        toothbrushPropertyReader: ToothbrushPropertyReader(
//            device: AppModel.instance.toothbrushConnection!.peripheral
        )
    )
    
    var body: some View {
        ScrollView {
            VStack {
                ConnectedCard()
                DeviceBasicInformationCard()
                DeviceVersionInformationCard()
                DeviceExtendedInformationCard()
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
    
    @ViewBuilder func ConnectedCard() -> some View {
        Text("Connected")
            .font(.title.bold())
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                CardBackground()
            }
            .padding(.horizontal)
    }
    
    @ViewBuilder func DeviceBasicInformationCard() -> some View {
        VStack(spacing: 16) {
            DeviceInfoLabel("Manufacturer Name:", value: model.manufacturerName ?? "--")
            DeviceInfoLabel("Model Number:", value: model.modelNumber ?? "--")
            DeviceInfoLabel("Serial Number:", value: model.serialNumber ?? "--")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            CardBackground()
        }
        .padding(.horizontal)
        .onTapGesture {
            model.fetchDeviceBasicInfo()
        }
    }
    
    @ViewBuilder func DeviceVersionInformationCard() -> some View {
        VStack(spacing: 16) {
            DeviceInfoLabel("Software Revision:", value: model.softwareRevision ?? "--")
            DeviceInfoLabel("Firmware Revision:", value: model.firmwareRevision ?? "--")
            DeviceInfoLabel("Hardware Revision:", value: model.hardwareRevision ?? "--")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            CardBackground()
        }
        .padding(.horizontal)
        .onTapGesture {
            model.fetchDeviceVersionInfo()
        }
    }
    
    @ViewBuilder func DeviceExtendedInformationCard() -> some View {
        VStack(spacing: 16) {
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
        .onTapGesture {
            model.fetchDeviceExtendedInfo()
        }
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
        .onTapGesture {
            model.fetchBatteryLevel()
        }
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
