//
//  ScannerView.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/26/23.
//

import SwiftUI
import CoreBluetooth

struct ScannerView: View {
    
    var onDeviceSelected: (DiscoveredPeripheral) -> Void
    
    @StateObject var model = ScannerViewModel(
        scanner: BleCentralManager.instance
    )
    
    var body: some View {
        VStack {
            DeviceList()
            ScanButton()
        }
        .background(.gray)
        .alert(model.alertMessage, isPresented: $model.showAlert) {}
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
    
    @ViewBuilder func DeviceItem(_ device: DiscoveredPeripheral) -> some View {
        Button {
            model.toggleScan()
            onDeviceSelected(device)
        } label: {
            Text(device.peripheral.name ?? "<<Unnamed Device>>")
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
        ScannerView(
            onDeviceSelected: { _ in }
        )
    }
}
