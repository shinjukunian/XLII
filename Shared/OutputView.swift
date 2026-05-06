//
//  OutputView.swift
//  XLII
//
//  Created by Morten Bertz on 2022/02/21.
//

import SwiftUI
import XLIICore

struct OutputView: View {
    
    @ObservedObject var holder:ConversionInputHolder
    
    var body: some View {
        contentView
        
            
            .onChange(of: holder.results){
                if let arabic=holder.results.first(where: {$0.type.isDecimal}){
                    holder.selectedResult = arabic
                }else{
                    holder.selectedResult = holder.results.first ?? .empty
                }
            }

        
    }
    
    @ViewBuilder
    var contentView: some View{

        switch holder.state{
        case .empty:
            Divider().background(Color.accentColor)
            GroupBox{
                Text("Please enter a number")
            }
        case .invalid:
            Divider().background(Color.accentColor)
            GroupBox{
                Text("The input could not be parsed.")
            }
        case .overflow:
            Divider().background(Color.accentColor)
            GroupBox{
                Text("The input is too large to be represented.")
            }
        case .valid:
            switch holder.results.count{
            case 0:
                Divider().background(Color.accentColor)
                GroupBox{
                    Text("The input could not be parsed.")
                }
            case 1:
                
                Text(verbatim: holder.selectedResult.type.description)
                    .font(.caption2)
            case 2...3:
                picker
                    .labelsHidden()
                    .pickerStyle(.segmented)
            default:
                picker.fixedSize(horizontal: true, vertical: false)
                    .pickerStyle(.menu)
            }
            
            
            Divider().background(Color.accentColor)
            let items:[Output] = {
                let items:[Output]
                if holder.selectedResult.type.isDecimal{
                    items = [Output.currentLocale] +  holder.outputs
                }
                else{
                    items = [.arabisch, Output.currentLocale] +  holder.outputs
                }
                return items.filter({output in
                    return output != holder.selectedResult.type
                })
            }()
            ConversionTableView(holder: holder, displayItems: items, selectedConversion: holder.selectedResult)
        }
    }
        
    var picker:some View{
        Picker(selection: $holder.selectedResult, content: {
            ForEach(holder.results, id: \.self, content: {result in
                Text(verbatim: result.type.description)
                    .tag(result)
            })
        }, label: {
            Text("Result:")
        })
    }
}

struct OutputView_Previews: PreviewProvider {
    static var previews: some View {
        let holder=ConversionInputHolder()
        holder.input="10"
        return ContentView(holder: holder)
    }
}
