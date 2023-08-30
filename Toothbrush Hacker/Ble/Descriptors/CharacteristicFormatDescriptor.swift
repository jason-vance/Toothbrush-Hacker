//
//  CharacteristicFormatDescriptor.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/27/23.
//

import Foundation
import CoreBluetooth

class CharacteristicFormatDescriptor: BleDescriptor {
    
    static let uuid = CBUUID(string: "2904")
    
    //TODO: Use these properties to format the charactertistic's value
    var format: Format = .reservedForFutureUse
    var exponent: Int8 = 0
    var unit: Unit = .unitless
    var namespace: Namespace = .unknown
    var description: Description = .description(0x0000)

    override init?(descriptor: CBDescriptor) {
        guard descriptor.uuid == Self.uuid else { return nil }
        super.init(descriptor: descriptor)
    }
    
    override func communicator(_ communicator: BleDeviceCommunicator, didUpdateValueFor cbDescriptor: CBDescriptor) {
        guard let data = cbDescriptor.value as? Data else { return }
        let byteArray = [UInt8](data)
        print("CharacteristicFormatDescriptor.didUpdateValueFor \(cbDescriptor)")
        
        pullOutProperties(byteArray)
    }
    
    private func pullOutProperties(_ byteArray: [UInt8]) {
        if let formatValue = byteArray.getValue(UInt8.self, at: 0) {
            format = Format.from(formatValue) ?? format
        }
        
        exponent = byteArray.getValue(Int8.self, at: 1) ?? exponent
        
        if let unitValue = byteArray.getValue(UInt16.self, at: 2) {
            unit = Unit.from(unitValue) ?? unit
        }
        
        if let namespaceValue = byteArray.getValue(UInt8.self, at: 4) {
            namespace = Namespace.from(namespaceValue)
        }
        
        description = .description(byteArray.getValue(UInt16.self, at: 5) ?? 0x0000)
    }
}

extension CharacteristicFormatDescriptor {
    enum Format: UInt8 {
        
        static func from(_ rawValue: UInt8) -> Format? {
            if let format = Format.init(rawValue: rawValue) {
                return format
            }
            print("Format not recognized: \([UInt8].from(rawValue).toString()))")
            return nil
        }
        
        case reservedForFutureUse = 0x00
//        <Enumeration key="1" value="Boolean" />
//        <Enumeration key="2" value="unsigned 2-bit integer" />
//        <Enumeration key="3" value="unsigned 4-bit integer" />
//        <Enumeration key="4" value="unsigned 8-bit integer" />
//        <Enumeration key="5" value="unsigned 12-bit integer" />
        case uint16 = 0x06
//        <Enumeration key="7" value="unsigned 24-bit integer" />
//        <Enumeration key="8" value="unsigned 32-bit integer" />
//        <Enumeration key="9" value="unsigned 48-bit integer" />
//        <Enumeration key="10" value="unsigned 64-bit integer" />
//        <Enumeration key="11" value="unsigned 128-bit integer" />
//        <Enumeration key="12" value="signed 8-bit integer" />
//        <Enumeration key="13" value="signed 12-bit integer" />
//        <Enumeration key="14" value="signed 16-bit integer" />
//        <Enumeration key="15" value="signed 24-bit integer" />
//        <Enumeration key="16" value="signed 32-bit integer" />
//        <Enumeration key="17" value="signed 48-bit integer" />
//        <Enumeration key="18" value="signed 64-bit integer" />
//        <Enumeration key="19" value="signed 128-bit integer" />
//        <Enumeration key="20"
//        value="IEEE-754 32-bit floating point" />
//        <Enumeration key="21"
//        value="IEEE-754 64-bit floating point" />
//        <Enumeration key="22" value="IEEE-11073 16-bit SFLOAT" />
//        <Enumeration key="23" value="IEEE-11073 32-bit FLOAT" />
//        <Enumeration key="24" value="IEEE-20601 format" />
//        <Enumeration key="25" value="UTF-8 string" />
//        <Enumeration key="26" value="UTF-16 string" />
//        <Enumeration key="27" value="Opaque Structure" />
//        <Reserved start="28" end="255"></Reserved>
    }
}

extension CharacteristicFormatDescriptor {
    enum Unit: UInt16 {
        
        static func from(_ rawValue: UInt16) -> Unit? {
            if let unit = Unit.init(rawValue: rawValue) {
                return unit
            }
            print("Unit not recognized: \([UInt8].from(rawValue).toString()))")
            return nil
        }
        
