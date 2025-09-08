//
//  CollectionViewGallaryViewControllerTests.swift
//  CollectionViewTests
//
//  Created by MACBOOK on 8/9/25.
//

import Foundation
import UIKit
import Combine
import XCTest
@testable import CollectionView
class CollectionViewGallaryViewControllerTests: XCTestCase {
    
    var sut: CollectionViewGallaryViewController!
    var mockViewModel: MockCollectionViewGallaryViewModel!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        let mockService = MockImageService()
        mockViewModel = MockCollectionViewGallaryViewModel(imageService: mockService)
        
        sut = CollectionViewGallaryViewController()
        sut.viewModel = mockViewModel
        sut.loadViewIfNeeded()
        sut.viewDidLoad()
        sut.view.layoutIfNeeded()
    }
    
    override func tearDown() {
        window = nil
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    
    func testViewDidLoad_SetsUpUI() {
        // Then
        XCTAssertNotNil(sut.view, "View should be loaded")
        XCTAssertEqual(sut.view.backgroundColor, .systemBackground, "Background color should be system background")
        XCTAssertEqual(sut.title, "Image Gallery", "Title should be set correctly")
    }
    
    func testViewDidLoad_SetsUpNavigationButtons() {
        
        // Then
        let rightBarButtonItems = sut.navigationItem.rightBarButtonItems
        XCTAssertNotNil(rightBarButtonItems, "Should have right bar button items")
        XCTAssertEqual(rightBarButtonItems?.count, 2, "Should have 2 right bar button items")
        
        // Check button titles
        let buttonTitles = rightBarButtonItems?.compactMap { $0.title } ?? []
        XCTAssertTrue(buttonTitles.contains("Reload All"), "Should have Reload All button")
        XCTAssertTrue(buttonTitles.contains("+"), "Should have + button")
    }
    
    
    func testViewDidLoad_BindsViewModel() {
        // Given
        let initialCount = getCollectionView()?.numberOfItems(inSection: 0) ?? 0
        
        // When
        mockViewModel.simulateImageUpdate()
        
        // Then
        // Wait for binding to take effect
        let expectation = expectation(description: "Collection view updated")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        let newCount = getCollectionView()?.numberOfItems(inSection: 0) ?? 0
        XCTAssertGreaterThan(newCount, initialCount, "Collection view should be updated when view model changes")
    }
    
    // MARK: - Button Action Tests
    
    func testAddButtonTapped_CallsAddNewImage() {
        // Given
        let addButton = findBarButtonItem(withTitle: "+")
        
        // When
        if let target = addButton?.target, let action = addButton?.action {
            _ = target.perform(action, with: addButton)
        }
        
        // Then
        XCTAssertEqual(mockViewModel.addNewImageCallCount, 1, "Should call addNewImage once")
    }
    
    func testReloadAllButtonTapped_CallsReloadAndScrollsToTop() {
        // Given
        let reloadButton = findBarButtonItem(withTitle: "Reload All")
        let collectionView = getCollectionView()
        
        // Set some offset to test scrolling
        collectionView?.setContentOffset(CGPoint(x: 100, y: 0), animated: false)
        
        // When
        if let target = reloadButton?.target, let action = reloadButton?.action {
            _ = target.perform(action, with: reloadButton)
        }
        
        // Then
        XCTAssertEqual(mockViewModel.reloadAllImagesCallCount, 1, "Should call reloadAllImages once")
        
        // Check if scrolled to top (with some tolerance for animation)
        let expectation = expectation(description: "Scrolled to top")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let currentOffset = collectionView?.contentOffset.x ?? 100
            XCTAssertLessThan(currentOffset, 10, "Should scroll to top")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: - Collection View DataSource Tests
    
    func testNumberOfItemsInSection_ReturnsViewModelCount() {
        // Given
        mockViewModel.simulateReloadWithCount(50)
        
        // When
        let count = sut.collectionView(getCollectionView()!, numberOfItemsInSection: 0)
        
        // Then
        XCTAssertEqual(count, 50, "Should return view model image count")
    }
    
    func testCellForItemAt_ConfiguresCell() {
        // Given
        mockViewModel.simulateReloadWithCount(10)
        let collectionView = getCollectionView()!
        let indexPath = IndexPath(item: 0, section: 0)
        
        // When
        let cell = sut.collectionView(collectionView, cellForItemAt: indexPath)
        
        // Then
        XCTAssertTrue(cell is ImageCollectionViewCell, "Should return ImageCollectionViewCell")
    }
    
    func testCellForItemAt_HandlesInvalidIndex() {
        // Given
        mockViewModel.simulateReloadWithCount(5)
        let collectionView = getCollectionView()!
        let invalidIndexPath = IndexPath(item: 10, section: 0) // Beyond array bounds
        
        // When
        let cell = sut.collectionView(collectionView, cellForItemAt: invalidIndexPath)
        
        // Then
        // Should return a basic UICollectionViewCell, not crash
        XCTAssertNotNil(cell, "Should not crash on invalid index")
    }
    
   
    
    func testInsetForSection_ReturnsZero() {
        // Given
        let collectionView = getCollectionView()!
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        // When
        let insets = sut.collectionView(collectionView, layout: layout, insetForSectionAt: 0)
        
        // Then
        XCTAssertEqual(insets, UIEdgeInsets.zero, "Insets should be zero")
    }
    
    // MARK: - Scroll View Delegate Tests
    
    func testScrollViewDidEndDecelerating_LoadsVisibleImages() {
        // Given
        mockViewModel.simulateReloadWithCount(70)
        let collectionView = getCollectionView()!
        
        // When
        sut.scrollViewDidEndDecelerating(collectionView)
        
        // Then
        XCTAssertGreaterThan(mockViewModel.loadImageCallCount, 0, "Should call loadImage for visible cells")
    }
    
    // MARK: - Memory Management Tests
    
    func testDeinit_ReleasesReferences() {
        // Given
        weak var weakSut: CollectionViewGallaryViewController?
        
        // When
        autoreleasepool {
            let viewController = CollectionViewGallaryViewController()
            weakSut = viewController
            
            // Load view to initialize everything
            viewController.loadViewIfNeeded()
            viewController.viewDidLoad()
        }
        
        // Then
        XCTAssertNil(weakSut, "View controller should be deallocated")
    }
    
    // MARK: - Integration Tests
    
    func testAddNewImage_InsertsItemInCollectionView() {
        // Given
        mockViewModel.simulateReloadWithCount(70)
        let collectionView = getCollectionView()!
        let initialCount = collectionView.numberOfItems(inSection: 0)
        
        // When
        sut.addButtonTapped()
        
        // Wait for UI update
        let expectation = expectation(description: "Collection view updated")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Then
        let newCount = collectionView.numberOfItems(inSection: 0)
        XCTAssertEqual(newCount, initialCount + 1, "Should insert one item")
        XCTAssertEqual(mockViewModel.loadImageCallCount, 71, "Should load image for new item")
    }
    
    func testReloadAll_UpdatesCollectionView() {
        // Given
        let collectionView = getCollectionView()!
        mockViewModel.simulateReloadWithCount(50) // Start with 50 items
        
        // When
        sut.reloadAllButtonTapped()
        
        // Simulate the reload with 140 items
        mockViewModel.simulateReloadWithCount(140)
        
        // Wait for UI update
        let expectation = expectation(description: "Collection view reloaded")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Then
        let count = collectionView.numberOfItems(inSection: 0)
        XCTAssertEqual(count, 140, "Should update to 140 items")
    }
    
    func testCollectionView_HandlesLargeDataSet() {
        // Given
        mockViewModel.simulateReloadWithCount(1000)
        let collectionView = getCollectionView()!
        
        // When
        let count = sut.collectionView(collectionView, numberOfItemsInSection: 0)
        
        // Then
        XCTAssertEqual(count, 1000, "Should handle large data set")
    }
    
    // MARK: - Helper Methods
    
    private func getCollectionView() -> UICollectionView? {
        return sut.collectionView
    }
    
    private func findBarButtonItem(withTitle title: String) -> UIBarButtonItem? {
        return sut.navigationItem.rightBarButtonItems?.first { $0.title == title }
    }
}
