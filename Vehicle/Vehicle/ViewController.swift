//
//  ViewController.swift
//  Vehicle
//
//  Created by Kas Song on 12/13/20.
//

import ARKit
import UIKit
import CoreMotion

class ViewController: UIViewController {

    // MARK: - Properties
    let sceneView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    let addButton = UIButton(type: .system)
    let motionManager = CMMotionManager()
    var vehicle: SCNPhysicsVehicle?
    var isCodeBase = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccelerometer()
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
//        concreteNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
//        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
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
        
        if !isCodeBase {
            addSceneNode(position: currentPositionOfCamera)
            return
        }
        
        let chassis = SCNNode(geometry: SCNBox(width: Standard.chassisWidth, height: Standard.chassisHeight, length: Standard.chassisLength, chamferRadius: 0))
        createCarNode(chassis: chassis, position: currentPositionOfCamera)
        addVehicleBehavior(chassis: chassis)
        sceneView.scene.rootNode.addChildNode(chassis)
    }
    }

// MARK: - Node Related
extension ViewController {
    private func createCarNode(chassis: SCNNode, position: SCNVector3) {
        chassis.position = position
        chassis.eulerAngles = SCNVector3(0, 0, 180.degreesToRadians)
        chassis.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        chassis.geometry?.firstMaterial?.isDoubleSided = true
        chassis.opacity = 0.95
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: chassis,
                                                                         options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        chassis.physicsBody = body
        createHeadNode(chassis: chassis)
        for index in 0...3 {
            createWheelNode(chassis: chassis, index: index)
        }
    }
    
    private func createHeadNode(chassis: SCNNode) {
        let headHeight: CGFloat = 0.1
        let headLength: CGFloat = 0.1
        let head = SCNNode(geometry: SCNBox(width: 0.1, height: headHeight, length: headLength, chamferRadius: 0))
        head.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        head.geometry?.firstMaterial?.isDoubleSided = true
        head.position = SCNVector3(0,
                                   -Standard.chassisHeight / 2 - headHeight / 2,
                                   Standard.chassisLength / 2 - headLength / 2)
        chassis.addChildNode(head)
    }
    
    private func createWheelNode(chassis: SCNNode, index: Int) {
        let wheelRadius: CGFloat = 0.025
        let wheelHeight: CGFloat = 0.035
        let wheel = SCNNode(geometry: SCNCylinder(radius: wheelRadius, height: wheelHeight))
        let wheelParent = SCNNode()
        wheelParent.eulerAngles = SCNVector3(180.degreesToRadians, 0, 0)
        wheel.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        wheel.geometry?.firstMaterial?.isDoubleSided = true
        wheel.eulerAngles = SCNVector3(0, 0, 90.degreesToRadians)
        var position = SCNVector3()
        switch index {
        case 0: // 우측 뒷바퀴
            wheelParent.name = "rearRightWheelParent"
            position = SCNVector3(Standard.chassisWidth / 2 - wheelHeight / 2 - 0.02,
                                  Standard.chassisHeight / 2 + wheelRadius + 0.02,
                                  -Standard.chassisLength / 2 + wheelRadius + 0.02)
        case 1: // 좌측 뒷바퀴
            wheelParent.name = "rearLeftWheelParent"
            position = SCNVector3(-Standard.chassisWidth / 2 + wheelHeight / 2 + 0.02,
                                  Standard.chassisHeight / 2 + wheelRadius + 0.02,
                                  -Standard.chassisLength / 2 + wheelRadius + 0.02)
        case 2: // 우측 앞바퀴
            wheelParent.name = "frontRightWheelParent"
            position = SCNVector3(Standard.chassisWidth / 2 - wheelHeight / 2 - 0.02,
                                  Standard.chassisHeight / 2 + wheelRadius + 0.02,
                                  Standard.chassisLength / 2 - wheelRadius - 0.02)
        case 3: // 좌측 앞바퀴
            wheelParent.name = "frontLeftWheelParent"
            position = SCNVector3(-Standard.chassisWidth / 2 + wheelHeight / 2 + 0.02,
                                  Standard.chassisHeight / 2 + wheelRadius + 0.02,
                                  Standard.chassisLength / 2 - wheelRadius - 0.02)
        default:
            fatalError()
        }
        wheelParent.position = position
        wheelParent.addChildNode(wheel)
        chassis.addChildNode(wheelParent)
    }
    
