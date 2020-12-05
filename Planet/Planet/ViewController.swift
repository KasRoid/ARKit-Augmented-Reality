//
//  ViewController.swift
//  Planet
//
//  Created by Kas Song on 12/5/20.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    let sceneView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let earth = SCNNode()
        earth.geometry = SCNSphere(radius: 0.2)
        earth.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Earth-Day")
        earth.geometry?.firstMaterial?.specular.contents = UIImage(named: "Earth-Specular")
        earth.geometry?.firstMaterial?.emission.contents = UIImage(named: "Earth-Emission")
        earth.geometry?.firstMaterial?.normal.contents = UIImage(named: "Earth-Normal")
//        earth.geometry?.firstMaterial?.normal.contents = UIColor.red
        earth.position = SCNVector3(0, 0, -1)
        self.sceneView.scene.rootNode.addChildNode(earth)
        
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        earth.runAction(forever)
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
