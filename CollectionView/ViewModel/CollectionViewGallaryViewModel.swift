//
//  CollectionViewGallaryViewModel.swift
//  CollectionView
//
//  Created by MACBOOK on 6/9/25.
//

import Foundation
import UIKit
import Combine

class ImageViewModel {
    @Published private(set) var images: [ImageModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let itemsPerPage = 70 // 7x10
    
    init() {
        loadInitialImages()
    }
    
    func loadInitialImages() {
        images = (0..<itemsPerPage).map { _ in ImageModel() }
    }
    
    func addNewImage() {
        images.append(ImageModel())
    }
    
    func reloadAllImages() {
        ImageService.shared.resetCache()
        images = (0..<140).map { _ in ImageModel() }
    }
    
    func loadImage(for indexPath: IndexPath) {
        guard indexPath.item < images.count else { return }
        
        let imageModel = images[indexPath.item]
        guard !imageModel.isLoading && imageModel.image == nil else { return }
        
        imageModel.isLoading = true
        images[indexPath.item] = imageModel  // update state
        
        Task {
            do {
                let image = try await ImageService.shared.fetchRandomImage()
                updateImageModel(at: indexPath.item, isLoading: false, image: image)
            } catch {
                updateImageModel(at: indexPath.item, isLoading: false, image: UIImage(systemName: "photo"))

            }
        }

    }
    
    private func updateImageModel(at index: Int, isLoading: Bool, image: UIImage?) {
        guard index < images.count else { return }
        let model = images[index]
        model.isLoading = isLoading
        model.image = image
        images[index] = model
    }
    
    func willDisplayItem(at indexPath: IndexPath) {
        let imageModel = images[indexPath.item]
        if imageModel.image == nil && !imageModel.isLoading {
            loadImage(for: indexPath)
        }
    }
}
