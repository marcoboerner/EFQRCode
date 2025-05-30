//
//  EFImageMode.swift
//  EFQRCode
//
//  Created by EyreFree on 2017/4/11.
//
//  Copyright (c) 2017-2024 EyreFree <eyrefree@eyrefree.org>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import CoreGraphics

/// Options to specify how watermark position and size for QR code.
public enum EFImageMode: CaseIterable {
    /// The option to scale the watermark to fit the size of QR code by changing the aspect ratio of the watermark if necessary.
    case scaleToFill
    /// The option to scale the watermark to fit the size of the QR code by maintaining the aspect ratio. Any remaining area of the QR code uses the background color.
    case scaleAspectFit
    /// The option to scale the watermark to fill the size of the QR code. Some portion of the watermark may be clipped to fill the QR code.
    case scaleAspectFill
    
    // MARK: - Utilities
    
    /// Calculates and returns the area in canvas where the image is going to be in this mode.
    /// - Parameters:
    ///   - imageSize: size of the watermark image to place in the canvas.
    ///   - canvasSize: size of the canvas to place the image in.
    /// - Returns: the area where the image is going to be according to the watermark mode.
    public func rectForContent(ofSize imageSize: CGSize,
                               inCanvasOfSize canvasSize: CGSize) -> CGRect {
        let size = canvasSize
        var finalSize: CGSize = size
        var finalOrigin: CGPoint = CGPoint.zero
        let imageSize: CGSize = imageSize
        switch self {
        case .scaleAspectFill:
            let scale = max(size.width / imageSize.width,
                            size.height / imageSize.height)
            finalSize = CGSize(width: imageSize.width * scale,
                               height: imageSize.height * scale)
            finalOrigin = CGPoint(x: (size.width - finalSize.width) / 2.0,
                                  y: (size.height - finalSize.height) / 2.0)
        case .scaleAspectFit:
            let scale = max(imageSize.width / size.width,
                            imageSize.height / size.height)
            finalSize = CGSize(width: imageSize.width / scale,
                               height: imageSize.height / scale)
            finalOrigin = CGPoint(x: (size.width - finalSize.width) / 2.0,
                                  y: (size.height - finalSize.height) / 2.0)
        case .scaleToFill:
            break
        }
        return CGRect(origin: finalOrigin, size: finalSize)
    }
    
    public func imageForContent(ofImage image: CGImage, inCanvasOfRatio canvasRatio: CGSize) throws -> CGImage {
        let imageWidth: CGFloat = image.width.cgFloat
        let imageHeight: CGFloat = image.height.cgFloat
        
        if imageWidth / imageHeight == canvasRatio.width / canvasRatio.height { return image }
        
        let widthRatio: CGFloat = imageWidth / canvasRatio.width
        let heightRatio: CGFloat = imageHeight / canvasRatio.height
        switch self {
        case .scaleToFill:
            let newSize: CGSize = {
                if widthRatio > heightRatio {
                    return CGSize(width: imageHeight / canvasRatio.height * canvasRatio.width, height: imageHeight)
                } else {
                    return CGSize(width: imageWidth, height: imageWidth / canvasRatio.width * canvasRatio.height)
                }
            }()
            return try image.resize(to: newSize)
        case .scaleAspectFit:
            let newSize: CGSize = {
                if widthRatio > heightRatio {
                    return CGSize(width: imageWidth, height: imageWidth / canvasRatio.width * canvasRatio.height)
                } else {
                    return CGSize(width: imageHeight / canvasRatio.height * canvasRatio.width, height: imageHeight)
                }
            }()
            return try image.clipAndExpandingTransparencyWith(rect: CGRect(
                x: -(imageWidth.cgFloat - newSize.width) / 2,
                y:  -(imageHeight.cgFloat - newSize.height) / 2,
                width: newSize.width,
                height: newSize.height
            ))
        case .scaleAspectFill:
            let newSize: CGSize = {
                if widthRatio < heightRatio {
                    return CGSize(width: imageWidth, height: imageWidth / canvasRatio.width * canvasRatio.height)
                } else {
                    return CGSize(width: imageHeight / canvasRatio.height * canvasRatio.width, height: imageHeight)
                }
            }()
            return try image.clipAndExpandingTransparencyWith(rect: CGRect(
                x: -(imageWidth.cgFloat - newSize.width) / 2,
                y:  -(imageHeight.cgFloat - newSize.height) / 2,
                width: newSize.width,
                height: newSize.height
            ))
        }
    }
}
