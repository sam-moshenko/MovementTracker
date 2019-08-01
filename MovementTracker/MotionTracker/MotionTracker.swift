//
//  MotionTracker.swift
//  MovementTracker
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import Foundation
import CoreMotion
import RxSwift

public class MotionTracker {
    public let motionSecondsObservable = PublishSubject<Int>()
    public let noMotionSecondsObservable = PublishSubject<Int>()
    private let minimumChange = 1.0
    private let manager = CMMotionManager()
    private var timer: Timer?
    
    public func trackMotion() {
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 1.0 / 60.0
            manager.showsDeviceMovementDisplay = true
            manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            
            var previousSum: Double? = nil
            var motionSeconds = 0
            var noMotionSeconds = 0
            // Configure a timer to fetch the motion data.
            timer = Timer(fire: Date(), interval: 1, repeats: true,
                               block: { [weak self] (timer) in
                                guard let self = self else { return }
                                
                                if let data = self.manager.deviceMotion {
                                    // Get the attitude relative to the magnetic north reference frame.
                                    let x = data.attitude.pitch
                                    let y = data.attitude.roll
                                    let z = data.attitude.yaw
                                    let sum = x + y + z
                                    if let previousSumUnwrapped = previousSum {
                                        let change = previousSumUnwrapped - sum
                                        if change > self.minimumChange {
                                            motionSeconds += 1
                                            previousSum = sum
                                        } else {
                                            previousSum = nil
                                            motionSeconds = 0
                                        }
                                        noMotionSeconds = 0
                                    } else {
                                        noMotionSeconds += 1
                                        motionSeconds = 0
                                    }
                                    self.continueMotion(motionSeconds, noMotionSeconds: noMotionSeconds)
                                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
        } else {
            debugPrint("Device motion is unavailable")
        }
    }
    
    private func continueMotion(_ motionSeconds: Int, noMotionSeconds: Int) {
        motionSecondsObservable.onNext(motionSeconds)
        noMotionSecondsObservable.onNext(noMotionSeconds)
    }
}
