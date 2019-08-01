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
import RealmSwift

public class MotionTracker {
    private let disposeBag = DisposeBag()
    
    private let successfullMovementTime = 10
    private let minimumChange = 1.0
    private let manager = CMMotionManager()
    private let realm = try! Realm()
    private var timer: Timer?
    
    private let motionSecondsObservable = PublishSubject<Int>()
    private let noMotionSecondsObservable = PublishSubject<Int>()
    
    public let movementSuccessfull = PublishSubject<Void>()
    public let movementStarted = PublishSubject<Void>()
    public let noMovement = PublishSubject<Void>()
    
    init() {
        setupMotionTracker()
    }
    
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
    
    private func setupMotionTracker() {
        Observable.combineLatest(motionSecondsObservable, noMotionSecondsObservable)
            .do(onNext: { [weak self] motionSeconds, noMotionSeconds in
                guard let self = self else { return }
                let isFactorOfSuccessfullMovementTime = motionSeconds % self.successfullMovementTime == 0
                if (isFactorOfSuccessfullMovementTime && motionSeconds != 0) {
                    self.movementSuccessfull.onNext(())
                    self.saveMotion(motionSeconds: motionSeconds)
                }
            })
            .do(onNext: { [weak self] motionSeconds, noMotionSeconds in
                guard let self = self else { return }
                if (motionSeconds > 0) {
                    self.movementStarted.onNext(())
                }
            })
            .do(onNext: { [weak self] motionSeconds, noMotionSeconds in
                guard let self = self else { return }
                if (motionSeconds == 0 && noMotionSeconds >= 5) {
                    self.noMovement.onNext(())
                }
            })
            .subscribe().disposed(by: disposeBag)
    }
    
    private func saveMotion(motionSeconds: Int) {
        let motion = MotionObject()
        motion.motionSeconds = motionSeconds
        realm.add(motion)
    }
}
