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
    let volumeSlider = UISlider()
    let statusIndicator = UIView()
    let snackbar = UILabel()
    let videoButton = UIButton() // Button to start video media
    let playPauseButton = UIButton() // Button to Play / Pause
    let seekBar = UISlider() // Seek bar
    
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
        
        // Set volume title label
        let volumeTitleLabel = UILabel()
        volumeTitleLabel.frame = CGRect(x: 20, y: 350, width: view.frame.width - 40, height: 30)
        volumeTitleLabel.text = "Volume"
        view.addSubview(volumeTitleLabel)
        
        volumeSlider.frame = CGRect(x: 20, y: 390, width: view.frame.width - 40, height: 40)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 100
        volumeSlider.addTarget(self, action: #selector(volumeSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(volumeSlider)
        
        videoButton.frame = CGRect(x: 20, y: 440, width: view.frame.width - 40, height: 40)
        setupButton(videoButton, title: "Start Video Media", yPosition: 440)
        
        playPauseButton.frame = CGRect(x: 20, y: 490, width: view.frame.width - 40, height: 40)
        setupButton(playPauseButton, title: "Play / Pause", yPosition: 490)
        playPauseButton.isEnabled = false
        
        // Set volume title label
        let seekBarTitleLabel = UILabel()
        seekBarTitleLabel.frame = CGRect(x: 20, y: 540, width: view.frame.width - 40, height: 30)
        seekBarTitleLabel.text = "Seek Bar"
        view.addSubview(seekBarTitleLabel)
        
        seekBar.frame = CGRect(x: 20, y: 570, width: view.frame.width - 40, height: 40)
        seekBar.minimumValue = 0
        seekBar.maximumValue = 100
        seekBar.isEnabled = false
        seekBar.addTarget(self, action: #selector(seekBarValueChanged(_:)), for: .valueChanged)
        view.addSubview(seekBar)
        
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
    
    @objc func seekBarValueChanged(_ sender: UISlider) {
        // Handle seek bar value change
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
    
    fileprivate func togglePlayPause() {
        // Handle play/pause button action
        device?.playingState(success: { state in
            if (state == .playing) {
                self.device?.pause(success: { succes in
                    print("Video paused")
                }, failure: { error in
                    print("failed to pause video")
                })
            } else if (state == .paused) {
                self.device?.play(success: { succes in
                    print("Video played")
                }, failure: { error in
                    print("failed to play video")
                })
            }
        }, failure: { error in
            print("Cannot get playing state")
        })
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        // Animate button tap
        animateButtonTap(sender)
        if sender == playButton {
            // Handle play button action
            device?.openBrowser(with: "https://www.netgem.com/fr", success: { launchSession in
                print("launch browser")
                self.showSnackbar("Browser launched")
                self.playPauseButton.isEnabled = true
                self.seekBar.isEnabled = true
            }, failure: { error in
                print("launch browser failed")
                self.showAlert("Launch browser failed", "Couldn't launch browser on the desired device")
            })
        } else if sender == connectButton {
            if let device = device {
                if device.isConnected {
                    device.disconnect()
                } else {
                    device.connect()
                }
            }
        } else if sender == videoButton {
            // Handle video button action
            playVideoMedia()
        } else if sender == playPauseButton {
            togglePlayPause()
        }
    }
    
    private func playVideoMedia() {
        guard let device = device else { return }
        // Use the MediaPlayerBuilder to play video media
        let mediaPlayerBuilder = device.makeMediaBuilder()
        // Set the media URL
        let mediaURL = URL(string: "http://www.connectsdk.com/files/8913/9657/0225/test_video.mp4")

        // Set other media properties if needed
        let iconURL = URL(string: "http://www.connectsdk.com/files/7313/9657/0225/test_video_icon.jpg")
        let title = "Sintel Trailer"
        let description = "Blender Open Movie Project"
        let mimeType = "video/mp4" // audio/* for audio files

        mediaPlayerBuilder
            .setMediaURL(mediaURL)
            .setIconURL(iconURL)
            .setTitle(title)
            .setDescription(description)
            .setMimeType(mimeType)
            .build(success: { mediaLaunchObject in
                // Handle success
                // Video playback started
                self.showSnackbar("Video playback started")
            }, failure: { error in
                // Handle failure
                // Video playback failed
                self.showAlert("Video Playback Failed", "Failed to play video on the connected device")
            })
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
            // Disable play/pause button and seek bar when disconnected
            self.playPauseButton.isEnabled = false
            self.seekBar.isEnabled = false
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
