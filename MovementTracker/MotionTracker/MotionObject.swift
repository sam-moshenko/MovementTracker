//
//  MotionObject.swift
//  MovementTracker
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import Foundation
import RealmSwift

class MotionObject: Object {
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var motionSeconds: Int = 0
}
