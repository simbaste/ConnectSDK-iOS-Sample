//
//  DeviceDetailViewController.swift
//  ConnectSDK-iOS-App
//
//  Created by Stephane SIMO MBA on 25/04/2024.
//

import UIKit
import ConnectSDKWrapper

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
    let volumeSlider = UISlider()
    let statusIndicator = UIView()
    let snackbar = UILabel()

    fileprivate func setupDeviceInfo() {
        // Set up device information
        if let device = device {
            nameLabel.text = device.name
            let services = device.services.map { $0.name }.joined(separator: ", ")
            let capabilities = device.capabilities.map { $0.rawValue }.joined(separator: ", ")
            descriptionLabel.text = "Service: \(services)\n Capabilities: \(capabilities)"
            statusLabel.text = device.isConnected ? "Connected" : "Disconnected"
            connectButton.setTitle(device.isConnected ? "Disconect" : "Connect", for: .normal)
            statusIndicator.backgroundColor = device.isConnected ? .green : .gray
        }
        playButton.isEnabled = device?.isConnected ?? false
        volumeSlider.isEnabled = device?.isConnected ?? false
        playButton.backgroundColor = playButton.isEnabled ? .blue : .lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 30)
        view.addSubview(nameLabel)

        descriptionLabel.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 30)
        view.addSubview(descriptionLabel)

        statusLabel.frame = CGRect(x: 20, y: 200, width: view.frame.width - 40, height: 30)
        statusLabel.numberOfLines = 0
        statusLabel.lineBreakMode = .byWordWrapping
        view.addSubview(statusLabel)
        
        statusIndicator.frame = CGRect(x: view.frame.width - 60, y: 200, width: 20, height: 20)
        statusIndicator.layer.cornerRadius = statusIndicator.frame.width / 2
        view.addSubview(statusIndicator)

        playButton.frame = CGRect(x: 20, y: 250, width: view.frame.width - 40, height: 40)

        // Set up playButton
        setupButton(playButton, title: "Play on TV", yPosition: 250)
        
        // Set up connectButton
        setupButton(connectButton, title: "Connect", yPosition: 300)
        
        setupDeviceInfo()
        device?.delegate = self
        
        volumeSlider.frame = CGRect(x: 20, y: 350, width: view.frame.width - 40, height: 40)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 100
        volumeSlider.addTarget(self, action: #selector(volumeSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(volumeSlider)
        
        snackbar.frame = CGRect(x: 20, y: view.frame.height - 100, width: view.frame.width - 40, height: 40)
        snackbar.isHidden = true
        snackbar.backgroundColor = .darkGray
        snackbar.textColor = .white
        snackbar.textAlignment = .center
        view.addSubview(snackbar)
    }
    
    @objc func volumeSliderValueChanged(_ sender: UISlider) {
        guard let device = device else { return }
        if device.isConnected {
            let volume = sender.value
            // Set volume on the connected device
            // Example: device.setVolume(volume: volume, success: { ... }, failure: { ... })
            device.setVolume(volume: volume) { launchSession in
                print("Volume updated")
            } failure: { error in
                print("Failed to set the volume")
            }

        }
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
            device?.openBrowser(with: "https://www.netgem.com/fr", success: { launchSession in
                print("launch browser")
                self.showSnackbar("Browser launched")
            }, failure: { error in
                print("launch browser failed")
                self.showAlert("Launch browser failed", "Couldn't launch browser on the derired device")
            })
        } else if sender == connectButton {
            if let device = device {
                if device.isConnected {
                    device.disconnect()
                } else {
                    device.connect()
                }
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
        DispatchQueue.main.async {
            self.device = device
            self.setupDeviceInfo()
            self.showSnackbar("Device connected")
        }
    }
    
    func device(didDisconnected device: DeviceWrapper, withError error: Error) {
        print("didDisconnected device \(device) with error \(error)")
        DispatchQueue.main.async {
            self.device = device
            self.setupDeviceInfo()
            self.showSnackbar("Device disconnected")
        }
    }
    
    func device(_ device: DeviceWrapper, service: DeviceServiceWrapper, pairingRequiredOfType pairingType: Int32) {
        print("pairingRequiredOfType() called with device = \(device), service = \(service), pairingType = \(pairingType)")
        showAlert("Pairing Required", "Pairing is required for this service.")
    }
    
    func deviceParingSucced(_device: DeviceWrapper, service: DeviceServiceWrapper) {
        print("deviceParingSucced() called with device = \(String(describing: device)), service = \(service)")
        self.showSnackbar("Device paired")
    }
    
    func device(_ device: DeviceWrapper, service: DeviceServiceWrapper, pairingFailedWithError error: Error) {
        print("pairingFailedWithError() called with device = \(device), service = \(service), error = \(error)")
        showAlert("Pairing Failed", "Pairing failed with error: \(error.localizedDescription)")
    }
    
    // MARK - Helpers functions
    
    fileprivate func showSnackbar(_ title: String) {
        self.snackbar.text = title
        self.snackbar.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.snackbar.isHidden = true
        }
    }
    
    fileprivate func showAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message:  message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}
