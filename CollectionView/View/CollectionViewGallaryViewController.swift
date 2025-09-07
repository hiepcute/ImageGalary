//
//  ViewController.swift
//  CollectionView
//
//  Created by MACBOOK on 5/9/25.
//

import UIKit
import Combine

class CollectionViewGallaryViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var images: [ImageModel] = []
    private let itemsPerPage = 70 // 7x10
    private let columnsPerRow = 7
    private let rowsPerPage = 10
    private var viewModel = CollectionViewGallaryViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        bindViewModel()
    }
    
    private func setupNavBar() {
        view.backgroundColor = .systemBackground
        title = "Image Gallery"
        
        // Setup navigation bar buttons
        let addButton = UIBarButtonItem(
            title: "+",
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 24)], for: .normal)
        
        let reloadButton = UIBarButtonItem(
            title: "Reload All",
            style: .plain,
            target: self,
            action: #selector(reloadAllButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [reloadButton ,addButton]
    }
    
    private func bindViewModel() {
        viewModel.images
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        // Register cell
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
            view.addSubview(collectionView)
        setupConstraint()
      
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func addButtonTapped() {
        addNewImage()
    }
    
    @objc private func reloadAllButtonTapped() {
        viewModel.reloadAllImages()
        collectionView.setContentOffset(.zero, animated: true)
    }
    

    private func addNewImage() {
        viewModel.addNewImage()
        let indexPath = IndexPath(item: viewModel.images.value.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        viewModel.loadImage(at: indexPath)
    }
    
    
    private func loadImagesForVisibleCells() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPaths {
            viewModel.loadImage(at: indexPath)
        }
    }
    
}

extension CollectionViewGallaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let imageModel = viewModel.images.value[safe: indexPath.item] else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.willDisplayItem(at: indexPath)
    }
}


extension CollectionViewGallaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width
        let spacingBetweenItems: CGFloat = 2
        let totalSpacing = spacingBetweenItems * CGFloat(columnsPerRow - 1)
        let itemWidth = (availableWidth - totalSpacing) / CGFloat(columnsPerRow)
        
        let availableHeight = collectionView.frame.height
        let totalVerticalSpacing = spacingBetweenItems * CGFloat(rowsPerPage - 1)
        let itemHeight = (availableHeight - totalVerticalSpacing) / CGFloat(rowsPerPage)
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
}

// MARK: - UIScrollViewDelegate
extension CollectionViewGallaryViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForVisibleCells()
    }
}
