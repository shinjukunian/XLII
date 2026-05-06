//
//  CommonPasteboard.swift
//  XLII
//
//  Created by Morten Bertz on 2022/02/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
typealias Pasteboard = NSPasteboard
typealias UIImage = NSImage
#else
import UIKit
typealias Pasteboard = UIPasteboard
#endif


extension Pasteboard{
    func add(text:String){
#if os(macOS)
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
#else
        UIPasteboard.general.string=text
#endif
    }
}

extension Image{
    #if os(macOS)
    init(nativeImage:NSImage){
        self.init(nsImage: nativeImage)
    }
    #else
    init(nativeImage:UIImage){
        self.init(uiImage: nativeImage)
    }
    #endif
}

#if os(macOS)
extension NSImage{
    convenience init(cgImage:CGImage){
        self.init(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
    }
    convenience init?(systemName:String) {
        self.init(systemSymbolName: systemName, accessibilityDescription: nil)
    }
    
    var cgImage:CGImage?{
        return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    static let importImageTypes = NSImage.imageTypes.compactMap { UTType($0) }
}
#endif
