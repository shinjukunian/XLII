//
//  RoemischeZahl.swift
//  RoemischeZahl
//
//  Created by Miho on 2021/04/29.
//

import Foundation
import AVFoundation

/// A class that converts between different (exotic) numerical formats
public final class ExotischeZahlenFormatter:Sendable{
    
    /// A struct that holds the parsed input
    public struct NumericalOutput: Equatable{
        /// The detected input type
        public enum InputLocale: Equatable{
            case roman
            case japanese
            case suzhou
            case hieroglyph
            case aegean
            case phoenician
            case kharosthi
            case brahmi(positional:Bool)
            case glagolitic
            case cyrillic
            case geez
            case sangi
            case sundanese
            case tibetan
            case mongolian
        }
        /// The parsed input as `Int`
        public let value:Int
        /// The detected number format
        public let locale:InputLocale
    }
    
    
    public init(){}
    
    
    /// Converts a number to a Roman numeral
    /// - Parameter Zahl: a number between 1 and 1000000000
    /// - Returns: a roman numeral or nil of conversion fails.
    public func macheRömischeZahl(aus Zahl:Int)->String?{
        
        guard Zahl > 0, Zahl < 1_000_000_000 else {
            return nil
        }
        
        let zehner = Zehner(Zahl: Zahl)
        let einser = Einer(Zahl: Zahl)
        let hunderter = Hunderter(Zahl: Zahl)
        let tausender = Tausender(Zahl: Zahl)
        
        let zehnerRömisch = zehner.römisch
        let einserRömisch = einser.römisch
        let hunderterRömisch = hunderter.römisch
        
        return tausender.römisch + hunderterRömisch + zehnerRömisch + einserRömisch
    }
    
    
    /// Convert a number to Japanese
    /// - Parameter Zahl: a number
    /// - Returns: a Japanese numeral
    public func macheJapanischeZahl(aus Zahl:Int)->String?{
        
        switch Zahl{
        case ..<0:
            return nil
        case 0:
            return "〇"
        case 0...:
            let z:[AlsJapanischeZahl]=[TenQuadrillion(Zahl: Zahl),
                                       OneTrillion(Zahl: Zahl),
                                       HundertMillionen(Zahl: Zahl),
                                       ZehnTausender(Zahl: Zahl),
                                       JapanischeTausender(Zahl: Zahl),
                                       Hunderter(Zahl: Zahl),
                                       Zehner(Zahl: Zahl),
                                       Einer(Zahl: Zahl)]
            return z.reduce("", {r, z in
                r+z.japanisch
            })
        default:
            return nil
        }
    }
    
    /// Convert to Kharosthi
    /// - Parameter Zahl: a number between 1 and 1000000
    /// - Returns: a Kharosthi number
    public func macheKharosthiZahl(aus Zahl:Int)->String?{
        guard (1..<1_000_000).contains(Zahl) else{
            return nil
        }
        return KharosthiNumber(number: Zahl)?.kharosthi
    }
    
    /// Convert to Suzhou
    /// - Parameter Zahl: a number
    /// - Returns: a Suzhou number
    public func macheSuzhouZahl(aus Zahl:Int)->String?{
        guard Zahl >= 0 else {
            return nil
        }
        let suzhou=SuzhouZahl(Zahl: Zahl)
        return suzhou.suzhou
    }
    
    
    /// Convert to a Japanese financial number
    /// - Parameters:
    ///   - Zahl: a number
    ///   - einfach: if true, only common conversion to financial characters will be performed (e.g. 10: 十 to 拾). If false, all characters will be converted. The latter usage is archaic.
    /// - Returns: A formatted japanese financial number
    public func macheJapanischeBankZahl(aus Zahl:Int, einfach:Bool)->String?{
        if Zahl == 0 {
            return "〇"
        }
        
        guard Zahl > 0, Zahl < Int.max else {
            return nil
        }
        let z:[AlsJapanischeBankZahl]=[TenQuadrillion(Zahl: Zahl),
                                       OneTrillion(Zahl: Zahl),
                                       HundertMillionen(Zahl: Zahl),
                                       ZehnTausender(Zahl: Zahl),
                                       JapanischeTausender(Zahl: Zahl),
                                       Hunderter(Zahl: Zahl),
                                       Zehner(Zahl: Zahl),
                                       Einer(Zahl: Zahl)]
        if einfach{
            return z.reduce("", {r, z in
                r+z.japanisch_Bank_einfach
            })
        }
        else{
            return z.reduce("", {r, z in
                r+z.japanisch_Bank
            })
        }
    }
    
    /// Convert to Babylonian
    /// - Parameter Zahl: a number > 0
    /// - Returns: a babylonian number
    public func macheBabylonischeZahl(aus Zahl:Int)->String?{
        return BabylonischeZahl(Zahl: Zahl)?.babylonisch
    }
    
    
    /// Convert to Phoenician
    /// - Parameter Zahl: a number between 1 and 1000
    /// - Returns: a phoenician number or nil if the conversion fails
    public func machePhoenizischeZahl(aus Zahl:Int)->String?{
        return PhoenizianFormatter(number: Zahl)?.phoenician
    }
    
