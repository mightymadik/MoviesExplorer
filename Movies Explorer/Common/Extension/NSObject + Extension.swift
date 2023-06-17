//
//  NSObject + Extension.swift
//  Movies Explorer
//
//  Created by MacBook on 15.06.2023.
//

import Foundation

extension NSObject {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
