//
//  ViewController.swift
//  AR-Drawing
//
//  Created by Kas Song on 11/28/20.
//

import ARKit
import UIKit

class ViewController: UIViewController {

    let sceneView = ARSCNView()
    let button = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAR()
    }
    
    @objc
    func handleButton(_ sender: UIButton) {
        print(#function)
    }
}

// MARK: - UI
extension ViewController {
    func setupAR() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.showsStatistics = true
    }
    
    func setupUI() {
        button.setTitle("Draw", for: .normal)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
        // Layout
        [sceneView, button].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
}
