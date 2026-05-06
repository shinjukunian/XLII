//
//  ConversionHolder.swift
//  RoemischeZahl
//
//  Created by Morten Bertz on 2021/09/14.
//

import Foundation
import SwiftUI
import AVFoundation

/// A class that provides formatted output of an arabic numer in a given format.
public class NumeralConversionHolder: Equatable{
    
    /// Various options to customize output
    public struct ConversionContext:Equatable{
        public var convertAllToDaiji = false
        public var uppercaseCyrillic = true
        public var useTitlo = true
        public var useCyrillicDiacriticNotation = false
        public var uppercaseNumericBases = true
        
        public init(){}
    }
    
    public static func == (lhs: NumeralConversionHolder, rhs: NumeralConversionHolder) -> Bool {
        lhs.input == rhs.input && lhs.output == rhs.output && lhs.originalText == rhs.originalText
    }
    
    
    public var formattedOutput:String = ""
    
    lazy var localizedSpellOutFormatter: NumberFormatter = {
        let f=NumberFormatter()
        f.numberStyle = .spellOut
        f.formattingContext = .standalone
        return f
    }()
    
    lazy var integerFormatter:NumberFormatter = {
        let f=NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits=0
        return f
    }()
    
    lazy var formatter=ExotischeZahlenFormatter()
    lazy var synthesizer = AVSpeechSynthesizer()
    
    public let noValidNumber=NSLocalizedString("Conversion not possible.", comment: "")
    let noInput = NSLocalizedString("No Input", comment: "")
    
    public let input:Int
    public let output:Output
    let originalText:String
    let context:ConversionContext
    
    
    /// Initialize the NumericalConversionHolder
    /// - Parameters:
    ///   - input: the input number
    ///   - output: the desired output
    ///   - originalText: the underlying text (if the number was derived from user input)
    ///   - context: formatting options
    public init(input:Int, output:Output, originalText:String, context:ConversionContext = ConversionContext()){
        self.input=input
        self.output=output
        self.originalText=originalText
        self.context=context
        self.formattedOutput =  parse()
    }
    
    func parse()->String{
        let zahl=input
        let formattedOutput:String
        switch output {
        case .römisch:
            formattedOutput = formatter.macheRömischeZahl(aus: zahl) ?? noValidNumber
        case .japanisch:
            formattedOutput = formatter.macheJapanischeZahl(aus: zahl) ?? noValidNumber
        case .arabisch:
            formattedOutput = integerFormatter.string(from: NSNumber(value: zahl)) ?? noValidNumber
        case .japanisch_bank:
            formattedOutput = formatter.macheJapanischeBankZahl(aus: zahl, einfach: !context.convertAllToDaiji) ?? noValidNumber
        case .babylonian:
            formattedOutput = formatter.macheBabylonischeZahl(aus: zahl) ?? noValidNumber
        case .aegean:
            formattedOutput = formatter.macheAegaeischeZahl(aus: zahl) ?? noValidNumber
        case .sangi:
            formattedOutput = formatter.macheSangiZahl(aus: zahl) ?? noValidNumber
        case .hieroglyph:
            formattedOutput = formatter.macheHieroglyphenZahl(aus: zahl) ?? noValidNumber
        case .suzhou:
            formattedOutput = formatter.macheSuzhouZahl(aus: zahl) ?? noValidNumber
        case .localized(let locale):
            localizedSpellOutFormatter.locale=locale
            formattedOutput = localizedSpellOutFormatter.string(from: NSNumber(value: zahl)) ?? noValidNumber
        case .numeric(let base):
            formattedOutput = String(zahl, radix: base, uppercase: context.uppercaseNumericBases)
        case .phoenician:
            formattedOutput = formatter.machePhoenizischeZahl(aus: zahl) ?? noValidNumber
        case .kharosthi:
            formattedOutput = formatter.macheKharosthiZahl(aus: zahl) ?? noValidNumber
        case .brahmi_positional:
            formattedOutput = BrahmiNumber(number: zahl, positional: true)?.brahmi ?? noValidNumber
        case .brahmi_traditional:
            formattedOutput = BrahmiNumber(number: zahl, positional: false)?.brahmi ?? noValidNumber
        case .glagolitic:
            formattedOutput = GlagoliticNumer(number: zahl)?.glacolitic ?? noValidNumber
        case .cyrillic:
            formattedOutput = formatter.macheKyrillischeZahl(aus: zahl, titlo: context.useTitlo, mitKreisen: context.useCyrillicDiacriticNotation, Großbuchstaben: context.uppercaseCyrillic) ?? noValidNumber
        case .geez:
            formattedOutput = GeezNumber(number: zahl)?.geez ?? noValidNumber
        case .sundanese:
            formattedOutput = SundaneseNumber(number: zahl).sundanese
        case .tibetan:
            formattedOutput = TibetanNumber(number: zahl).tibetan
        case .mongolian:
            formattedOutput = MongolianNumber(number: zahl).mongolian
        }
        return formattedOutput
        
    }
    
    /// speak the number, mostly useful for spell-out or roman numerals
    public func speak(){
        self.synthesizer.stopSpeaking(at: .immediate)
        let utterances = self.formatter.utterance(input: SpeechOutput(text: String(input), format: .arabisch), output: SpeechOutput(text: formattedOutput, format: output))
        for utterance in utterances {
            self.synthesizer.speak(utterance)
        }
    }
    
    
    @available(iOS 11.0, *)
    public var itemProvider:NSItemProvider{
        let provider=NSItemProvider(item: nil, typeIdentifier: Output.dragType)
        provider.registerObject(self.formattedOutput as NSString, visibility: .all)
        provider.registerItem(forTypeIdentifier: Output.dragType, loadHandler: {handler,object,e in
            guard let handler=handler else{
                return
            }
            handler(self.output.rawValue as NSString, nil)
            
        })
        return provider
    }
    
    
    
}
