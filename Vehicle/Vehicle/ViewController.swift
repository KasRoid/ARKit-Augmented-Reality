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
        
        let frame = SCNNode(geometry: SCNBox(width: 0.2, height: 0.1, length: 0.4, chamferRadius: 0))
        frame.position = currentPositionOfCamera
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: frame,
                                                                         options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        frame.physicsBody = body
        createCarNode(frame: frame)
        sceneView.scene.rootNode.addChildNode(frame)
    }
    
    @discardableResult
    private func createCarNode(frame origin: SCNNode) -> SCNNode {
        let body = createBodyNode(origin: origin)
        createHeadNode(origin: origin, body: body)
        for index in 0...3 {
            createWheelNode(origin: origin, body: body, index: index)
        }
        return origin
    }
    
    private func createBodyNode(origin: SCNNode) -> SCNNode {
        let bodyWidth: CGFloat = 0.2
        let bodyHeight: CGFloat = 0.1
        let bodyLength: CGFloat = 0.4
        let body = SCNNode(geometry: SCNBox(width: bodyWidth, height: bodyHeight, length: bodyLength, chamferRadius: 0))
        body.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        origin.addChildNode(body)
        return body
    }
    
    @discardableResult
    private func createHeadNode(origin: SCNNode, body: SCNNode) -> SCNNode {
        let headHeight: CGFloat = 0.1
        let headLength: CGFloat = 0.1
        let head = SCNNode(geometry: SCNBox(width: 0.1, height: headHeight, length: headLength, chamferRadius: 0))
        let bodyHeight = CGFloat(body.boundingBox.max.y - body.boundingBox.min.y)
        let bodyLength = CGFloat(body.boundingBox.max.z - body.boundingBox.min.z)
        head.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        head.position = SCNVector3(0,
                                   bodyHeight / 2 + headHeight / 2,
                                   bodyLength / 2 - headLength / 2)
        origin.addChildNode(head)
        return body
    }
    
    @discardableResult
    private func createWheelNode(origin: SCNNode, body: SCNNode, index: Int) -> SCNNode {
        let wheelRadius: CGFloat = 0.025
        let wheelHeight: CGFloat = 0.025
        let wheel = SCNNode(geometry: SCNCylinder(radius: wheelRadius, height: wheelHeight))
        wheel.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        wheel.eulerAngles = SCNVector3(0, 0, 90.degreesToRadians)
        let bodyWidth = CGFloat(body.boundingBox.max.x - body.boundingBox.min.x)
        let bodyHeight = CGFloat(body.boundingBox.max.y - body.boundingBox.min.y)
        let bodyLength = CGFloat(body.boundingBox.max.z - body.boundingBox.min.z)
        
        var position = SCNVector3()
        switch index {
        case 0: // 우측 앞바퀴
            position = SCNVector3(bodyWidth / 2 - wheelHeight / 2,
                                  -bodyHeight / 2 - wheelRadius,
                                  bodyLength / 2 - wheelRadius)
        case 1: // 좌측 앞바퀴
            position = SCNVector3(-bodyWidth / 2 + wheelHeight / 2,
                                  -bodyHeight / 2 - wheelRadius,
                                  bodyLength / 2 - wheelRadius)
        case 2: // 우측 뒷바퀴
            position = SCNVector3(bodyWidth / 2 - wheelHeight / 2,
                                  -bodyHeight / 2 - wheelRadius,
                                  -bodyLength / 2 + wheelRadius)
        case 3: // 좌측 뒷바퀴
            position = SCNVector3(-bodyWidth / 2 + wheelHeight / 2,
                                  -bodyHeight / 2 - wheelRadius,
                                  -bodyLength / 2 + wheelRadius)
        default:
            fatalError()
        }
        wheel.position = position
        origin.addChildNode(wheel)
        return wheel
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAhnchor = anchor as? ARPlaneAnchor else { return }
        let concreteNode = createConcrete(planeAnchor: planeAhnchor)
        node.addChildNode(concreteNode)
        print("new flat surface detectd, new ARPlaneAnchor added")
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
        configuration.planeDetection = .horizontal
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
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
