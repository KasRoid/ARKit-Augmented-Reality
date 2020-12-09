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
    var selectedItem: String?
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
        registerGestureRecognizer()
    }
}

// MARK: - Helpers
extension ViewController {
    func registerGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    func addItem(raycastResult: ARRaycastResult) {
        if let selectedItem = selectedItem {
            print(selectedItem)
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false) ?? SCNNode()
            let transform = raycastResult.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
//    func addItem(hitTestResult: ARHitTestResult) {
//        if let selectedItem = selectedItem {
//            print(selectedItem)
//            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
//            let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false) ?? SCNNode()
//            let transform = hitTestResult.worldTransform
//            let thirdColumn = transform.columns.3
//            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
//            sceneView.scene.rootNode.addChildNode(node)
//        }
//    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    private func tapped(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: sceneView)
//        let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
//        if !hitTest.isEmpty {
//            self.addItem(hitTestResult: hitTest.first!)
//        } else {
//            print("HitTest Failed")
//        }
        let raycast = sceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
        if let raycast = raycast {
            let raycastResult = sceneView.session.raycast(raycast)
            self.addItem(raycastResult: raycastResult.first!)
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = itemsArray[indexPath.item]
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
        configuration.planeDetection = .horizontal
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
