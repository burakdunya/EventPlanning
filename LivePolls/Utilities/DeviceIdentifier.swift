//
//  DeviceIdentifier.swift
//  LivePolls
//
//  Created by Efe Koç on 25.12.2024.
//

import UIKit

struct DeviceIdentifier {
    static var current: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
}
