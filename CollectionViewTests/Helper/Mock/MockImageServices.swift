//
//  MockImageServices.swift
//  CollectionViewTests
//
//  Created by MACBOOK on 7/9/25.
//

import Foundation
import XCTest
import Combine
import UIKit
@testable import CollectionView

class MockImageService: ImageServiceProtocol {
    var shouldReturnError = false
    var fetchCallCount = 0
    var resetCacheCallCount = 0
    var mockImage: UIImage?
    var delay: TimeInterval = 0
    
    init() {
        // Create a simple test image
        mockImage = createTestImage()
    }
    
    func fetchRandomImage(useCache: Bool) async throws -> UIImage {
        fetchCallCount += 1
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldReturnError {
            throw NetworkError.invalidData
        }
        
        return mockImage ?? UIImage()
    }
    
    func resetCache() {
        resetCacheCallCount += 1
    }
    
    private func createTestImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
