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
    let button = UIButton(type: .system)
    var spaceBackground = false
    
    var sun: SCNNode?
    var mercury: SCNNode?
    var venus: SCNNode?
    var earth: SCNNode?
    var mars: SCNNode?
    var jupiter: SCNNode?
    var saturn: SCNNode?
    var uranus: SCNNode?
    
    let positionOfSun = SCNVector3(0, 0, -1)
    
    // Parents
    let mercuryParent = SCNNode()
    let venusParent = SCNNode()
    let earthParent = SCNNode()
    let marsParent = SCNNode()
    let jupiterParent = SCNNode()
    let saturnParent = SCNNode()
    let uranusParent = SCNNode()
    
    // Satellite Parents
    let moonParent = SCNNode()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSolarSystem()
    }
    
    // MARK: - Helpers
    func setSolarSystem() {
        setSun()
        setMercury()
        setVenus()
        setEarth()
        setMars()
        setJupiter()
        setSaturn()
        setUranus()
        setMoon()
        setRevolution()
    }
    
    func setSun() {
        sun = planet(
            geometry: SCNSphere(radius: 1),
            diffuse: UIImage(named: "Sun"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: positionOfSun)
        
        guard let sun = sun else { return }
        self.sceneView.scene.rootNode.addChildNode(sun)
        rotate(node: sun, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setMercury() {
        mercury = planet(
            geometry: SCNSphere(radius: 0.05),
            diffuse: UIImage(named: "Mercury-Surface"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(1.4, 0, 0))
        
        guard let mercury = mercury else { return }
        mercuryParent.addChildNode(mercury)
        rotate(node: mercury, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setVenus() {
        venus = planet(
            geometry: SCNSphere(radius: 0.13),
            diffuse: UIImage(named: "Venus-Surface"),
            specular: nil,
            emission: UIImage(named: "Venus-Atmosphere"),
            normal: nil,
            position: SCNVector3(1.7, 0, 0))
        
        guard let venus = venus else { return }
        venusParent.addChildNode(venus)
        rotate(node: venus, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setEarth() {
        earth = planet(
            geometry: SCNSphere(radius: 0.15),
            diffuse: UIImage(named: "Earth-Day"),
            specular: UIImage(named: "Earth-Specular"),
            emission: UIImage(named: "Earth-Emission"),
            normal: UIImage(named: "Earth-Normal"),
            position: SCNVector3(2, 0, 0))
        
        guard let earth = earth else { return }
        earthParent.addChildNode(earth)
        rotate(node: earth, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setMars() {
        mars = planet(
            geometry: SCNSphere(radius: 0.07),
            diffuse: UIImage(named: "Mars-Surface"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(2.3, 0, 0))
        
        guard let mars = mars else { return }
        marsParent.addChildNode(mars)
        rotate(node: mars, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setJupiter() {
        jupiter = planet(
            geometry: SCNSphere(radius: 0.6),
            diffuse: UIImage(named: "Jupiter-Surface"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(4, 0, 0))
        
        guard let jupiter = jupiter else { return }
        jupiterParent.addChildNode(jupiter)
        rotate(node: jupiter, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setSaturn() {
        saturn = planet(
            geometry: SCNSphere(radius: 0.5),
            diffuse: UIImage(named: "Saturn-Surface"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(5.5, 0, 0))
        
        let ring = SCNNode(geometry: SCNTube(innerRadius: 0.7, outerRadius: 1, height: 0.01))
        ring.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        ring.geometry?.firstMaterial?.emission.contents = UIImage(named: "Saturn-Ring")
        ring.geometry?.firstMaterial?.normal.contents = UIImage(named: "Saturn-Ring")
        ring.eulerAngles = SCNVector3(-30.degreesToRadians, 30.degreesToRadians, 0)
        saturn?.addChildNode(ring)
        
        guard let saturn = saturn else { return }
        saturnParent.addChildNode(saturn)
        rotate(node: saturn, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setUranus() {
        uranus = planet(
            geometry: SCNSphere(radius: 0.2),
            diffuse: UIImage(named: "Uranus-Surface"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(6, 0, 0))
        
        guard let uranus = uranus else { return }
        uranusParent.addChildNode(uranus)
        rotate(node: uranus, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
    }
    
    func setMoon() {
        let moon = planet(
            geometry: SCNSphere(radius: 0.05),
            diffuse: UIImage(named: "Moon-Surface"),
            specular: nil,
            emission: nil,
            normal: nil,
            position: SCNVector3(0.3, 0, 0))
        
        moonParent.addChildNode(moon)
    }
    
    func setRevolution() {
        // Planets
        [mercuryParent, venusParent, earthParent, marsParent, jupiterParent, saturnParent, uranusParent].forEach {
            self.sceneView.scene.rootNode.addChildNode($0)
            $0.position = sun?.position ?? SCNVector3()
        }
        
        rotate(node: mercuryParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 7)
        rotate(node: venusParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 10)
        rotate(node: earthParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 14)
        rotate(node: marsParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 18)
        rotate(node: jupiterParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 20)
        rotate(node: saturnParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 30)
        rotate(node: uranusParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 45)

        // Moon
        earthParent.addChildNode(moonParent)
        moonParent.position = earth?.position ?? SCNVector3()
        rotate(node: moonParent, x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 4)
    }
    
    func planet(geometry: SCNGeometry,
                diffuse: UIImage?,
                specular: UIImage?,
                emission: UIImage?,
                normal: UIImage?,
                position: SCNVector3) -> SCNNode {
        let node = SCNNode()
        node.geometry = geometry
        node.geometry?.firstMaterial?.diffuse.contents = diffuse
        node.geometry?.firstMaterial?.specular.contents = specular
        node.geometry?.firstMaterial?.emission.contents = emission
        node.geometry?.firstMaterial?.normal.contents = normal
        node.position = position
        return node
    }
    
    func rotate(node: SCNNode , x: CGFloat, y: CGFloat, z: CGFloat, duration: TimeInterval) {
        let action = SCNAction.rotateBy(x: x, y: y, z: z, duration: duration)
        let forever = SCNAction.repeatForever(action)
        node.runAction(forever)
    }
}

extension ViewController {
    @objc
    func handleButton(_ sender: UIButton) {
        spaceBackground.toggle()
        spaceBackground
            ? { sceneView.scene.background.contents = UIImage(named: "MilkyWay") }()
            : { }() // To do
    }
}

// MARK: - AR
extension ViewController {
    func setupAR() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.session.run(configuration)
    }
}

// MARK: - UI
extension ViewController {
    func setupUI() {
        button.setTitle("Change Background", for: .normal)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        
        // Layout
        view.addSubview(sceneView)
        view.addSubview(button)
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180 }
}
