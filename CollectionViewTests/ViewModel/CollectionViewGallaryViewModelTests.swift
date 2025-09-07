//
//  CollectionViewGallaryViewModelTests.swift
//  CollectionViewTests
//
//  Created by MACBOOK on 7/9/25.
//

import Foundation
import UIKit
import Combine
import XCTest
@testable import CollectionView

class CollectionViewGallaryViewModelTests: XCTestCase {
    
    var sut: CollectionViewGallaryViewModel!
    var mockImageService: MockImageService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockImageService = MockImageService()
        sut = CollectionViewGallaryViewModel(imageService: mockImageService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        mockImageService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization_LoadsInitialImages() {
        // Given & When - initialization happens in setUp
        
        // Then
        let images = sut.images.value
        XCTAssertEqual(images.count, 70, "Should load 70 initial images")
        
        // Verify all images are empty initially
        for image in images {
            XCTAssertNil(image.image, "Initial images should be nil")
            XCTAssertFalse(image.isLoading, "Initial images should not be loading")
        }
    }
    
    func testInitialization_UsesProvidedImageService() {
        // Given
        let customMockService = MockImageService()
        
        // When
        let viewModel = CollectionViewGallaryViewModel(imageService: customMockService)
        
        // Then
        XCTAssertEqual(viewModel.images.value.count, 70)
    }
    
    // MARK: - Load Initial Images Tests
    
    func testLoadInitialImages_CreatesCorrectNumberOfImages() {
        // Given
        let expectation = expectation(description: "Images updated")
        var receivedImages: [ImageModel] = []
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                receivedImages = images
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.loadInitialImages()
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedImages.count, 70)
    }
    
    // MARK: - Add New Image Tests
    
    func testAddNewImage_IncreasesImageCount() {
        // Given
        let initialCount = sut.images.value.count
        let expectation = expectation(description: "Image added")
        var finalCount = 0
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                finalCount = images.count
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.addNewImage()
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(finalCount, initialCount + 1, "Should add one image")
    }
    
    func testAddNewImage_AddsEmptyImageModel() {
        // Given
        let expectation = expectation(description: "Image added")
        var newImages: [ImageModel] = []
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                newImages = images
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.addNewImage()
        
        // Then
        waitForExpectations(timeout: 1.0)
        let lastImage = newImages.last!
        XCTAssertNil(lastImage.image, "New image should be nil")
        XCTAssertFalse(lastImage.isLoading, "New image should not be loading")
    }
    
    // MARK: - Reload All Images Tests
    
    func testReloadAllImages_ResetsCache() {
        // When
        sut.reloadAllImages()
        
        // Then
        XCTAssertEqual(mockImageService.resetCacheCallCount, 1, "Should reset cache once")
    }
    
    func testReloadAllImages_Creates140Images() {
        // Given
        let expectation = expectation(description: "Images reloaded")
        var reloadedImages: [ImageModel] = []
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                reloadedImages = images
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.reloadAllImages()
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(reloadedImages.count, 140, "Should create 140 images after reload")
    }
    
    func testReloadAllImages_CreatesEmptyImages() {
        // Given
        let expectation = expectation(description: "Images reloaded")
        var reloadedImages: [ImageModel] = []
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                reloadedImages = images
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.reloadAllImages()
        
        // Then
        waitForExpectations(timeout: 1.0)
        for image in reloadedImages {
            XCTAssertNil(image.image, "Reloaded images should be nil")
            XCTAssertFalse(image.isLoading, "Reloaded images should not be loading")
        }
    }
    
    // MARK: - Load Image Tests
    
