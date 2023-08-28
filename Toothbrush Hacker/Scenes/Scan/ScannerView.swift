//
//  ScannerView.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/26/23.
//

import SwiftUI

struct ScannerView: View {
    
    @StateObject var model = ScannerViewModel(
        scanner: BleDeviceManager.instance,
        connector: BleDeviceManager.instance
    )
    
    var body: some View {
        VStack {
            DeviceList()
            ScanButton()
        }
        .background(.gray)
    }
    
    @ViewBuilder func DeviceList() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(model.devices) { device in
                    DeviceItem(device)
                }
            }
        }
    }
    
    @ViewBuilder func DeviceItem(_ device: ScannedDevice) -> some View {
        Button {
            model.connect(device: device)
        } label: {
            Text(device.name)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
                .padding()
                .background {
                    Capsule(style: .continuous)
                        .fill(.white)
                }
                .padding(.horizontal)
        }
    }
    
    @ViewBuilder func ScanButton() -> some View {
        Button {
            model.toggleScan()
        } label: {
            Text(model.scanningState == .idle ? "Scan" : "Scanning...")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                .background {
                    Capsule(style: .continuous)
                        .fill(Color.accentColor)
                }
                .padding(.horizontal)
        }
        .padding(.top)
        .background {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.white)
                .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
