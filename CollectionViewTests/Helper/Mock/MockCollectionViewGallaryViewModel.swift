//
//  MockCollectionViewGallaryViewModel.swift
//  CollectionViewTests
//
//  Created by MACBOOK on 8/9/25.
//

import Foundation
import XCTest
import Combine
import UIKit
@testable import CollectionView

class MockCollectionViewGallaryViewModel: CollectionViewGallaryViewModel {
    
    var loadImageCallCount = 0
    var loadImageCalledWithIndexPaths: [IndexPath] = []
    var reloadAllImagesCallCount = 0
    var addNewImageCallCount = 0
    var willDisplayItemCallCount = 0
    var willDisplayItemCalledWithIndexPaths: [IndexPath] = []
    
    // Override to track calls
    override func loadImage(at indexPath: IndexPath) {
        loadImageCallCount += 1
        loadImageCalledWithIndexPaths.append(indexPath)
        super.loadImage(at: indexPath)
    }
    
    override func reloadAllImages() {
        reloadAllImagesCallCount += 1
        super.reloadAllImages()
    }
    
    override func addNewImage() {
        addNewImageCallCount += 1
        super.addNewImage()
    }
    
    override func willDisplayItem(at indexPath: IndexPath) {
        willDisplayItemCallCount += 1
        willDisplayItemCalledWithIndexPaths.append(indexPath)
        super.willDisplayItem(at: indexPath)
    }
    
    // Helper method to simulate image updates
    func simulateImageUpdate() {
        var current = images.value
        current.append(ImageModel())
        images.send(current)
    }
    
    func simulateReloadWithCount(_ count: Int) {
        let newImages = (0..<count).map { _ in ImageModel() }
        images.send(newImages)
    }
}
