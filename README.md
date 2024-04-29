# ConnectSDK iOS Sample

ConnectSDK iOS Sample is an example project demonstrating the usage of the ConnectSDKWrapper library to integrate LG WebOS devices into iOS applications.

## Overview

This sample project showcases the following features:

- Discovering LG WebOS devices on the network.
- Displaying discovered devices in a table view.
- Connecting to discovered devices.
- Opening and closing the browser on connected devices.
- Handling device connections and disconnections.

## Getting Started

To run the example project, follow these steps:

1. Clone or download the ConnectSDK iOS Sample project from [GitHub](https://github.com/simbaste/ConnectSDK-iOS-Sample).
2. Open the project in Xcode.
3. Build and run the project on a physical iOS device or simulator.

## Usage

### DevicesViewController

- The `DevicesViewController` is the main view controller responsible for discovering and displaying LG WebOS devices.
- It includes a table view to display discovered devices.
- Tapping on a device in the table view navigates to the `DeviceDetailViewController` to show more details and perform actions.

### DeviceDetailViewController

- The `DeviceDetailViewController` displays detailed information about a selected device, such as its name, description, and connection status.
- It provides buttons to play content on the connected device and connect/disconnect from the device.
- The `playButton` demonstrates how to open the browser on the connected device to play content.

## Requirements

- Xcode 12.0+
- Swift 5.0+
- iOS 12.0+ (Simulator or physical device)

## Installation

1. Clone or download the ConnectSDKWrapper library from [Bitbucket](https://bitbucket.org/netgem/connectsdkwrapper-ios.git).
2. Integrate the ConnectSDKWrapper library into your own project using Swift Package Manager or manual installation.
3. Follow the instructions provided in the README of the ConnectSDKWrapper repository.

## License

ConnectSDK iOS Sample is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
