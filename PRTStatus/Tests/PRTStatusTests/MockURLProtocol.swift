//
//  MockURL.swift
//  PRTStatus
//
//  Created by Kaitlyn Landmesser on 12/6/24.
//

import Foundation

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var error: Error?
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let handler = MockURLProtocol.requestHandler else {
            assertionFailure("Received unexpected request with no handler set")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // TODO: Andd stop loading here
    }
}
