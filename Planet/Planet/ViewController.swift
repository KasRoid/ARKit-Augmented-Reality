//
//  ViewController.swift
//  Planet
//
//  Created by Kas Song on 12/5/20.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    // MARK: - Properties
    let sceneView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    var sun: SCNNode?
    var venus: SCNNode?
    var earth: SCNNode?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSun()
        setVenus()
        setEarth()
    }
    
    // MARK: - Helpers
    func setSun() {
        sun = planet(
            geometry: SCNSphere(radius: 0.35),
            diffuse: UIImage(named: "Sun"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(0, 0, -1))
        guard let sun = sun else { return }
        self.sceneView.scene.rootNode.addChildNode(sun)
    }
    
    func setVenus() {
        venus = planet(
            geometry: SCNSphere(radius: 0.1),
            diffuse: UIImage(named: "Venus-Surface"),
            specular: nil,
            emission: UIImage(named: "Venus-Atmosphere"),
            normal: nil,
            position: SCNVector3(0.7, 0, 0))
        
        guard let venus = venus else { return }
        sun?.addChildNode(venus)
    }
    
    func setEarth() {
        earth = planet(
            geometry: SCNSphere(radius: 0.2),
            diffuse: UIImage(named: "Earth-Day"),
            specular: UIImage(named: "Earth-Specular"),
            emission: UIImage(named: "Earth-Emission"),
            normal: UIImage(named: "Earth-Normal"),
            position: SCNVector3(1.2, 0, 0))
        
        guard let earth = earth else { return }
        sun?.addChildNode(earth)
        
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        earth.runAction(forever)
    }
    
    func planet(geometry: SCNGeometry,
                diffuse: UIImage?,
                specular: UIImage?,
                emission: UIImage?,
                normal: UIImage?,
                position: SCNVector3) -> SCNNode {
        let node = SCNNode()
        node.geometry = SCNSphere(radius: 0.2)
        node.geometry?.firstMaterial?.diffuse.contents = diffuse
        node.geometry?.firstMaterial?.specular.contents = specular
        node.geometry?.firstMaterial?.emission.contents = emission
        node.geometry?.firstMaterial?.normal.contents = normal
        node.position = position
        return node
    }
}

extension ViewController {
    func setupAR() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
    }
}

extension ViewController {
    func setupUI() {
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180 }
}
