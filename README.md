# 🧠 BrainTumor-Detector

An iOS app that analyzes brain MRI scans **on-device** and classifies them as *tumor* or *no tumor*, with a confidence score. Built with SwiftUI, Core ML and Vision. The interface is in Arabic.

> ⚠️ This is an educational project, **not** a medical diagnosis tool.

## Features

- Pick an MRI image from the photo library or take a photo with the camera
- Runs a custom Core ML image classifier locally, with no internet and no data leaving the device
- Shows the result (possible tumor / no tumor) with a confidence percentage

## How it works

1. The selected image is passed to `TumorClassifier` (`ml.swift`).
2. A `VNCoreMLRequest` runs the bundled `tumor.mlmodel` on a background queue, center-cropping the image to the model's input size and respecting its orientation.
3. The top `VNClassificationObservation` is returned to the SwiftUI view, which shows the label and confidence.

## Tech stack

- **SwiftUI** for the interface, with `PhotosPicker` and a `UIImagePickerController` camera wrapper
- **Core ML** and **Vision** for on-device image classification, using a custom image classifier (`tumor.mlmodel`)

## Run it

1. Open the `tumor brain` project folder in Xcode.
2. Build and run on an iPhone or the iOS Simulator (camera requires a real device).

## Author

**Rimah Aldaghfaq**: [Portfolio](https://codingreema.github.io) · [LinkedIn](https://www.linkedin.com/in/rimahaldaghfaq)
