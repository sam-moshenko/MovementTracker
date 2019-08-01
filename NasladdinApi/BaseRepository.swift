//
//  BaseRepository.swift
//  NasladdinApi
//
//  Created by Simon Lebedev on 8/1/19.
//  Copyright © 2019 Simon Lebedev. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

// Abstract class, override baseUrl field
public class BaseRepository {
    internal var baseUrl: String {
        get {
            fatalError("Abstract Field")
        }
    }
    private let sessionManager: SessionManager
    private let dictionaryEncoder = DictionaryEncoder()
    
    public init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    public func request<T: Encodable>(_ path: String, method: HTTPMethod, object: T) -> Observable<DefaultDataResponse> {
        let dictionary = try! dictionaryEncoder.encode(object) as! [String: Any]
        return Observable.create { [weak self] (observer) -> Disposable in
            if let self = self {
                self.sessionManager
                    .request(URL(string: self.baseUrl + path)!, method: .put, parameters: dictionary, encoding: JSONEncoding.default, headers: nil)
                    .response(completionHandler: { (response) in
                    observer.onNext(response)
                })
            }
            return Disposables.create()
        }
    }
}
