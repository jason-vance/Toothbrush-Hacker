//
//  BleNotificationsRegistration.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 9/5/23.
//

import Foundation
import CoreBluetooth

public protocol NotificationsRegistration { }

internal class BleNotificationsRegistration: NotificationsRegistration {
    
    let onDeinit: () -> ()
    
    init(onDeinit: @escaping () -> ()) {
        self.onDeinit = onDeinit
    }
    
    deinit {
        onDeinit()
    }
}
