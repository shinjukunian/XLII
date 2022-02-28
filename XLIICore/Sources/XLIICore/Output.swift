//
//  Output.swift
//  XLII
//
//  Created by Morten Bertz on 2022/02/20.
//

import Foundation

public enum Output: Identifiable, Codable, Equatable, RawRepresentable, Hashable, CustomStringConvertible{
    
    public typealias RawValue = String
    
    case römisch
    case japanisch
    case arabisch
    case japanisch_bank
    case babylonian
    case aegean
    case sangi
    case hieroglyph
    case suzhou
    case phoenician
    case kharosthi
    case brahmi_traditional
    case brahmi_positional
    case glagolitic
    case cyrillic
    case geez
    
    case numeric(base:Int)
    
    case localized(locale:Locale)
    
    public static let currentLocale = Output.localized(locale: Locale.current)
    public static let dragType = "com.mihomaus.xlii.outputType"

    public static let builtin:[Output] = [.römisch, .japanisch, .japanisch_bank, .suzhou, .babylonian, .aegean, .sangi, .hieroglyph, .phoenician, .kharosthi, brahmi_traditional, .brahmi_positional, .glagolitic, .cyrillic, .geez]
    
    public init?(rawValue: String) {
        switch rawValue{
        case "roman":
            self = .römisch
        case "japanese":
            self = .japanisch
        case "arabic":
            self = .arabisch
        case "japanese_banking":
            self = .japanisch_bank
        case "babylonian":
            self = .babylonian
        case "aegean":
            self = .aegean
        case "sangi":
            self = .sangi
        case "hieroglyph":
            self = .hieroglyph
        case "suzhou":
            self = .suzhou
        case "phoenician":
            self = .phoenician
        case "kharosthi":
            self = .kharosthi
        case "brahmi_traditional":
            self = .brahmi_traditional
        case "brahmi_positional":
            self = .brahmi_positional
        case "glagolitic":
            self = .glagolitic
        case "cyrillic":
            self = .cyrillic
        case "geez":
            self = .geez
        case _ where rawValue.hasPrefix("numeric_base"):
            let components=rawValue.split(separator: "|")
            guard components.count == 2,
                  let base=Int(components[1])
            else {return nil}
            
            self = .numeric(base: base)
        case _ where rawValue.hasPrefix("localized"):
            let components=rawValue.split(separator: "|")
            guard components.count == 2
            else {return nil}
            let locale=Locale(identifier: String(components[1]))
            self = .localized(locale: locale)
        default:
            return nil
        }
    }
    
    public init?(output:ExotischeZahlenFormatter.NumericalOutput){
        switch output.locale{
        case .japanese:
            self = .japanisch
        case .roman:
            self = .römisch
        case .suzhou:
            self = .suzhou
        case .hieroglyph:
            self = .hieroglyph
        case .aegean:
            self = .aegean
        case .phoenician:
            self = .phoenician
        case .kharosthi:
            self = .kharosthi
        case .brahmi(let positional):
            self = positional ? .brahmi_positional : .brahmi_traditional
        case .glagolitic:
            self = .glagolitic
        case .cyrillic:
            self = .cyrillic
        case .geez:
            self = .geez
            
        }
    }
    
