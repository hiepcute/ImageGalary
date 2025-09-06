//
//  Array+Extenstion.swift
//  CollectionView
//
//  Created by MACBOOK on 6/9/25.
//

import Foundation
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
