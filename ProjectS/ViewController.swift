//
//  ViewController.swift
//  ProjectS
//
//  Created by Rodrigo on 14/02/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Abrir Camera", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        
    }
    
    func setupUI() {
        
        view.backgroundColor = .white
        view.addSubview(cameraButton)
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 200),
            cameraButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func openCamera() {
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true, completion: nil)
    }
    
}

