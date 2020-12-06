//
//  ViewController.swift
//  Whack-a-Jellyfish
//
//  Created by Kas Song on 12/6/20.
//

import ARKit
import UIKit
import Each

class ViewController: UIViewController {
    
    // MARK: - Properties
    var timer = Each(1).seconds
    var second = 5
    var countdown = 5
    
    let topView = UIView()
    let timerLabel = UILabel()
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

// MARK: - Game Related
extension ViewController {
    /// 해파리 추가
    func addNode() {
        let jellyfishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyfishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false)
        jellyfishNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),
                                             randomNumbers(firstNum: -0.5, secondNum: 0.5),
                                             randomNumbers(firstNum: -1, secondNum: 1))
        sceneView.scene.rootNode.addChildNode(jellyfishNode!)
    }
    /// 노드가 두 지점을 이동하는 애니메이션
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        let position = node.presentation.position
        spin.toValue = SCNVector3(position.x - 0.2, position.y - 0.2, position.z - 0.02)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    }
    /// 사용자 승리
    func win() {
        timer.stop()
        timerLabel.text = "You Win"
        self.playButton.isEnabled = true
    }
}

// MARK: - Timer Related
extension ViewController {
    /// 타이머 시작
    func setTimer() {
        timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)
            if self.countdown == 0 {
                self.timerLabel.text = "You Lose"
                return .stop
            }
            return .continue
        }
    }
    /// 타이머 초기화
    func restoreTimer() {
        timer.stop()
        countdown = second
        timerLabel.text = String(countdown)
    }
}

// MARK: - Selectors
extension ViewController {
    /// 버튼 터치 시 동작
    @objc
    func handleButtons(_ sender: UIButton) {
        switch sender {
        case playButton:
            addNode()
            setTimer()
            playButton.isEnabled = false
        case resetButton:
            restoreTimer()
            playButton.isEnabled = true
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                node.removeFromParentNode()
            }
        default:
            break
        }
    }
    /// 해파리 터치 시 동작
    @objc
    func handleTaps(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? ARSCNView else { return }
        let location = sender.location(in: tappedView)
        let hitTest = tappedView.hitTest(location)
        if hitTest.isEmpty {
            print("Didn't touch anything")
        } else {
            if countdown > 0 {
                let result = hitTest.first!
                let node = result.node
                if node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.win()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
}

// MARK: - Helpers
extension ViewController {
    /// 두 숫자 사이의 무작위 숫자 생성
    private func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
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
        // Attributes
        view.backgroundColor = .white
        topView.backgroundColor = .white
        timerLabel.text = "Let's Play"
        timerLabel.textColor = .black
        timerLabel.font = UIFont.systemFont(ofSize: 22)
        
        playButton.setImage(UIImage(named: "Play"), for: .normal)
        playButton.addTarget(self, action: #selector(handleButtons(_:)), for: .touchUpInside)
        resetButton.setImage(UIImage(named: "Reset"), for: .normal)
        resetButton.addTarget(self, action: #selector(handleButtons(_:)), for: .touchUpInside)
        
        // Layout
        [topView, sceneView, playButton, resetButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 50),
            
            sceneView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            playButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
        topView.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
        ])
    }
}
