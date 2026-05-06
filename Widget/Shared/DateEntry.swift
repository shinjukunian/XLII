//
//  DateEntry.swift
//  Widget-iOSExtension
//
//  Created by Morten Bertz on 2022/02/25.
//

import Foundation
import XLIICore
import SwiftUI
import WidgetKit

struct DateEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    
    let requiredComponents:Set<Calendar.Component> = Set([.minute,.month,.hour,.day, .year])
    
    var output:Output{
        return Output(output: configuration.output) ?? .römisch
    }
    
    var formattedDate:FormattedDate?{
        var calendar=Calendar.autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        
        let components=calendar.dateComponents(requiredComponents, from: date)
        guard let hour=components.hour,
              let minute=components.minute,
              let year=components.year,
              let month = components.month,
              let day=components.day
        else{
            return nil
        }
        
        return FormattedDate(year: year, month: month, day: day, hour: hour, minute: minute, output: output)
    }
    
    var showDate:Bool{
        return configuration.showDate?.boolValue ?? true
    }
    
    var deepLinkURL:URL{
        guard let formattedDate=formattedDate else{
            return URL.deeplinkURL(number: 42)
        }
        return URL.deeplinkURL(number: formattedDate.minute)
    }
}

struct FormattedDate{
    
    let timeSeparator = ":"
    let dateSeperator = "/"
    
    let hour:Int
    let minute:Int
    let day:Int
    let month:Int
    let year:Int
    let output:Output
    
    let ctx:NumeralConversionHolder.ConversionContext
    
    @MainActor static let dummy = FormattedDate(year: 2022, month: 2, day: 25, hour: 12, minute: 12, output: .römisch)
    
    init(year:Int, month:Int, day:Int, hour:Int, minute:Int, output:Output){
        self.hour=hour
        self.minute=minute
        self.output=output
        self.year=year
        self.day=day
        self.month=month
        var ctx=NumeralConversionHolder.ConversionContext()
        ctx.uppercaseCyrillic = UserDefaults.shared.bool(forKey: UserDefaults.Keys.uppercaseCyrillicKey)
        ctx.convertAllToDaiji = UserDefaults.shared.bool(forKey: UserDefaults.Keys.daijiCompleteKey)
        self.ctx=ctx
    }
    
    var time:String{
        let time = [hour,minute].map({n->String in
            let h=NumeralConversionHolder(input: n, output: output , originalText: "")
            return h.formattedOutput
        })
            .joined(separator: timeSeparator)
        return time
    }
    
    var date:String{
        let date=[year,month,day].map({n->String in
            let h=NumeralConversionHolder(input: n, output: output , originalText: "")
            return h.formattedOutput
        }).joined(separator: dateSeperator)
        return date
    }
    
    func formattedText(component:Calendar.Component, use24h:Bool = false)->String{
        switch component{
        case .minute:
            let output=NumeralConversionHolder(input: minute, output: output, originalText: "")
            if output.formattedOutput == output.noValidNumber{
                return String(minute)
            }
            else{
                return output.formattedOutput
            }
            
        case .month:
            return NumeralConversionHolder(input: month, output: output, originalText: "").formattedOutput
        case .hour where use24h == true:
            return NumeralConversionHolder(input: hour, output: output, originalText: "").formattedOutput
        case .hour where use24h == false:
            return NumeralConversionHolder(input: hour > 12 ? hour - 12 : hour, output: output, originalText: "").formattedOutput
        case .year:
            let output=NumeralConversionHolder(input: year, output: output, originalText: "")
            if output.formattedOutput == output.noValidNumber{
                return String(year)
            }
            else{
                return output.formattedOutput
            }
            
        case .day:
            return NumeralConversionHolder(input: day, output: output, originalText: "").formattedOutput
        default:
            return ""
        }
    }
    
    func attributedDate(textAttributes:AttributeContainer = .init(), seperatorAttributes:AttributeContainer = .init([.foregroundColor: Color.green]) )->AttributedString{
        let seperator=AttributedString(dateSeperator, attributes: seperatorAttributes)
        let year=NumeralConversionHolder(input: year, output: output , originalText: "")
        let yearAtt=AttributedString(year.formattedOutput, attributes:textAttributes)
        let month=NumeralConversionHolder(input: month, output: output , originalText: "")
        let monthAtt=AttributedString(month.formattedOutput, attributes:textAttributes)
        let day=NumeralConversionHolder(input: day, output: output , originalText: "")
        let dayAtt=AttributedString(day.formattedOutput, attributes:textAttributes)
        
        return yearAtt + seperator + monthAtt + seperator + dayAtt
       
    }
    
}