    private func addVehicleBehavior(chassis: SCNNode) {
        let rearRightWheelNode = chassis.childNode(withName: "rearRightWheelParent", recursively: false)!
        let rearLeftWheelNode = chassis.childNode(withName: "rearLeftWheelParent", recursively: false)!
        let frontRightWheelNode = chassis.childNode(withName: "frontRightWheelParent", recursively: false)!
        let frontLeftWheelNode = chassis.childNode(withName: "frontLeftWheelParent", recursively: false)!
        
        let rearRightWheel = SCNPhysicsVehicleWheel(node: rearRightWheelNode)
        let rearLeftWheel = SCNPhysicsVehicleWheel(node: rearLeftWheelNode)
        let frontRightWheel = SCNPhysicsVehicleWheel(node: frontRightWheelNode)
        let frontLeftWheel = SCNPhysicsVehicleWheel(node: frontLeftWheelNode)
        vehicle = SCNPhysicsVehicle(chassisBody: chassis.physicsBody ?? SCNPhysicsBody(),
                                         wheels: [rearRightWheel,
                                                  rearLeftWheel,
                                                  frontRightWheel,
                                                  frontLeftWheel])
        guard let vehicle = vehicle else { return }
        sceneView.scene.physicsWorld.addBehavior(vehicle)
    }
    
    private func addSceneNode(position: SCNVector3) {
        let scene = SCNScene(named: "Car-Scene.scn")
        let chassis = (scene?.rootNode.childNode(withName: "chassis", recursively: false))!
        let frontLeftWheel = chassis.childNode(withName: "frontLeftParent", recursively: false)!
        let frontRightWheel = chassis.childNode(withName: "frontRightParent", recursively: false)!
        let rearLeftWheel = chassis.childNode(withName: "rearLeftParent", recursively: false)!
        let rearRightWheel = chassis.childNode(withName: "rearRightParent", recursively: false)!
        
        let v_frontLeftWheel = SCNPhysicsVehicleWheel(node: frontLeftWheel)
        let v_frontRightWheel = SCNPhysicsVehicleWheel(node: frontRightWheel)
        let v_rearRightWheel = SCNPhysicsVehicleWheel(node: rearLeftWheel)
        let v_rearLeftWheel = SCNPhysicsVehicleWheel(node: rearRightWheel)

        
        chassis.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: chassis, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        chassis.physicsBody = body
        self.vehicle = SCNPhysicsVehicle(chassisBody: chassis.physicsBody!, wheels: [v_rearRightWheel, v_rearLeftWheel, v_frontRightWheel, v_frontLeftWheel])
        self.sceneView.scene.physicsWorld.addBehavior(self.vehicle!)
        self.sceneView.scene.rootNode.addChildNode(chassis)
    }
}

// MARK: - Accelerometer Related
extension ViewController {
    func setupAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.startAccelerometerUpdates(to: .main,
                                                withHandler: { data, error in
                                                    if let error = error {
                                                        print(error.localizedDescription)
                                                        return
                                                    }
                                                    guard let data = data else { return }
                                                    self.accelerometerDidChange(acceleration: data.acceleration)
                                                })
    }
    
    func accelerometerDidChange(acceleration: CMAcceleration) {
//        print(acceleration.x)
//        print(acceleration.y)
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

extension ViewController {
    struct Standard {
        static let chassisWidth: CGFloat = 0.2
        static let chassisHeight: CGFloat = 0.1
        static let chassisLength: CGFloat = 0.4
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
