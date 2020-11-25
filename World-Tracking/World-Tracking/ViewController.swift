//
//  ViewController.swift
//  World-Tracking
//
//  Created by Kas Song on 11/24/20.
//

import ARKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let sceneView = ARSCNView()
    private let configuration = ARWorldTrackingConfiguration()
    private let addButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupUI()
    }
    
    // MARK: - Selectors
    @objc
    private func handleButtons(_ sender: UIButton) {
        switch sender {
        case addButton:
            let node = SCNNode()
            node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03)
            node.geometry?.firstMaterial?.specular.contents = UIColor.white
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
            let x = randomNumbers(firstNum: -0.3, secondNum: 0.3)
            let y = randomNumbers(firstNum: -0.3, secondNum: 0.3)
            let z = randomNumbers(firstNum: -0.3, secondNum: -0.6)
            node.position = SCNVector3(x, y, z)
            sceneView.scene.rootNode.addChildNode(node)
        case removeButton:
            sceneView.session.pause()
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        default:
            break
        }
    }
    
    // MARK: - Helpers
    private func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

extension ViewController {
    private func setupSceneView() {
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
    }
    
    private func setupUI() {
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        addButton.setTitle("Add", for: .normal)
        addButton.addTarget(self, action: #selector(handleButtons(_:)), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
        removeButton.setTitle("Remove", for: .normal)
        removeButton.addTarget(self, action: #selector(handleButtons(_:)), for: .touchUpInside)
        view.addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            removeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
    }
}
