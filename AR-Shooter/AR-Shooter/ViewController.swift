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
    final private var target: SCNNode?
    
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
        bulletNode.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        bulletNode.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        sceneView.scene.rootNode.addChildNode(bulletNode)
        bulletNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0),
                                                 SCNAction.removeFromParentNode()]))
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
        eggNode.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        eggNode.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        sceneView.scene.rootNode.addChildNode(eggNode)
    }
}

extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            target = nodeA
        } else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue {
            target = nodeB
        }
        let confettiScene = SCNScene(named: "Art.scnassets/confetti.scn")!
        let confettiNode = confettiScene.rootNode.childNode(withName: "particles", recursively: false)!
        confettiNode.particleSystems?.first?.loops = false
        confettiNode.particleSystems?.first?.particleLifeSpan = 4
        confettiNode.particleSystems?.first?.emitterShape = self.target?.geometry
        confettiNode.position = contact.contactPoint
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        target?.removeFromParentNode()
    }
}

// MARK: - AR
extension ViewController {
    final private func setAR() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.autoenablesDefaultLighting = true
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.session.run(configuration)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.x, left.z + right.z)
}

enum BitMaskCategory: Int {
    case bullet = 0
    case target = 1
}
