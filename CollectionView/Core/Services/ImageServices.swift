//
//  ImageServices.swift
//  CollectionView
//
//  Created by MACBOOK on 5/9/25.
//

import Foundation
import UIKit

protocol ImageServiceProtocol {
    func fetchRandomImage(useCache: Bool) async throws -> UIImage
    func resetCache()
}

class ImageService: ImageServiceProtocol{
    static let shared = ImageService()
    private var cache = NSCache<NSString, UIImage>()
    private var services = NetworkService(session: URLSession.shared)
    
    private init() {
        cache.countLimit = 200 // Cache up to 200 images
    }
    
    func resetCache() {
        cache = NSCache<NSString, UIImage>()
    }
    
    func fetchRandomImage(useCache: Bool = true) async throws -> UIImage {
        let imageSize = 200
        let urlString = APIEndPoint.makeImageURL(imageSize: imageSize)
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // Check cache first
        let cacheKey = NSString(string: url.absoluteString + "\(Int.random(in: 1...10000) )")
        if useCache {
            if let cachedImage = cache.object(forKey: cacheKey) {
                return cachedImage
            }
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidData
        }
        
        // Cache the image
        cache.setObject(image, forKey: cacheKey)
        
        return image
    }
}
