//
//  MotionTrackerViewModel.swift
//  MovementTracker
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import Foundation
import RxSwift

internal class MotionTrackerViewModel {
    private let disposeBag = DisposeBag()
    private let motionTracker: MotionTracker
    
    let statusText = PublishSubject<String>()
    
    init(motionTracker: MotionTracker) {
        self.motionTracker = motionTracker
        setupStatusText()
        motionTracker.trackMotion()
    }
    
    private func setupStatusText() {
        motionTracker.movementSuccessfull.map {
            "Энергия успешно потрачена."
            }.bind(to: statusText)
            .disposed(by: disposeBag)
        motionTracker.movementStarted.map {
            "Вы тратите энергию"
            }.bind(to: statusText)
            .disposed(by: disposeBag)
        motionTracker.noMovement.map {
            "Пожалуйста потратьте энергию"
            }.bind(to: statusText)
            .disposed(by: disposeBag)
    }
}
