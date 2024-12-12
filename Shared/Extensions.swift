//
//  Extensions.swift
//  RoemischeZahl
//
//  Created by Morten Bertz on 2021/09/14.
//

import Foundation
import CoreGraphics
import SwiftUI

extension NSUserActivity{
    enum ActivityTypes{
        static let conversionActivity = "com.telethon.XLII.conversionActivity"
    }
}

public extension Bundle{
    var applicationName:String{
        return (self.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? ""
    }
    var version:String{
        return self.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    var build:String{
        return self.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
}

extension CGRect:@retroactive Hashable{
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(size.width)
        hasher.combine(size.height)
    }
}


extension FocusedValues {
    var showingSidebar: Binding<Bool>? {
        get { self[ShowingSidebarKey.self] }
        set { self[ShowingSidebarKey.self] = newValue }
    }
    private struct ShowingSidebarKey: FocusedValueKey {
        typealias Value = Binding<Bool>
    }
}




