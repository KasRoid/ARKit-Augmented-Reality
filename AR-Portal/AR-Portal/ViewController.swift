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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setAR()
        setUI()
    }
}

// MARK: - UI
extension ViewController {
    final private func setAR() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    final private func setUI() {
        view.addSubview(sceneView)
        sceneView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
