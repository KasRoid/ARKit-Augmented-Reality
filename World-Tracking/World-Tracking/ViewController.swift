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
            addButtonActions()
        case removeButton:
            removeButtonActions()
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
    
    private func addButtonActions() {
        rotatedPlane()
    }
    
    private func removeButtonActions() {
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func buildHouse() {
        let houseGeometry = SCNBox(width: 0.1, height: 0.08, length: 0.1, chamferRadius: 0)
        let ceilingGeometry = SCNPyramid(width: 0.1, height: 0.05, length: 0.1)
        let doorGeometry = SCNPlane(width: 0.025, height: 0.05)
        let handleGeometory = SCNPlane(width: 0.005, height: 0.005)
        handleGeometory.cornerRadius = 0.01 / 2
        let houseNode = SCNNode(geometry: houseGeometry)
        let ceilingNode = SCNNode(geometry: ceilingGeometry)
        let doorNode = SCNNode(geometry: doorGeometry)
        let handleNode = SCNNode(geometry: handleGeometory)
        
        houseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        houseNode.position = SCNVector3(0, 0, -0.3)
        ceilingNode.position = SCNVector3(0, 0.04, 0)
        doorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        doorNode.position = SCNVector3(-0.05 + (0.025 / 2) + 0.005, -(0.04 - 0.025), 0.051)
        handleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        handleNode.position = SCNVector3(-0.008, 0, 0.001)
        sceneView.scene.rootNode.addChildNode(houseNode)
        houseNode.addChildNode(ceilingNode)
        houseNode.addChildNode(doorNode)
        doorNode.addChildNode(handleNode)
    }
    
    private func rotatedPlane() {
        let geometry = SCNPlane(width: 0.2, height: 0.2)
        let node = SCNNode(geometry: geometry)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        node.geometry?.firstMaterial?.isDoubleSided = true
        node.position = SCNVector3(0, 0, -0.2)
        node.eulerAngles = SCNVector3(0, 90.degreesToRadians, 0)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func createHouseShape() {
        let node = SCNNode()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0.2))
        path.addLine(to: CGPoint(x: 0.2, y: 0.4))
        path.addLine(to: CGPoint(x: 0.4, y: 0.2))
        path.addLine(to: CGPoint(x: 0.4, y: 0))
        
        node.geometry = SCNShape(path: path, extrusionDepth: 0.1)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        node.position = SCNVector3(0, 0, -0.3)
        sceneView.scene.rootNode.addChildNode(node)
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

// Copy below to try out default shapes
//            node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03)
//            node.geometry = SCNCapsule(capRadius: 0.1, height: 0.3)
//            node.geometry = SCNCone(topRadius: 0.1, bottomRadius: 0.3, height: 0.3)
//            node.geometry = SCNCylinder(radius: 0.1, height: 0.1)
//            node.geometry = SCNSphere(radius: 0.1)
//            node.geometry = SCNTube(innerRadius: 0.1, outerRadius: 0.2, height: 0.1)
//            node.geometry = SCNTorus(ringRadius: 0.2, pipeRadius: 0.1)
//            node.geometry = SCNPlane(width: 0.2, height: 0.2)
//            node.geometry = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
