//
//  TimeView.swift
//  Widget-iOSExtension
//
//  Created by Morten Bertz on 2022/02/25.
//

import SwiftUI
import WidgetKit

struct TimeView: View{
    
    let formattedEntry:FormattedDate
    
    
    let formatter:DateFormatter = {
        let f=DateFormatter()
        return f
    }()
    
    var body: some View{
        HStack(alignment: .center, spacing: 2.0){
            
            let separator = Text(verbatim: formattedEntry.timeSeparator)
                
            let prefers24HTime = prefers24HTime
            Text(verbatim: formattedEntry.formattedText(component: .hour, use24h: prefers24HTime))
                .layoutPriority(10)
            
            separator
            
            Text(verbatim: formattedEntry.formattedText(component: .minute))
                .layoutPriority(10)
            
            if prefers24HTime == false{
                switch formattedEntry.hour{
                case 0...12:
                    Text(formatter.amSymbol)
                default:
                    Text(formatter.pmSymbol)
                }
            }
           
        }

    }
    
    var prefers24HTime:Bool{
        let components=DateComponents(calendar: .autoupdatingCurrent, timeZone: nil, year: 2022, month: 2, day: 22, hour: 19, minute: 1, second: 0)
        guard let date=components.date else{
            return false
        }
        let formatted=date.formatted(date: .omitted, time: .shortened)
        return formatted.localizedStandardContains("m") == false
        
    }
}

struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        let intent=ConfigurationIntent()
        intent.output = .octal
        let components=DateComponents(calendar: .autoupdatingCurrent, timeZone: nil, year: 2022, month: 2, day: 22, hour: 4, minute: 1, second: 0)
        
        return TimeView(formattedEntry: DateEntry(date: components.date ?? .now, configuration: intent).formattedDate ?? .dummy)
            .previewContext(WidgetPreviewContext.init(family: .systemSmall))
            .preferredColorScheme(.light)
            .environment(\.locale, .init(identifier: "de_DE"))
           
    }
}