    public var rawValue: String{
        switch self {
        case .römisch:
            return "roman"
        case .japanisch:
            return "japanese"
        case .arabisch:
            return "arabic"
        case .japanisch_bank:
            return "japanese_banking"
        case .babylonian:
            return "babylonian"
        case .localized(let locale):
            return "localized|\(locale.identifier)"
        case .aegean:
            return "aegean"
        case .sangi:
            return "sangi"
        case .hieroglyph:
            return "hieroglyph"
        case .suzhou:
            return "suzhou"
        case .phoenician:
            return "phoenician"
        case .kharosthi:
            return "kharosthi"
        case .numeric(let base):
            return "numeric_base|\(base)"
        case .brahmi_positional:
            return "brahmi_positional"
        case .brahmi_traditional:
            return "brahmi_traditional"
        case .glagolitic:
            return "glagolitic"
        case .cyrillic:
            return "cyrillic"
        case .geez:
            return "geez"
        }
    }
    
    
    public var id: String {
        return rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .römisch, .japanisch, .japanisch_bank, .arabisch, .babylonian, .aegean, .sangi, .hieroglyph, .suzhou, .phoenician, .kharosthi, .brahmi_positional, .brahmi_traditional, .glagolitic, .cyrillic, .geez:
            hasher.combine(rawValue)
        case .localized(_), .numeric(_):
            hasher.combine(rawValue)
        }
    }
    
    public var description: String{
        switch self {
        case .römisch:
            return NSLocalizedString("Roman", tableName: nil, bundle: .module, value: "Roman", comment: "Roman Numeral Output")
        case .japanisch:
            return NSLocalizedString("Japanese", tableName: nil, bundle: .module, value: "Japanese", comment: "Japanese Numeral Output")
        case .arabisch:
            return NSLocalizedString("Arabic Numerals", tableName: nil, bundle: .module, value: "Arabic Numerals", comment: "Arabic Numeral Output")
        case .japanisch_bank:
            return NSLocalizedString("Japanese (大字)", tableName: nil, bundle: .module, value: "Japanese (大字)", comment: "Arabic Numeral Output")
        case .babylonian:
            return NSLocalizedString("Babylonian Cuneiform", tableName: nil, bundle: .module, value: "Babylonian Cuneiform", comment: "Babylonian Cuneiform")
        case .aegean:
            return NSLocalizedString("Aegean", tableName: nil, bundle: .module, value: "Aegean", comment: "Aegean Output")
        case .sangi:
            return NSLocalizedString("Counting Rods (籌)", tableName: nil, bundle: .module, value: "Counting Rods (籌)", comment: "Counting Rods")
        case .hieroglyph:
            return NSLocalizedString("Egyptian Numerals (Hieroglyphs)", tableName: nil, bundle: .module, value: "Egyptian Numerals (Hieroglyphs)", comment: "Egytpian Output")
        case .suzhou:
            return NSLocalizedString("Suzhou (蘇州碼子)", tableName: nil, bundle: .module, value: "Suzhou (蘇州碼子)", comment: "Suzhou Output")
        case .phoenician:
            return NSLocalizedString("Phoenician", tableName: nil, bundle: .module, value: "Phoenician", comment: "Phoenician alphabet")
        case .kharosthi:
            return NSLocalizedString("Kharoṣṭhī", tableName: nil, bundle: .module, value: "Kharoṣṭhī", comment: "Kharoṣṭhī alphabet")
        case .brahmi_traditional:
            return NSLocalizedString("Brahmi", tableName: nil, bundle: .module, value: "Brahmi", comment: "Brahmi alphabet")
        case .brahmi_positional:
            return NSLocalizedString("Brahmi (positional)", tableName: nil, bundle: .module, value: "Brahmi (positional)", comment: "Brahmi alphabet")
        case .glagolitic:
            return NSLocalizedString("Glagolitic", tableName: nil, bundle: .module, value: "Glagolitic", comment: "Glagolitic alphabet")
        case .cyrillic:
            return NSLocalizedString("Cyrillic", tableName: nil, bundle: .module, value: "Cyrillic", comment: "Cyrillic alphabet")
        case .geez:
            return NSLocalizedString("Geez", tableName: nil, bundle: .module, value: "Geʽez", comment: "Cyrillic alphabet")
        case .localized(let locale):
            if let language=locale.languageCode{
                return Locale.current.localizedString(forLanguageCode: language) ?? locale.identifier
            }
            else{
                return Locale.current.localizedString(forIdentifier: locale.identifier) ?? locale.identifier
            }
        case .numeric(let base):
            switch base{
            case 2:
                return NSLocalizedString("Binary", tableName: nil, bundle: .module, value: "Binary", comment: "binary number")
            case 3:
                return NSLocalizedString("Ternary", tableName: nil, bundle: .module, value: "Ternary", comment: "binary number")
            case 4:
                return NSLocalizedString("Quaternary", tableName: nil, bundle: .module, value: "Quaternary", comment: "binary number")
            case 5:
                return NSLocalizedString("Quinary", tableName: nil, bundle: .module, value: "Quinary", comment: "binary number")
            case 6:
                return NSLocalizedString("Senary", tableName: nil, bundle: .module, value: "Senary", comment: "binary number")
                
            case 8:
                return NSLocalizedString("Octal", tableName: nil, bundle: .module, value: "Octal", comment: "Octal number")
            case 10:
                return NSLocalizedString("Decimal", tableName: nil, bundle: .module, value: "Decimal", comment: "Decimal number")
            case 16:
                return NSLocalizedString("Hexadecimal", tableName: nil, bundle: .module, value: "Hexadecimal", comment: "Hexadecimal number")
            case 12:
                return NSLocalizedString("Duodecimal", tableName: nil, bundle: .module, value: "Duodecimal", comment: "Duodecimal number")
            case 20:
                return NSLocalizedString("Vigesimal", tableName: nil, bundle: .module, value: "Vigesimal", comment: "Vigesimal number")
            default:
                return String(format: NSLocalizedString("Numeric Base %i", tableName: nil, bundle: .module, value: "Numeric Base %i", comment: "Other base"), base)
            }
        }
    }
    
    
    
}



