//
//  ViewController.swift
//  AR-Hoops
//
//  Created by Kas Song on 1/3/21.
//

import ARKit
import UIKit
import Each

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var detectedLabel: UILabel!
    
    final private let configuration = ARWorldTrackingConfiguration()
    final private var timer = Each(0.05).seconds
    final private var power: Float = 0
    final private var basketAdded = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setAR()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        timer.perform(closure: { () -> NextStep in
            self.power += 1
            return .continue
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if basketAdded == true {
            timer.stop()
            shootBall()
        }
        power = 1
    }
    
    deinit {
        timer.stop()
    }
}

// MARK: - Helpers
extension ViewController {
    final private func addBasket(raycastResult: ARRaycastResult) {
        guard basketAdded == false else { return }
        let scene = SCNScene(named: "Basketball.scnassets/Basketball.scn")!
        let node = scene.rootNode.childNode(withName: "Basket", recursively: false)!
        node.position.x = raycastResult.worldTransform.columns.3.x
        node.position.y = raycastResult.worldTransform.columns.3.y
        node.position.z = raycastResult.worldTransform.columns.3.z
        node.physicsBody = SCNPhysicsBody(type: .static,
                                          shape: SCNPhysicsShape(node: node,
                                                                 options: [SCNPhysicsShape.Option.keepAsCompound: true,
                                                                           SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        sceneView.scene.rootNode.addChildNode(node)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2,
                                      execute: {
                                        self.basketAdded = true
                                      })
    }
    
    final private func shootBall() {
        guard let pointOfView = sceneView.pointOfView else { return }
        removeEveryOtherBall()
        let location = SCNVector3(pointOfView.transform.m41,
                                  pointOfView.transform.m42,
                                  pointOfView.transform.m43)
        let orientation = SCNVector3(-pointOfView.transform.m31,
                                     -pointOfView.transform.m32,
                                     -pointOfView.transform.m33)
        let position = location + orientation
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "ball")
        ball.position = position
        ball.name = "BasketBall"
        let body = SCNPhysicsBody(type: .dynamic,
                                  shape: SCNPhysicsShape(node: ball, options: nil))
        body.restitution = 0.2
        ball.physicsBody = body
        ball.physicsBody?.applyForce(SCNVector3(orientation.x * power,
                                                orientation.y * power,
                                                orientation.z * power),
                                     asImpulse: true)
        sceneView.scene.rootNode.addChildNode(ball)
    }
    
    final private func removeEveryOtherBall() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "BasketBall" {
                node.removeFromParentNode()
            }
        }
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
        tapGesture.cancelsTouchesInView = false
        sceneView.addGestureRecognizer(tapGesture)
        
        configuration.planeDetection = .horizontal
        sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        sceneView.automaticallyUpdatesLighting = true
        sceneView.delegate = self
        sceneView.session.run(configuration)
    }
}

func +(left: SCNVector3, right: SCNVector3 ) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
