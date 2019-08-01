//
//  NasladdinRepository.swift
//  NasladdinApi
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

private enum Paths: String {
    case status = "energy/operationStatus"
}

public class NasladdinRepository: BaseRepository {
    override internal var baseUrl: String {
        get {
            return "https://betaapi.nasladdin.club/api/"
        }
    }
    
    public func setStatus(_ statusType: StatusType) -> Observable<DefaultDataResponse> {
        let statusModel = StatusModel(status: statusType)
        return request(Paths.status.rawValue, method: .put, object: statusModel)
    }
}
