//
//  ViewController.swift
//  CollectionView
//
//  Created by MACBOOK on 5/9/25.
//

import UIKit

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var images: [ImageModel] = []
    private let itemsPerPage = 70 // 7x10
    private let columnsPerRow = 7
    private let rowsPerPage = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        loadInitialImages()
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
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
        
        navigationItem.rightBarButtonItems = [reloadButton]
        navigationItem.leftBarButtonItems = [addButton]
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
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
        reloadAllImages()
    }
    
    private func loadInitialImages() {
        for _ in 0..<70 {
            let imageModel = ImageModel()
            images.append(imageModel)
        }
        collectionView.reloadData()
        
        // Start loading images
        loadImagesForVisibleCells()
    }
    
    
    private func addNewImage() {
        let newImage = ImageModel()
        images.append(newImage)
        
        let indexPath = IndexPath(item: images.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        
        // Load the new image
        loadImage(for: newImage, at: indexPath)
    }
    private func reloadAllImages() {
        // Clear existing images
        images.removeAll()
        collectionView.reloadData()
        ImageService.shared.resetCache()
        
        // Add 140 new images
        for _ in 0..<140 {
            let imageModel = ImageModel()
            images.append(imageModel)
        }
        
        collectionView.reloadData()
        
        // Scroll to first page
        collectionView.setContentOffset(.zero, animated: true)
        
        // Load images for visible cells
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            self?.loadImagesForVisibleCells()
        }
    }
    
    private func loadImagesForVisibleCells() {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPaths {
            let imageModel = images[indexPath.item]
            loadImage(for: imageModel, at: indexPath)
        }
    }
    
    private func loadImage(for imageModel: ImageModel, at indexPath: IndexPath) {
        guard !imageModel.isLoading && imageModel.image == nil else { return }
        
        imageModel.isLoading = true
        print("index path \(indexPath)")
        // Update cell to show loading state
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            cell.showLoading()
        }
    
        ImageService.shared.fetchRandomImage { [weak self] result in
            DispatchQueue.main.async {
                imageModel.isLoading = false
                switch result {
                case .success(let image):
                    imageModel.image = image
                case .failure:
                    imageModel.image = UIImage(systemName: "photo")
                }
                
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
                    cell.configure(with: imageModel)
                }
            }
        }
    }
    
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        let imageModel = images[indexPath.item]
        cell.configure(with: imageModel)
        
        // Load image if not already loaded
        if imageModel.image == nil && !imageModel.isLoading {
            loadImage(for: imageModel, at: indexPath)
        }
        
        return cell
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
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
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForVisibleCells()
    }
}
