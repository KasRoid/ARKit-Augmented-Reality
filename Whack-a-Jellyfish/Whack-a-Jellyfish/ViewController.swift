//
//  ViewController.swift
//  Whack-a-Jellyfish
//
//  Created by Kas Song on 12/6/20.
//

import ARKit
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    let sceneView = ARSCNView()
    let configuration = ARWorldTrackingConfiguration()
    let playButton = UIButton()
    let resetButton = UIButton()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
    }
}

// MARK: - Helpers
extension ViewController {
    func addNode() {
        let node = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        node.position = SCNVector3(0, 0, -0.2)
        sceneView.scene.rootNode.addChildNode(node)
    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    func handleButtons(_ sender: UIButton) {
        switch sender {
        case playButton:
            addNode()
        case resetButton:
            break
        default:
            break
        }
    }
    
    @objc
    func handleTaps(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: tappedView)
        let hitTest = tappedView.hitTest(location)
        if hitTest.isEmpty {
            print("Didn't touch anything")
        } else {
            let result = hitTest.first!
            let geometry = result.node.geometry
            print(geometry)
        }
    }
}

// MARK: - UI
extension ViewController {
    func setupAR() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTaps(_:)))
        sceneView.addGestureRecognizer(gesture)
        sceneView.session.run(configuration)
    }
    
    func setupUI() {
        // Buttons
        playButton.setImage(UIImage(named: "Play"), for: .normal)
        playButton.addTarget(self, action: #selector(handleButtons(_:)), for: .touchUpInside)
        resetButton.setImage(UIImage(named: "Reset"), for: .normal)
        resetButton.addTarget(self, action: #selector(handleButtons(_:)), for: .touchUpInside)
        
        // Layout
        [sceneView, playButton, resetButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            playButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
}
