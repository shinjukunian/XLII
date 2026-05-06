//
//  DateView.swift
//  Widget-iOSExtension
//
//  Created by Morten Bertz on 2022/02/25.
//

import SwiftUI
import WidgetKit

struct DateView: View{
    
    struct DateFormat{
        let order:[Calendar.Component]
        let seperator:String
        
        static let `default` = DateFormat(order: [.year, .month, .day], seperator: "/")
    }
    
    let formattedEntry:FormattedDate
    
    
    var body: some View{
        HStack(alignment: .center, spacing: 2.0){
            let format=self.timeFormat
            
            let separator = Text(verbatim: format.seperator)

            Text(verbatim: formattedEntry.formattedText(component: format.order[0]))
            
            separator
            
            Text(verbatim: formattedEntry.formattedText(component: format.order[1]))
            separator
            Text(verbatim: formattedEntry.formattedText(component: format.order[2]))
            
        }
    }
    
    var timeFormat:DateFormat{
        let formatstring="yyyyMMdd"
        if let localizedFormat = DateFormatter.dateFormat(fromTemplate: formatstring, options: 0, locale: .current),
           let yearRange=localizedFormat.range(of: "yyyy"),
           let monthRange=localizedFormat.range(of: "MM"),
           let dayRange=localizedFormat.range(of: "dd"){
            let order=zip([Calendar.Component.year, .month, .day], [yearRange,monthRange,dayRange]).sorted(by: {c1,c2 in
                return c1.1.lowerBound < c2.1.lowerBound
            })
            let seperator:String
            if let firstRange=order.first?.1.upperBound,
               let s=localizedFormat.prefix(through: firstRange).last{
                seperator = String(s)
            }
            else{
                seperator="/"
            }
            
            
            
            return DateFormat(order: order.map({$0.0}), seperator: seperator)
        }
        
        return .default
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        let intent=ConfigurationIntent()
        intent.output = .roman
        return DateView(formattedEntry: DateEntry(date: .now, configuration: intent).formattedDate ?? .dummy)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
