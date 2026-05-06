//
//  WidgetView.swift
//  Widget-iOSExtension
//
//  Created by Morten Bertz on 2022/02/25.
//

import SwiftUI
import XLIICore
import WidgetKit

struct WidgetView: View {
    
    let entry:DateEntry
    
    
    var body: some View {
        
        HStack{
            if let formatted=entry.formattedDate{
                
                VStack(spacing: 2){
                    HStack{
                        Text(verbatim: entry.output.description)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.accent)
                        Spacer()
                    }
               
                    VStack(alignment: .center){
                        
                        if #available(iOS 26.0, macOS 26.0, *) {
                            GlassEffectContainer(content: {
                                timeStack(formatted: formatted)
                                dateStack(formatted: formatted)
                            })
                            
                        } else {
                            timeStack(formatted: formatted)
                            dateStack(formatted: formatted)
                        }
                    }
                   
                }
                
            }
            else{
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .multilineTextAlignment(.center)
                    .font(.headline)
                
            }
        
        }
        .containerBackground(for: .widget){
            Color.widgetBackground
        }
        .widgetURL(entry.deepLinkURL)
        
    }
    
    @ViewBuilder
    func timeStack(formatted:FormattedDate)-> some View{
        VStack{
            TimeView(formattedEntry: formatted)
                .font(.title2)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .foregroundStyle(.accent)
            if entry.showDate{
                Text(entry.date.formatted(date: .omitted, time: .shortened)).font(.caption).foregroundColor(.primary)
            }
            
        }
        .frame(maxWidth: .infinity).padding(5)
            .background(content: {
                RoundedRectangle(cornerRadius: 8).fill(Color.widgetBackground)
            })
    }
    
    @ViewBuilder
    func dateStack(formatted:FormattedDate)-> some View{
        VStack{
            DateView(formattedEntry: formatted)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .foregroundStyle(.accent)
            if entry.showDate{
                Text(entry.date.formatted(date: .numeric, time: .omitted)).font(.caption).foregroundColor(.primary)
            }
        }.frame(maxWidth: .infinity).padding(5).background(content: {
            RoundedRectangle(cornerRadius: 8).fill(Color.widgetBackground
            )
        })
    }
    
    
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let intent=ConfigurationIntent()
        intent.output = .aegean
        let components=DateComponents(calendar: .autoupdatingCurrent, timeZone: nil, year: 2022, month: 12, day: 19, hour: 23, minute: 50, second: 0)
        
        return WidgetView(entry: .init(date: components.date ?? .now, configuration: intent))
            .preferredColorScheme(.dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .environment(\.locale, .init(identifier: "de_DE"))
    }
}
