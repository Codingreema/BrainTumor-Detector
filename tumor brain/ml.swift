//
//  ml.swift
//  tumor brain
//
//  Created by Rimah on 30/05/1448 AH.
//

import CoreML
import Vision
import UIKit

struct ClassificationResult {
    let label: String
    let confidence: Float
}

enum TumorClassifier {
    static func classify(_ image: UIImage,
                         completion: @escaping (ClassificationResult?) -> Void) {
        guard let cgImage = image.cgImage,
              let coreModel = try? tumor(configuration: MLModelConfiguration()).model,
              let vnModel = try? VNCoreMLModel(for: coreModel) else {
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: vnModel) { request, _ in
            let top = (request.results as? [VNClassificationObservation])?.first
            DispatchQueue.main.async {
                completion(top.map { ClassificationResult(label: $0.identifier,
                                                          confidence: $0.confidence) })
            }
        }
        request.imageCropAndScaleOption = .centerCrop

        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
            try? handler.perform([request])
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ ui: UIImage.Orientation) {
        switch ui {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
