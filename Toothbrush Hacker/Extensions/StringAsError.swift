//
//  StringAsError.swift
//  Toothbrush Hacker
//
//  Created by Jason Vance on 8/28/23.
//

import Foundation

extension String: Error {}
extension String: LocalizedError {
    public var errorDescription: String? { self }
}