    /// Convert to Aegean
    /// - Parameter Zahl: a number between 1 and 100000
    /// - Returns: a formatted Aegean number
    public func macheAegaeischeZahl(aus Zahl:Int)->String?{
        return AegeanZahl(number: Zahl)?.aegean
    }
    
    /// Convert to Brahmi
    /// - Parameters:
    ///   - Zahl: a number > 0
    ///   - positional: use positional notation (true) opr traditional notation (false)
    /// - Returns: a formatted Brahmi number
    public func macheBrahmiZahl(aus Zahl:Int, positional:Bool)-> String?{
        return BrahmiNumber(number: Zahl, positional: positional)?.brahmi
    }
    
    /// Convert to Sanghi (Counting Rods)
    /// - Parameter Zahl: a number > 0
    /// - Returns: a formatted Sanghi number
    public func macheSangiZahl(aus Zahl:Int)->String?{
        return SangiNumber(number: Zahl).sangi
    }
    
    /// Convert to Egyptian Hieroglyphs
    /// - Parameter Zahl: a number between 1 and 10,000,000
    /// - Returns: a hieroglyph number
    public func macheHieroglyphenZahl(aus Zahl:Int)->String?{
        return HieroglyphenZahl(Zahl: Zahl)?.hieroglyph
    }
    
    /// Convert to Glagolitic
    /// - Parameter Zahl: a number between 1 and 4000
    /// - Returns: a glagolitic numeral
    public func macheGlagolitischeZahl(aus Zahl:Int)->String?{
        return GlagoliticNumer(number: Zahl)?.glacolitic
    }
    
    /// Convert to Sundanese
    /// - Parameter Zahl: a number
    /// - Returns: a Sundanese number
    public func macheSundaneseZahl(aus Zahl:Int)->String?{
        return SundaneseNumber(number: Zahl).sundanese
    }
    
    /// Convert to Tibetan
    /// - Parameter Zahl: a number
    /// - Returns: a tibetan number
    public func macheTibetanischeZahl(aus Zahl:Int)->String?{
        return TibetanNumber(number: Zahl).tibetan
    }
    
