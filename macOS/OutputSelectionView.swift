//
//  OutputSelectionView.swift
//  XLII (macOS)
//
//  Created by Morten Bertz on 2022/02/22.
//

import SwiftUI
import XLIICore

struct OutputSelectionView: View {
    
    @ObservedObject var holder:ConversionInputHolder
    
    @State var searchText:String = ""
    
    @State var outputs:[Output] = [Output]()
    @State var showSelected:Bool = false
    
    @AppStorage(UserDefaults.Keys.preferredBasesKey) var preferredBases:BasePreference = BasePreference.default
    
    var availableOutputs:[Output]{
        Output.builtin + preferredBases.outputs + Output.availableLocalizedOutputs
    }
    
    @Environment(\.undoManager) var undoManager
    
    @State private var sortOrder = [
        KeyPathComparator(\Output.description, comparator: .localizedStandard, order: .forward)
    ]

    var body: some View {
        
        VStack(spacing:0){
            tableView
            HStack(alignment: .center){
                Spacer()
                Button(action: {
                    let selected=holder.outputs
                    undoManager?.registerUndo(withTarget: holder, handler: {holder in
                        holder.outputs=selected
                    })
                    
                    holder.outputs.removeAll()
                }, label: {
                    Text("Deselect All")
                })
                Spacer()
                Toggle(isOn: $showSelected, label: {
                    showSelected ? Text("Show All") : Text("Show Selected")
                    
                }).toggleStyle(.button)
                Spacer()
                
            }.controlSize(.mini)
            .padding(.vertical, 6.0)
                .onChange(of: showSelected) {_, showSelected in
                    if showSelected{
                        outputs=availableOutputs.filter({holder.outputs.contains($0)})
                    }
                    else{
                        outputs=availableOutputs
                    }
                }
                
        }
    }
    
    
    var tableView: some View{
        
        Table(sortOrder: $sortOrder, columns: {
                        
            TableColumn(LocalizedStringKey("Selected"), content: {output in
                
                let binding=Binding<Bool>(get: {
                    holder.outputs.contains(output)
                }, set: {value, transaction in
                    if value == true{
                        holder.outputs.append(output)
                    }
                    else if let pos=holder.outputs.firstIndex(of: output){
                        holder.outputs.remove(at: pos)
                    }
                })
                
                Toggle(isOn: binding, label: {})
            }).width(min: 50, ideal: 50, max: 60)
            

            TableColumn(LocalizedStringKey("Name"), value: \.description)
        }, rows: {
            ForEach(outputs, id: \.id, content: {output in
                TableRow(output)
                    .itemProvider({
                    let itemProvider=NSItemProvider(item: output.rawValue as NSString, typeIdentifier: Output.dragType)
                    return itemProvider
                })
            })
        })
            
        .tableStyle(.inset(alternatesRowBackgrounds: true))
        .onAppear{
            outputs=availableOutputs
        }
        .searchable(text: $searchText, placement: .automatic, prompt: Text("Search"))
        .onChange(of: searchText, {_, text in
            if text.isEmpty{
                outputs=availableOutputs
            }
            else{
                let filtered=availableOutputs.filter({$0.description.localizedStandardContains(text.trimmingCharacters(in: .whitespaces))
                    
                })
                outputs=filtered
            }
        })
        
        .onChange(of: sortOrder,{_, sortOrder in
            outputs.sort(using: sortOrder)
        })
        .onChange(of: preferredBases, {_, p in
            outputs = Output.builtin + p.outputs + Output.availableLocalizedOutputs            
        })
    }
    
}

struct OutputSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        OutputSelectionView(holder:ConversionInputHolder())
    }
}
