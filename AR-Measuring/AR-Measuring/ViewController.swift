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

    // MARK: - Properties
    private let sceneView = ARSCNView()
    private let stackView = UIStackView()
    private let button = UIButton()
    private let texts = ["Distance", "x", "y", "z"]
    private var startingPosition: SCNNode?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBasics()
        setUI()
        setAR()
    }
}

// MARK: - Helpers
extension ViewController {
    private func setLabels(x: Float, y: Float, z: Float) {
        DispatchQueue.main.async {
            guard let labels = self.stackView.arrangedSubviews as? [UILabel] else { return }
            let texts = [String(format: "%.2f", self.distanceTraveled(x: x, y: y, z: z))  + "m",
                         String(format: "%.2f", x) + "m",
                         String(format: "%.2f", y) + "m",
                         String(format: "%.2f", z) + "m"]
            for index in labels.indices {
                labels[index].text = texts[index]
            }
        }
    }
    
    private func distanceTraveled(x: Float, y: Float, z: Float) -> Float {
        return sqrtf(x * x + y * y + z * z)
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
        if startingPosition != nil {
            startingPosition?.removeFromParentNode()
            startingPosition = nil
            return
        }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        let node = SCNNode(geometry: SCNSphere(radius: 0.005))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        node.simdTransform = modifiedMatrix
        sceneView.scene.rootNode.addChildNode(node)
        startingPosition = node
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let startingPosition = startingPosition else { return }
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        setLabels(x: xDistance, y: yDistance, z: zDistance)
    }
}

// MARK: - UI
extension ViewController {
    private func setAR() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.delegate = self
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
