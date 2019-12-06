//
//  MLVision.swift
//  TransTravel
//
//  Created by Hesham Salama on 8/5/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import Foundation
import Firebase

class MLVision {
    
    static func parseTextFrom(image: UIImage, completion: @escaping (String?) -> Void) {
        
        let vision = Vision.vision()
        let textRecognizer = vision.onDeviceTextRecognizer()
        
        guard let image = image.fixedOrientation() else {
            print("Image is nil after fixing orientation")
            completion(nil)
            return
        }
        
        let visionImage = VisionImage(image: image)
        textRecognizer.process(visionImage) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let result = result else {
                completion(nil)
                return
            }
            
            let text = getTextSentencesSortedByPosition(visionText: result)
            completion(text)
        }
    }
    
    private static func getTextSentencesSortedByPosition(visionText: VisionText) -> String? {
        var dict = [VisionTextLine: CGFloat]()
        for block in visionText.blocks {
            for line in block.lines {
                if let cornerPoints = line.cornerPoints {
                    dict[line] = cornerPoints[0].cgPointValue.y
                }
            }
        }
        let lines = dict.keys.sorted(by: {dict[$0] ?? CGFloat.greatestFiniteMagnitude < dict[$1] ?? CGFloat.greatestFiniteMagnitude})
        var text = ""
        for line in lines {
            text += line.text + "\n"
        }
        return String(text.dropLast())
    }
}

extension UIImage {
    
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

