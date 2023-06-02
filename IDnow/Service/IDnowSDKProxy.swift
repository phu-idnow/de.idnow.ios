//
//  IDnowSDKProxy.swift
//  IDnow
//
//  Created by Phu Nguyen on 6/2/23.
//

import Foundation
import IDnowSDK
import Combine

final class IDnowSDKProxy: NSObject, IDnowControllerDelegate {
    let controller: IDnowController!
    private let token: String
    
    // Subjects
    private let initializationSubject: PassthroughSubject<Bool, Error>
    private let identificationSubject: PassthroughSubject<Bool, Error>
    private let identificationCancelledSubject: PassthroughSubject<Bool, Error>
    
    // Publishers
    var initializationPublisher: AnyPublisher<Bool, Error> {
        initializationSubject.eraseToAnyPublisher()
    }
    var identificationCancelledPublisher: AnyPublisher<Bool, Error> {
        identificationCancelledSubject.eraseToAnyPublisher()
    }
    var identificationPublisher: AnyPublisher<Bool, Error> {
        identificationSubject.eraseToAnyPublisher()
    }
    
    
    init(_ token: String) {
        self.token = token
        IDnowSettings.instance.transactionToken = token
        IDnowSettings.instance.ignoreCompanyID = true
        controller = IDnowController(settings: IDnowSettings.instance)
        initializationSubject = PassthroughSubject()
        identificationSubject = PassthroughSubject()
        identificationCancelledSubject = PassthroughSubject()
        super.init()
        controller.delegate = self
    }
    
    // MARK: - Initialization
    func idnowControllerDidFinishInitializing(_ idnowController: IDnowController) {
        initializationSubject.send(true)
    }
    
    func idnowController(_ idnowController: IDnowController, initializationDidFailWithError error: Error) {
        initializationSubject.send(completion: .failure(error))
    }
    
    // MARK: - Identification
    func idnowControllerDidFinishIdentification(_ idnowController: IDnowController) {
        identificationSubject.send(true)
    }
    
    func idnowController(_ idnowController: IDnowController, identificationDidFailWithError error: Error) {
        identificationSubject.send(completion: .failure(error))
    }
    
    func idnowControllerCanceled(byUser idnowController: IDnowController) {
        identificationCancelledSubject.send(true)
    }
}
