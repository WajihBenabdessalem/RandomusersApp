//
//  NetworkMonitor.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/11/25.
//

import Network
import Combine

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = true
    private(set) var connectionType: ConnectionType = .unknown
    
    private var statusSubject = PassthroughSubject<Bool, Never>()
    var statusPublisher: AnyPublisher<Bool, Never> {
        return statusSubject.eraseToAnyPublisher()
    }
    
    enum ConnectionType {
        case wifi
        case cellular
        case wired
        case unknown
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            self.isConnected = path.status == .satisfied
            self.determineConnectionType(path)
            
            DispatchQueue.main.async {
                self.statusSubject.send(self.isConnected)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func determineConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wired
        } else {
            connectionType = .unknown
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
