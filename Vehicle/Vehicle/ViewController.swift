//
//  ViewController.swift
//  Vehicle
//
//  Created by Kas Song on 12/13/20.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    let sceneView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    let addButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - AR Related
extension ViewController {
    func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                                      height: CGFloat(planeAnchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        concreteNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody   
        return concreteNode
    }
    
    private func addCar() {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = orientation + location
        let box = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        box.position = currentPositionOfCamera
        let body = SCNPhysicsBody(type: .dynamic,
                                  shape: SCNPhysicsShape(node: box,
                                                         options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        box.physicsBody = body
        sceneView.scene.rootNode.addChildNode(box)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAhnchor = anchor as? ARPlaneAnchor else { return }
        let concreteNode = createConcrete(planeAnchor: planeAhnchor)
        node.addChildNode(concreteNode)
        print("new flat surface dtectd, new ARPlaneAnchor added")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAhnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childeNode, _) in
            childeNode.removeFromParentNode()
        }
        let concreteNode = createConcrete(planeAnchor: planeAhnchor)
        node.addChildNode(concreteNode)
        print("Updating floor's anchor")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childeNode, _) in
            childeNode.removeFromParentNode()
        }
    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    private func handleButton(_ sender: UIButton) {
        addCar()
    }
}

// MARK: - UI
extension ViewController {
    func setupAR() {
        sceneView.delegate = self
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    func setupUI() {
        // Attributes
        addButton.setTitle("Add", for: .normal)
        addButton.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        
        // Layout
        [sceneView, addButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