        case unitless = 0x2700
//        0x2701 length (metre)
//        0x2702 mass (kilogram)
//        0x2703 time (second)
//        0x2704 electric current (ampere)
//        0x2705 thermodynamic temperature (kelvin)
//        0x2706 amount of substance (mole)
//        0x2707 luminous intensity (candela)
//        0x2710 area (square metres)
//        0x2711 volume (cubic metres)
//        0x2712 velocity (metres per second)
//        0x2713 acceleration (metres per second squared)
//        0x2714 wavenumber (reciprocal metre)
//        0x2715 density (kilogram per cubic metre)
//        0x2716 surface density (kilogram per square metre)
//        0x2717 specific volume (cubic metre per kilogram)
//        0x2718 current density (ampere per square metre)
//        0x2719 magnetic field strength (ampere per metre)
//        0x271A amount concentration (mole per cubic metre)
//        0x271B mass concentration (kilogram per cubic metre)
//        0x271C luminance (candela per square metre)
//        0x271D refractive index
//        0x271E relative permeability
//        0x2720 plane angle (radian)
//        0x2721 solid angle (steradian)
//        0x2722 frequency (hertz)
//        0x2723 force (newton)
//        0x2724 pressure (pascal)
//        0x2725 energy (joule)
//        0x2726 power (watt)
//        0x2727 electric charge (coulomb)
        case electricPotentialDifference_Volt = 0x2728
//        0x2729 capacitance (farad)
//        0x272A electric resistance (ohm)
//        0x272B electric conductance (siemens)
//        0x272C magnetic flux (weber)
//        0x272D magnetic flux density (tesla)
//        0x272E inductance (henry)
//        0x272F Celsius temperature (degree Celsius)
//        0x2730 luminous flux (lumen)
//        0x2731 illuminance (lux)
//        0x2732 activity referred to a radionuclide (becquerel)
//        0x2733 absorbed dose (gray)
//        0x2734 dose equivalent (sievert)
//        0x2735 catalytic activity (katal)
//        0x2740 dynamic viscosity (pascal second)
//        0x2741 moment of force (newton metre)
//        0x2742 surface tension (newton per metre)
//        0x2743 angular velocity (radian per second)
//        0x2744 angular acceleration (radian per second squared)
//        0x2745 heat flux density (watt per square metre)
//        0x2746 heat capacity (joule per kelvin)
//        0x2747 specific heat capacity (joule per kilogram kelvin)
//        0x2748 specific energy (joule per kilogram)
//        0x2749 thermal conductivity (watt per metre kelvin)
//        0x274A energy density (joule per cubic metre)
//        0x274B electric field strength (volt per metre)
//        0x274C electric charge density (coulomb per cubic metre)
//        0x274D surface charge density (coulomb per square metre)
//        0x274E electric flux density (coulomb per square metre)
//        0x274F permittivity (farad per metre)
//        0x2750 permeability (henry per metre)
//        0x2751 molar energy (joule per mole)
//        0x2752 molar entropy (joule per mole kelvin)
//        0x2753 exposure (coulomb per kilogram)
//        0x2754 absorbed dose rate (gray per second)
//        0x2755 radiant intensity (watt per steradian)
//        0x2756 radiance (watt per square metre steradian)
//        0x2757 catalytic activity concentration (katal per cubic metre)
//        0x2760 time (minute)
//        0x2761 time (hour)
//        0x2762 time (day)
//        0x2763 plane angle (degree)
//        0x2764 plane angle (minute)
//        0x2765 plane angle (second)
//        0x2766 area (hectare)
//        0x2767 volume (litre)
//        0x2768 mass (tonne)
//        0x2780 pressure (bar)
//        0x2781 pressure (millimetre of mercury)
//        0x2782 length (ångström)
//        0x2783 length (nautical mile)
//        0x2784 area (barn)
//        0x2785 velocity (knot)
//        0x2786 logarithmic radio quantity (neper)
//        0x2787 logarithmic radio quantity (bel)
//        0x27A0 length (yard)
//        0x27A1 length (parsec)
//        0x27A2 length (inch)
//        0x27A3 length (foot)
//        0x27A4 length (mile)
//        0x27A5 pressure (pound-force per square inch)
//        0x27A6 velocity (kilometre per hour)
//        0x27A7 velocity (mile per hour)
//        0x27A8 angular velocity (revolution per minute)
//        0x27A9 energy (gram calorie)
//        0x27AA energy (kilogram calorie)
//        0x27AB energy (kilowatt hour)
//        0x27AC thermodynamic temperature (degree Fahrenheit)
//        0x27AD percentage
//        0x27AE per mille
//        0x27AF period (beats per minute)
//        0x27B0 electric charge (ampere hours)
//        0x27B1 mass density (milligram per decilitre)
//        0x27B2 mass density (millimole per litre)
//        0x27B3 time (year)
//        0x27B4 time (month)
//        0x27B5 concentration (count per cubic metre)
//        0x27B6 irradiance (watt per square metre)
//        0x27B7 milliliter (per kilogram per minute)
//        0x27B8 mass (pound)
//        0x27B9 metabolic equivalent
//        0x27BA step (per minute)
//        0x27BC stroke (per minute)
//        0x27BD pace (kilometre per minute)
//        0x27BE luminous efficacy (lumen per watt)
//        0x27BF luminous energy (lumen hour)
//        0x27C0 luminous exposure (lux hour)
//        0x27C1 mass flow (gram per second)
//        0x27C2 volume flow (litre per second)
//        0x27C3 sound pressure (decibel)
//        0x27C4 parts per million
//        0x27C5 parts per billion
//        0x27C6 mass density rate ((milligram per decilitre) per minute)
//        0x27C7 Electrical Apparent Energy (kilovolt ampere hour)
//        0x27C8 Electrical Apparent Power (volt ampere)
    }
}

extension CharacteristicFormatDescriptor {
    enum Namespace: UInt8 {
        
        static func from(_ rawValue: UInt8) -> Namespace {
            if let format = Namespace.init(rawValue: rawValue) {
                return format
            }
            print("Namespace not recognized: \([UInt8].from(rawValue).toString()))")
            return .unknown
        }
        
        case unknown = 0x00
        case bluetoothSigAssignedNumbers = 0x01
    }
}

extension CharacteristicFormatDescriptor {
    enum Description {
        case description(UInt16)
    }
}

