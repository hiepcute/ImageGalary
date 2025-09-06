//
//  APIConstant.swift
//  CollectionView
//
//  Created by MACBOOK on 6/9/25.
//

import Foundation


struct APIEndPoint {
    static let baseURL = "https://picsum.photos"
    
    static func makeImageURL(imageSize: Int) -> String {
        return "\(baseURL)/\(imageSize)/\(imageSize)"
    }
}
