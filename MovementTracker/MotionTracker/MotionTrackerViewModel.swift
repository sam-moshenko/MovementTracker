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
    private let successfullMovementTime = 10
    private let disposeBag = DisposeBag()
    private let motionTracker: MotionTracker
    
    let statusText = PublishSubject<String>()
    private let movementSuccessfull = PublishSubject<Void>()
    private let movementStarted = PublishSubject<Void>()
    private let noMovement = PublishSubject<Void>()
    
    init(motionTracker: MotionTracker) {
        self.motionTracker = motionTracker
        setupMotionTracker()
        setupStatusText()
    }
    
    private func setupStatusText() {
        movementSuccessfull.map {
            "Энергия успешно потрачена."
            }.bind(to: statusText)
            .disposed(by: disposeBag)
        movementStarted.map {
            "Вы тратите энергию"
            }.bind(to: statusText)
            .disposed(by: disposeBag)
        noMovement.map {
            "Пожалуйста потратьте энергию"
            }.bind(to: statusText)
            .disposed(by: disposeBag)
    }
    
    private func setupMotionTracker() {
        motionTracker.trackMotion()
        Observable.combineLatest(motionTracker.motionSecondsObservable, motionTracker.noMotionSecondsObservable)
            .do(onNext: { [weak self] motionSeconds, noMotionSeconds in
                guard let self = self else { return }
                let isFactorOfSuccessfullMovementTime = motionSeconds % self.successfullMovementTime == 0
                if (isFactorOfSuccessfullMovementTime && motionSeconds != 0) {
                    self.movementSuccessfull.onNext(())
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
}
