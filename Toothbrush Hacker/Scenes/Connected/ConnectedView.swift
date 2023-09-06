//
//  ConnectedView.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import SwiftUI

struct ConnectedView: View {
    
    @StateObject var model = ConnectedViewModel(
        toothbrushConnection: AppModel.instance.toothbrushConnection!
    )
    
    var body: some View {
        ScrollView {
            VStack {
                ConnectedCard()
                DeviceBasicInformationCard()
                DeviceVersionInformationCard()
                BatteryLevelCard01()
                BatteryLevelCard02()
                DeviceExtendedInformationCard()
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
            DeviceInfoLabel("Manufacturer Name:", value: model.manufacturerName ?? "Tap to read")
            DeviceInfoLabel("Model Number:", value: model.modelNumber ?? "Tap to read")
            DeviceInfoLabel("Serial Number:", value: model.serialNumber ?? "Tap to read")
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
            DeviceInfoLabel("Software Revision:", value: model.softwareRevision ?? "Tap to read")
            DeviceInfoLabel("Firmware Revision:", value: model.firmwareRevision ?? "Tap to read")
            DeviceInfoLabel("Hardware Revision:", value: model.hardwareRevision ?? "Tap to read")
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
            DeviceInfoLabel("System Id:", value: model.systemId != nil ? "\(model.systemId!)" : "Tap to read")
            DeviceInfoLabel("IEEE Certification:", value: model.ieeeCertification != nil ? "\(model.ieeeCertification!)" : "Tap to read")
            DeviceInfoLabel("PnP Id:", value: model.pnpId != nil ? "\(model.pnpId!)" : "Tap to read")
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
    
    @ViewBuilder func BatteryLevelCard01() -> some View {
        HStack {
            Text("Battery Level 01:")
            Spacer()
            if model.isListening01 {
                Text(model.currentBatteryLevel?.formatted(.percent) ?? "--")
            } else {
                Text("Start listening")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            CardBackground()
        }
        .padding(.horizontal)
        .onTapGesture {
            model.fetchBatteryLevel01()
        }
    }
    
    @ViewBuilder func BatteryLevelCard02() -> some View {
        HStack {
            Text("Battery Level 02:")
            Spacer()
            if model.isListening02 {
                Text(model.currentBatteryLevel?.formatted(.percent) ?? "--")
            } else {
                Text("Start listening")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            CardBackground()
        }
        .padding(.horizontal)
        .onTapGesture {
            model.fetchBatteryLevel02()
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
