//
//  ViewController.swift
//  AR-Portal
//
//  Created by Kas Song on 12/20/20.
//

import ARKit
import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    final private let sceneView = ARSCNView()
    final private let detectionLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setAR()
        setUI()
    }
}

// MARK: - Helpers
extension ViewController {
    func showDetectionLabel() {
        DispatchQueue.main.async { self.detectionLabel.isHidden = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3,
                                      execute: { self.detectionLabel.isHidden = true })
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        showDetectionLabel()
    }
}

// MARK: - UI
extension ViewController {
    final private func setAR() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.delegate = self
        sceneView.session.run(configuration)
    }
    
    final private func setBasics() {
        detectionLabel.text = "Plane Detected"
        detectionLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        detectionLabel.textColor = .black
        detectionLabel.isHidden = true
    }
    
    final private func setUI() {
        setBasics()
        [sceneView, detectionLabel].forEach {
            view.addSubview($0)
        }
        sceneView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        detectionLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
