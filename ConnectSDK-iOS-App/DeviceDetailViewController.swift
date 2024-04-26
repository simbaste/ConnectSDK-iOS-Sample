//
//  DeviceDetailViewController.swift
//  ConnectSDK-iOS-App
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import UIKit
import ConnectSDKWrapper

class DeviceDetailViewController: UIViewController, ConnectableDeviceWrapperDelegate {
    
    // Device information
    var device: DeviceWrapper?

    // UI components
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let statusLabel = UILabel()
    let playButton = UIButton()
    let connectButton = UIButton()

    fileprivate func setupDeviceInfo() {
        // Set up device information
        if let device = device {
            nameLabel.text = device.name
            descriptionLabel.text = device.description
            statusLabel.text = device.isConnected ? "Connected" : "Disconnected"
        }
        playButton.isEnabled = device?.isConnected ?? false
        playButton.backgroundColor = playButton.isEnabled ? .blue : .lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 30)
        view.addSubview(nameLabel)

        descriptionLabel.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 30)
        view.addSubview(descriptionLabel)

        statusLabel.frame = CGRect(x: 20, y: 200, width: view.frame.width - 40, height: 30)
        view.addSubview(statusLabel)

        playButton.frame = CGRect(x: 20, y: 250, width: view.frame.width - 40, height: 40)

        // Set up playButton
        setupButton(playButton, title: "Play on TV", yPosition: 250)
        
        // Set up connectButton
        setupButton(connectButton, title: "Connect", yPosition: 300)
        
        setupDeviceInfo()
        device?.delegate = self
    }
    
    private func setupButton(_ button: UIButton, title: String, yPosition: CGFloat) {
        button.frame = CGRect(x: 20, y: yPosition, width: view.frame.width - 40, height: 40)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
    }

    @objc func buttonTapped(_ sender: UIButton) {
        // Animate button tap
        animateButtonTap(sender)
        if sender == playButton {
            // Handle play button action
        } else if sender == connectButton {
            device?.connect()
            if let device = device {
                self.device = DeviceWrapper(nil, FakeDevice(name: device.name!, description: device.description, isConnected: !device.isConnected))
                device.delegate?.device(didConnected: self.device!)
            }
        }
    }
    
    // Function to animate button tap
    private func animateButtonTap(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            // Scale the button down
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            // Scale the button back to its original size
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = .identity
            })
        })
    }
    
    // MARK: - ConnectableDeviceWrapperDelegate
    
    func device(didConnected device: DeviceWrapper) {
        print("didConnected device ==> \(device) isConnected ==> \(device.isConnected)")
        self.device = device
        self.setupDeviceInfo()
    }
    
    func device(didDisconnected device: DeviceWrapper, withError error: any Error) {
        print("didDisconnected device \(device) with error \(error)")
        self.device = device
        self.setupDeviceInfo()
    }

}
