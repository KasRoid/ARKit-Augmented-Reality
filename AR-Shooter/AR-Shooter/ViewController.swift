//
//  ViewController.swift
//  AR-Shooter
//
//  Created by Kas Song on 1/3/21.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var sceneView: ARSCNView!
    final private let configuration = ARWorldTrackingConfiguration()
    final private var power: Float = 50
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setAR()
    }
    
    // MARK: - Selectors
    @IBAction func handleButton(_ sender: UIButton) {
        addEgg(x: 5, y: 0, z: -40)
        addEgg(x: 0, y: 0, z: -40)
        addEgg(x: -5, y: 0, z: -40)
    }
    
    @objc
    private func handleGesture(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let position = orientation + location
        let bulletNode = SCNNode(geometry: SCNSphere(radius: 0.1))
        bulletNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bulletNode.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bulletNode, options: nil))
        body.isAffectedByGravity = false
        bulletNode.physicsBody = body
        bulletNode.physicsBody?.applyForce(SCNVector3(orientation.x * power,
                                                      orientation.y * power,
                                                      orientation.z * power),
                                           asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletNode)
    }
}

// MARK: - Helpers
extension ViewController {
    final private func addEgg(x: Float, y: Float, z: Float) {
        let eggScene = SCNScene(named: "Art.scnassets/egg.scn")!
        let eggNode = eggScene.rootNode.childNode(withName: "egg", recursively: false)!
        eggNode.position = SCNVector3(x, y, z)
        eggNode.physicsBody = SCNPhysicsBody(type: .static,
                                             shape: SCNPhysicsShape(node: eggNode, options: nil))
        sceneView.scene.rootNode.addChildNode(eggNode)
    }
}

// MARK: - AR
extension ViewController {
    final private func setAR() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        sceneView.session.run(configuration)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.x, left.z + right.z)
}
