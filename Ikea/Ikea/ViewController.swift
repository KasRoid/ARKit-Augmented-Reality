//
//  ViewController.swift
//  Ikea
//
//  Created by Kas Song on 12/8/20.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    let itemsArray = ["cup", "vase", "boxing", "table"]
    let flowLayout = UICollectionViewFlowLayout()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    let sceneView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupAR()
        setupUI()
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as? ItemCollectionViewCell else { fatalError() }
        cell.label.text = itemsArray[indexPath.item]
        return cell
    }
}

// MARK: - UI
extension ViewController {
    private func setupCollectionView() {
        collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 30
        flowLayout.minimumLineSpacing = 30
        flowLayout.itemSize = CGSize(width: 120, height: 50)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    private func setupAR() {
        sceneView.session.run(configuration)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        // Layout
        [sceneView, collectionView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
}
