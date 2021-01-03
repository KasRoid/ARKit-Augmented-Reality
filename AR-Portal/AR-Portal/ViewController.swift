//
//  ViewController.swift
//  AR-Portal
//
//  Created by Kas Song on 12/20/20.
//

import ARKit
import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    final private let sceneView = ARSCNView()
    final private let detectionLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setAR()
        setUI()
    }
}

// MARK: - Helpers
extension ViewController {
    func showDetectionLabel() {
        DispatchQueue.main.async { self.detectionLabel.isHidden = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3,
                                      execute: { self.detectionLabel.isHidden = true })
    }
    
    func addPortal(raycastResult: ARRaycastResult) {
        let portalScene = SCNScene(named: "portal.scnassets/Portal.scn")!
        let portalNode = portalScene.rootNode.childNode(withName: "Portal", recursively: false)!
        let transform = raycastResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        portalNode.position = SCNVector3(planeXposition, planeYposition, planeZposition)
        addPlane(nodeName: "roof", portalNode: portalNode, imageName: "top")
        addPlane(nodeName: "floor", portalNode: portalNode, imageName: "bottom")
        addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "back")
        addWalls(nodeName: "sideWallA", portalNode: portalNode, imageName: "sideA")
        addWalls(nodeName: "sideWallB", portalNode: portalNode, imageName: "sideB")
        addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "sideDoorA")
        addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "sideDoorB")
        sceneView.scene.rootNode.addChildNode(portalNode)
    }
    
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)
        child?.renderingOrder = 200
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        showDetectionLabel()
    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        let touchLocation = sender.location(in: sceneView)
        let raycastQuery = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)
        guard let raycast = raycastQuery else { return }
        let raycastResults = sceneView.session.raycast(raycast)
        if !raycastResults.isEmpty {
            addPortal(raycastResult: raycastResults.first!)
        }
    }
}

// MARK: - UI
extension ViewController {
    final private func setAR() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.delegate = self
        sceneView.session.run(configuration)
    }
    
    final private func setBasics() {
        detectionLabel.text = "Plane Detected"
        detectionLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        detectionLabel.textColor = .black
        detectionLabel.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    final private func setUI() {
        setBasics()
        [sceneView, detectionLabel].forEach {
            view.addSubview($0)
        }
        sceneView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        detectionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
        }
    }
}

