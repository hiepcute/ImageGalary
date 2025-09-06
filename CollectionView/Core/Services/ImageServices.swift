//
//  ImageServices.swift
//  CollectionView
//
//  Created by MACBOOK on 5/9/25.
//

import Foundation
import UIKit

class ImageService {
    static let shared = ImageService()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 200 // Cache up to 200 images
    }
    
    func resetCache() {
        cache = NSCache<NSString, UIImage>()
    }
    
    func fetchRandomImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let imageSize = 200
        let urlString = "https://picsum.photos/\(imageSize)/\(imageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Check cache first
        let cacheKey = NSString(string: url.absoluteString + "\(Int.random(in: 1...10000) )")
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(.success(cachedImage))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            // Cache the image
            self?.cache.setObject(image, forKey: cacheKey)
            completion(.success(image))
            
        }.resume()
    }
}
