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
    let detectionLabel = UILabel()
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
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressGesture.minimumPressDuration = 0.1
        sceneView.addGestureRecognizer(longPressGesture)
    }
    
    func addItem(raycastResult: ARRaycastResult) {
        if let selectedItem = selectedItem {
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            let node = scene?.rootNode.childNode(withName: selectedItem, recursively: false) ?? SCNNode()
            let transform = raycastResult.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            if selectedItem == "table" {
                self.centerPivot(for: node)
            }
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x) / 2,
            min.y + (max.y - min.y) / 2,
            min.z + (max.z - min.z) / 2
        )
    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    private func tapped(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: sceneView)
        let raycast = sceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
        if let raycast = raycast {
            guard let raycastResult = sceneView.session.raycast(raycast).first else { return }
            self.addItem(raycastResult: raycastResult)
        }
    }
    
    @objc
    func pinch(_ sender: UIPinchGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(location)
        if !hitTest.isEmpty {
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc
    func longPress(_ sender: UILongPressGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(location)
        guard let result = hitTest.first else { return }
        let node = result.node
        if sender.state == .began {
            let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
            let forever = SCNAction.repeatForever(rotation)
            node.runAction(forever)
        } else if sender.state == .ended {
            node.removeAllActions()
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { print("Guard"); return }
        DispatchQueue.main.async {
            self.detectionLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.detectionLabel.isHidden = true
            })
        }
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
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.session.run(configuration)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        detectionLabel.text = "Plane Detected"
        detectionLabel.textColor = .green
        detectionLabel.font = UIFont.systemFont(ofSize: 20)
        detectionLabel.isHidden = true
        
        collectionView.backgroundColor = .white
        
        // Layout
        [sceneView, detectionLabel, collectionView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            
            detectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
    }

//extension ViewController {
//    @objc
//    private func tapped(_ sender: UITapGestureRecognizer) {
//        guard let sceneView = sender.view as? ARSCNView else { return }
//        let location = sender.location(in: sceneView)
//        let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
//        if !hitTest.isEmpty {
//            self.addItem(hitTestResult: hitTest.first!)
//        } else {
//            print("HitTest Failed")
//        }
//    }
//
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
//}
