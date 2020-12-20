//
//  ViewController.swift
//  AR-Measuring
//
//  Created by Kas Song on 12/20/20.
//

import ARKit
import UIKit
import SnapKit

class ViewController: UIViewController {

    private let sceneView = ARSCNView()
    private let stackView = UIStackView()
    private let button = UIButton()
    private let texts = ["Distance", "x", "y", "z"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBasics()
        setUI()
        setAR()
    }
}

// MARK: - Selectors
extension ViewController {
    @objc
    private func handleButton(_ sender: UIButton) {
        print(#function)
    }
    
    @objc
    private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        let node = SCNNode(geometry: SCNSphere(radius: 0.005))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        node.simdTransform = modifiedMatrix
        sceneView.scene.rootNode.addChildNode(node)
    }
}

// MARK: - UI
extension ViewController {
    private func setAR() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.debugOptions = [.showWorldOrigin]
        sceneView.session.run(configuration)
    }
    
    private func setBasics() {
        texts.forEach {
            stackView.addArrangedSubview(createLabels(text: $0))
        }
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 30
        
        button.setImage(UIImage(named: "add"), for: .normal)
        button.addTarget(self, action: #selector(handleButton(_:)), for: .touchUpInside)
    }
    
    private func createLabels(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }
    
    private func setUI() {
        [sceneView, stackView, button].forEach {
            view.addSubview($0)
        }
        sceneView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.centerX.equalToSuperview()
        }
        button.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