    func testLoadImage_ValidIndexPath_StartsLoading() async {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let expectation = expectation(description: "Loading started")
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                if let firstImage = images.first, firstImage.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.loadImage(at: indexPath)
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testLoadImage_SuccessfulFetch_UpdatesImageModel() async {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let expectation = expectation(description: "Image loaded successfully")
        expectation.expectedFulfillmentCount = 2 // Loading + Loaded
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.loadImage(at: indexPath)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        let finalImages = sut.images.value
        let loadedImage = finalImages[0]
        XCTAssertNotNil(loadedImage.image, "Image should be loaded")
        XCTAssertFalse(loadedImage.isLoading, "Should not be loading after completion")
        XCTAssertEqual(mockImageService.fetchCallCount, 1, "Should call fetch once")
    }
    
    func testLoadImage_FailedFetch_SetsDefaultImage() async {
        // Given
        mockImageService.shouldReturnError = true
        let indexPath = IndexPath(item: 0, section: 0)
        let expectation = expectation(description: "Image load failed")
        expectation.expectedFulfillmentCount = 2 // Loading + Error
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.loadImage(at: indexPath)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        let finalImages = sut.images.value
        let errorImage = finalImages[0]
        XCTAssertNotNil(errorImage.image, "Should have default image on error")
        XCTAssertFalse(errorImage.isLoading, "Should not be loading after error")
    }
    
    func testLoadImage_InvalidIndexPath_DoesNothing() {
        // Given
        let invalidIndexPath = IndexPath(item: 999, section: 0)
        let initialFetchCount = mockImageService.fetchCallCount
        
        // When
        sut.loadImage(at: invalidIndexPath)
        
        // Then
        XCTAssertEqual(mockImageService.fetchCallCount, initialFetchCount, "Should not call fetch for invalid index")
    }
    
    
    func testLoadImage_AlreadyLoaded_DoesNotReload() {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let currentImages = sut.images.value
        currentImages[0].image = UIImage() // Set image as already loaded
        sut.images.send(currentImages)
        
        // When
        sut.loadImage(at: indexPath)
        
        // Then
        XCTAssertEqual(mockImageService.fetchCallCount, 0, "Should not fetch if image already loaded")
    }
    
    // MARK: - Will Display Item Tests
    
    func testWillDisplayItem_ImageNilAndNotLoading_LoadsImage() async {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let expectation = expectation(description: "Image starts loading")
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                if let firstImage = images.first, firstImage.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.willDisplayItem(at: indexPath)
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(mockImageService.fetchCallCount, 1)
    }
    
    func testWillDisplayItem_ImageAlreadyLoaded_DoesNotLoad() {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let currentImages = sut.images.value
        currentImages[0].image = UIImage() // Already loaded
        sut.images.send(currentImages)
        
        // When
        sut.willDisplayItem(at: indexPath)
        
        // Then
        XCTAssertEqual(mockImageService.fetchCallCount, 0, "Should not load if already loaded")
    }
    
    func testWillDisplayItem_ImageLoading_DoesNotLoad() {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let currentImages = sut.images.value
        currentImages[0].isLoading = true // Already loading
        sut.images.send(currentImages)
        
        // When
        sut.willDisplayItem(at: indexPath)
        
        // Then
        XCTAssertEqual(mockImageService.fetchCallCount, 0, "Should not load if already loading")
    }
    
    // MARK: - Combine Integration Tests
    
    func testImagesSubject_PublishesChanges() {
        // Given
        let expectation = expectation(description: "Images published")
        var receivedImages: [ImageModel] = []
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                receivedImages = images
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.addNewImage()
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedImages.count, 71) // 70 initial + 1 new
    }
    

    
    func testMultipleReloadCalls_HandlesCorrectly() {
        // Given
        let expectation = expectation(description: "Multiple reloads handled")
        var callCount = 0
        
        sut.images
            .dropFirst() // Skip initial value
            .sink { images in
                callCount += 1
                if callCount == 3 { // 3 reload calls
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.reloadAllImages()
        sut.reloadAllImages()
        sut.reloadAllImages()
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockImageService.resetCacheCallCount, 3)
        XCTAssertEqual(sut.images.value.count, 140)
    }
    
}
