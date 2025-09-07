//
//  CollectionViewGallaryViewModel.swift
//  CollectionView
//
//  Created by MACBOOK on 6/9/25.
//

import Foundation
import UIKit
import Combine

class CollectionViewGallaryViewModel {
    private(set) var images = CurrentValueSubject<[ImageModel], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    private let imageService: ImageServiceProtocol
    private let itemsPerPage = 70 // 7x10
    
    init(imageService: ImageServiceProtocol = ImageService.shared) {
        self.imageService = imageService
        loadInitialImages()
    }
    
    func loadInitialImages() {
        images.send((0..<itemsPerPage).map { _ in ImageModel() })
    }
    
    func addNewImage() {
        var current = images.value
        current.append(ImageModel())
        images.send(current)
    }
    
    
    func reloadAllImages() {
        imageService.resetCache()
        images.send((0..<140).map { _ in ImageModel() })
    }
    
    func loadImage(at indexPath: IndexPath) {
        var current = images.value
        guard indexPath.item < current.count else { return }
        
        let imageModel = current[indexPath.item]
        guard !imageModel.isLoading && imageModel.image == nil else { return }
        
        imageModel.isLoading = true
        current[indexPath.item] = imageModel  // update state
        images.send(current)
        Task {
            do {
                let image = try await imageService.fetchRandomImage(useCache: true)
                updateImageModel(at: indexPath.item, isLoading: false, image: image)
            } catch {
                updateImageModel(at: indexPath.item, isLoading: false, image: UIImage(systemName: "photo"))
            }
        }
    }
    
    private func updateImageModel(at index: Int, isLoading: Bool, image: UIImage?) {
        var current = images.value
        guard index < current.count else { return }
        let model = current[index]
        model.isLoading = isLoading
        model.image = image
        current[index] = model
        images.send(current)
    }
    
    func willDisplayItem(at indexPath: IndexPath) {
        let current = images.value
        let imageModel = current[indexPath.item]
        if imageModel.image == nil && !imageModel.isLoading {
            loadImage(at: indexPath)
        }
    }
    
}
