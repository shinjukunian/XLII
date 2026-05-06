//
//  OutputPreference.swift
//  XLII
//
//  Created by Morten Bertz on 2022/02/23.
//

import Foundation
import XLIICore

struct OutputPreference:RawRepresentable, Sendable{
    
    typealias RawValue = String
    
    let outputs:[Output]
    
    init?(rawValue: String) {
        let values=rawValue.split(separator: "%").compactMap({Output(rawValue: String($0))})
        self.outputs=values
    }
    
    init(outputs:[Output]){
        self.outputs=outputs
    }
    
    var rawValue: String{
        return self.outputs.map({$0.rawValue}).joined(separator: "%")
    }
    
    static let `default` = OutputPreference(outputs:[.römisch, .japanisch, .suzhou, .hieroglyph, .babylonian, .numeric(base: 16)])
}