    /// Convert to Mongolian
    /// - Parameter Zahl: a number
    /// - Returns: a formatted mongolian number
    public func macheMongolischeZahl(aus Zahl:Int)->String?{
        return MongolianNumber(number: Zahl).mongolian
    }
    
    
    /// Parse text to extract a number
    /// - Parameter text: the input text
    /// - Returns: `NumericalOutput`, a struct which contains the detected number (as `Int`) and the detected format. Returns `nil` if no number could be detected.
    public func macheZahl(aus text:String)->NumericalOutput?{
        switch text {
        case _ where text.potenzielleRömischeZahl:
            if let zahl = self.macheZahl(römisch: text){
                return NumericalOutput(value: zahl, locale: .roman)
            }
        case _ where text.potenzielleJapanischeZahl:
            if let zahl=self.macheZahl(japanisch: text){
                return NumericalOutput(value: zahl, locale: .japanese)
            }
        case _ where text.potenzielleSuzhouZahl:
            if let zahl=SuzhouZahl(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .suzhou)
            }
        case _ where text.potenzielleHieroglypheZahl:
            if let zahl=HieroglyphenZahl(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .hieroglyph)
            }
        case _ where text.potenziellAegaeischeZahl:
            if let zahl=AegeanZahl(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .aegean)
            }
        case _ where text.potentiellePhoenizischeZahl:
            if let zahl=PhoenizianFormatter(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .phoenician)
            }
        case _ where text.potentielleKharosthiZahl:
            if let zahl=KharosthiNumber(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .kharosthi)
            }
        case _ where text.potentielleBrahmiZahl:
            if let zahl=BrahmiNumber(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .brahmi(positional: zahl.positional))
            }
        case _ where text.potentielleGlagoliticZahl:
            if let zahl=GlagoliticNumer(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .glagolitic)
            }
        case _ where text.potentielleKyrillischeZahl:
            if let zahl=CyrillicNumber(text: text){
                return NumericalOutput(value: zahl.arabic, locale: .cyrillic)
            }
        case _ where text.potentielleGeezZahl:
            if let zahl=GeezNumber(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .geez)
            }
        case _ where text.potentielleSangiZahl:
            if let zahl=SangiNumber(text: text){
                return NumericalOutput(value: zahl.arabic, locale: .sangi)
            }
        case _ where text.potentielleSundaneseZahl:
            if let zahl=SundaneseNumber(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .sundanese)
            }
        case _ where text.potentielleTibetanZahl:
            if let zahl=TibetanNumber(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .tibetan)
            }
        case _ where text.potentielleMongolischeZahl:
            if let zahl=MongolianNumber(string: text){
                return NumericalOutput(value: zahl.arabic, locale: .mongolian)
            }
        default:
            return nil
        }
        return nil
    }
    
    /// Convert to Cyrillic
    /// - Parameters:
    ///   - Zahl: a number
    ///   - titlo: use a Titlo, a small overbar that indicates the numeral. This is often used to differentiate numerals from regular text, since both use the same characters
    ///   - mitKreisen: for numbers > 10,000, use decorators to indicate multiplication (`true`). If `false`, use the thousands multiplier ҂. This limits the output range to < 1,000,000.
    ///   - Großbuchstaben: use uppercase (true) or lowercase Cyrillic letters
    /// - Returns: a fomatted Cyrillic number
    public func macheKyrillischeZahl(aus Zahl:Int, titlo:Bool, mitKreisen:Bool, Großbuchstaben:Bool)->String?{
        guard let parser=CyrillicNumber(number: Zahl, useMultiplicationModifiers: mitKreisen) else{
            return nil
        }
        switch (titlo, Großbuchstaben){
        case (true, true):
            return parser.cyrilicUsingTitlo.uppercased()
        case (true,false):
            return parser.cyrilicUsingTitlo.lowercased()
        case (false,true):
            return parser.cyrillic.uppercased()
        case (false,false):
            return parser.cyrillic.lowercased()
        }
    }
    
    
    /// Convert to Ge'ez
    /// - Parameter Zahl: a number > 0
    /// - Returns: a fomatted Ge'ez number
    public func macheGeezZahl(aus Zahl:Int)->String?{
        return GeezNumber(number: Zahl)?.geez
    }
    
    
    func macheZahl(römisch Zahl:String)->Int?{
        let einser=Einer(römischeZahl: Zahl)
        var restZahl=Zahl.replacingOccurrences(of: einser.römisch, with: "", options: [.backwards, .caseInsensitive, .anchored], range: nil)
        let zehner=Zehner(römischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: zehner.römisch, with: "", options: [.backwards, .caseInsensitive, .anchored], range: nil)
        let hunderter=Hunderter(römischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: hunderter.römisch, with: "", options: [.backwards, .caseInsensitive, .anchored], range: nil)
        let tausender=Tausender(römischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: tausender.römisch, with: "", options: [.backwards, .caseInsensitive, .anchored], range: nil)
        
        if restZahl.count > 0{
            return nil
        }
        
        
        return tausender.arabisch + hunderter.arabisch + zehner.arabisch + einser.arabisch
    }
    
    fileprivate func macheZahl(japanisch Zahl:String)->Int?{
        let einser=Einer(japanischeZahl: Zahl)
        var restZahl=Zahl.replacingOccurrences(of: einser.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: einser.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        let zehner=Zehner(japanischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: zehner.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: zehner.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: zehner.japanisch_Bank_einfach, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        let hunderter=Hunderter(japanischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: hunderter.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: hunderter.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: hunderter.japanisch_Bank_einfach, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        let tausender=JapanischeTausender(japanischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: tausender.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: tausender.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: tausender.japanisch_Bank_einfach, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        let zehnTausender=ZehnTausender(japanischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: zehnTausender.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: zehnTausender.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: zehnTausender.japanisch_Bank_einfach, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        let hundertMillionen=HundertMillionen(japanischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: hundertMillionen.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: hundertMillionen.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: hundertMillionen.japanisch_Bank_einfach, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        let trillion=OneTrillion(japanischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: trillion.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: trillion.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: trillion.japanisch_Bank_einfach, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        let tenQuadrillion=TenQuadrillion(japanischeZahl: restZahl)
        restZahl=restZahl.replacingOccurrences(of: tenQuadrillion.japanisch, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: tenQuadrillion.japanisch_Bank, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        restZahl=restZahl.replacingOccurrences(of: tenQuadrillion.japanisch_Bank_einfach, with: "", options: [.backwards, .caseInsensitive, .anchored, .widthInsensitive], range: nil)
        
        if restZahl.count > 0{
            return nil
        }
        
        
        return tenQuadrillion.arabisch + trillion.arabisch + hundertMillionen.arabisch + zehnTausender.arabisch + tausender.arabisch + hunderter.arabisch + zehner.arabisch + einser.arabisch
    }
    
    
    func utterance(input:SpeechOutput, output:SpeechOutput)->[AVSpeechUtterance]{
        
        let textZumSprechen=NSLocalizedString("is:", comment: "utterance string")
        let u2 = AVSpeechUtterance(string: String(textZumSprechen))
        u2.voice=Output.arabisch.voice
        u2.rate=AVSpeechUtteranceDefaultSpeechRate
        u2.postUtteranceDelay=0.1
        
        return input.utterances + [u2] + output.utterances
    }
    
    
//    /// Speak a number and its conversion
//    /// - Parameters:
//    ///   - input: The `SpeechInput` for the input number
//    ///   - output: The `SpeechInput` for the output number
//    public func speak(input:SpeechOutput, output:SpeechOutput){
//        self.synthesizer.stopSpeaking(at: .immediate)
//        
//        self.utterance(input: input, output: output).forEach({u in
//            self.synthesizer.speak(u)
//        })
//    }
    
}
