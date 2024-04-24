//
//  ViewController.swift
//  ConnectSDK-iOS-App
//
//  Created by Stephane SIMO MBA on 24/04/2024.
//

import UIKit
import ConnectSDKApi
import ConnectSDK

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource,
                      UINavigationControllerDelegate,
                      ConnectSDKDelegate {
    
    let tableView = UITableView()
    var discoveredDevices: [ConnectableDevice] = [] // Propriété pour stocker les appareils découverts
    var loaderView: UIView? // Vue pour l'écran de chargement
    var loadingLabel: UILabel?
    
    var connectSDKApi = ConnectSDKApi()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Connect SDK Devices"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        // Ajouter un label pour afficher le message de recherche en cours
        loadingLabel = UILabel()
        loadingLabel?.text = "Recherche en cours..."
        loadingLabel?.textAlignment = .center
        loadingLabel?.isHidden = true
        view.addSubview(loadingLabel!)
        
        connectSDKApi.delegate = self
        findDevice()
    }

    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
        // Positionner la table et le label
        tableView.frame = view.bounds
        loadingLabel?.frame = CGRect(x: 0, y: view.bounds.height / 2 - 20, width: view.bounds.width, height: 40)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let device = discoveredDevices[indexPath.row]
        cell.textLabel?.text = device.friendlyName // Afficher le nom de l'appareil dans la cellule
        return cell
    }

    // MARK: - ConnectSDK Api Delegate

    func findDevice() {
        print("findDevice() called")
        showLoader()
        connectSDKApi.searchForDevices()
    }
    
    func didFindDevices(_ devices: [ConnectableDevice]) {
        print("find devices ==> \(devices)")
        hideLoader() // Cacher l'écran de chargement une fois que les appareils sont trouvés
        discoveredDevices = devices
        tableView.reloadData() // Mettre à jour la table avec les appareils découverts
    }
    
    func didFailWithError(_ error: any Error) {
        print("Failed to find devices ==> \(error)")
        hideLoader() // Cacher l'écran de chargement en cas d'erreur
        // Afficher un message d'erreur à l'utilisateur
    }
    
    func device(didConnected device: ConnectableDevice) {
        print("device connected ==> \(device)")
    }
    
    func device(didDisconnected device: ConnectableDevice, withError error: any Error) {
        print("device disconnected ==> \(device) with error ==> \(error)")
    }
    
    // MARK: - Loader Methods

    func showLoader() {
        loaderView = UIView(frame: view.bounds)
        loaderView?.backgroundColor = UIColor(white: 0, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loaderView!.center
        loaderView?.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.addSubview(loaderView!)

        loadingLabel?.isHidden = false // Afficher le message de "Recherche en cours"
    }

    func hideLoader() {
        loaderView?.removeFromSuperview()
        loaderView = nil
        loadingLabel?.isHidden = true
    }

}
