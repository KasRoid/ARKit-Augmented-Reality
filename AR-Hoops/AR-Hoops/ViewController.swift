//
//  ViewController.swift
//  AR-Hoops
//
//  Created by Kas Song on 1/3/21.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var detectedLabel: UILabel!
    final private let configuration = ARWorldTrackingConfiguration()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setAR()
    }
}

// MARK: - Helpers
extension ViewController {
    final private func addBasket(raycastResult: ARRaycastResult) {
        let scene = SCNScene(named: "Basketball.scnassets/Basketball.scn")!
        let node = scene.rootNode.childNode(withName: "Basket", recursively: false)!
        node.position.x = raycastResult.worldTransform.columns.3.x
        node.position.y = raycastResult.worldTransform.columns.3.y
        node.position.z = raycastResult.worldTransform.columns.3.z
        sceneView.scene.rootNode.addChildNode(node)
    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneView)
        let raycastQuery = sceneView.raycastQuery(from: touchLocation,
                                                  allowing: .existingPlaneGeometry,
                                                  alignment: .horizontal)
        guard let query = raycastQuery else { return }
        let raycastResults = sceneView.session.raycast(query)
        guard let raycastReult = raycastResults.first else { return }
        addBasket(raycastResult: raycastReult)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.detectedLabel.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.detectedLabel.isHidden = true
        })
    }
}

// MARK: - AR
extension ViewController {
    final private func setAR() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        configuration.planeDetection = .horizontal
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        sceneView.automaticallyUpdatesLighting = true
        sceneView.delegate = self
        sceneView.session.run(configuration)
    }
}
