//
//  ViewModel.swift
//  IDnow
//
//  Created by Phu Nguyen on 6/2/23.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    @Published var tokenField: String = ""
    @Published var identFinishedSuccess: Bool = false
    @Published var identFinishedFailed = false
    @Published var errorMessage: String = ""
    
    private var cancellableSet: Set<AnyCancellable> = []
    private let bgScheduler = DispatchQueue(label: "de.idnow.de.background.service")
    private let validationSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private let identificationFailedSubject = PassthroughSubject<String, Never>()
    private let identificationFinishedSubject = PassthroughSubject<Bool, Never>()
    
    var buttonEnabled: AnyPublisher<Bool, Never> {
        validationSubject.eraseToAnyPublisher()
    }
    
    private var idnowService: IDnowSDKProxy?

    init() {
        let validation = $tokenField.throttle(for: 0.5, scheduler: bgScheduler, latest: true)
            .removeDuplicates()
            .map { $0.count > 5 }
            .eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink { valid in
                self.validationSubject.send( valid )
            }
        validation.store(in: &cancellableSet)
    }
    
    func finish() {
        validationSubject.send(true)
        identificationFailedSubject.send("")
        idnowService = nil
    }
    
    func start() {
        validationSubject.send(false)
        idnowService = IDnowSDKProxy( tokenField )
        idnowService?.controller.initialize()
        idnowService?.initializationPublisher
            .print("[initializationPublisher]")
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.identificationFailedSubject.send(error.localizedDescription)
                    self.validationSubject.send(true)
                default:
                    break
                }
            }, receiveValue: { success in
                success ? self.idnowService?.controller.startIdentification(from: ViewUtils.rootController()) :
                self.identificationFailedSubject.send("Initialized identification failed")
                if (!success) {
                    self.validationSubject.send(true)
                }
            })
            .store(in: &cancellableSet)
        idnowService?.identificationPublisher
            .print("[identificationPublisher]")
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.identificationFailedSubject.send(error.localizedDescription)
                }
                self.validationSubject.send(true)
            }, receiveValue: { success in
                self.identificationFinishedSubject.send(success)
            })
            .store(in: &cancellableSet)
        
        idnowService?.identificationCancelledPublisher
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                print("[receiveCompletion]")
            }, receiveValue: { cancelled in
                self.identificationFailedSubject.send("Ident has cancelled by user")
            })
            .store(in: &cancellableSet)
        
        //
        identificationFailedSubject.map { !$0.isEmpty }
            .receive(on: RunLoop.main)
            .assign(to: \.identFinishedFailed, on: self)
            .store(in: &cancellableSet)
        identificationFinishedSubject
            .receive(on: RunLoop.main)
            .assign(to: \.identFinishedSuccess, on: self)
            .store(in: &cancellableSet)
        identificationFailedSubject
            .receive(on: RunLoop.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellableSet)
    }
}
