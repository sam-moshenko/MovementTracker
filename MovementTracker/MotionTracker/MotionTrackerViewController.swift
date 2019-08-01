//
//  MotionTrackerViewController.swift
//  MovementTracker
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MotionTrackerViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    let disposeBag = DisposeBag()
    let viewModel = MotionTrackerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.statusText.bind(to: statusLabel.rx.text).disposed(by: disposeBag)
    }

}
