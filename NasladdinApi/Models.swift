//
//  Models.swift
//  NasladdinApi
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import Foundation

public enum StatusType: Int, Codable {
    case success = 0,
    failed = 1
}

internal struct StatusModel: Codable {
    let status: StatusType
    
    init(status: StatusType) {
        self.status = status
    }
}
