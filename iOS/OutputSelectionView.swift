//
//  OutputSelectionView.swift
//  XLII
//
//  Created by Morten Bertz on 2022/02/20.
//

import SwiftUI
import Algorithms
import XLIICore

struct OutputSelectionView: View {
    
    struct OutputSelectionViewSection{
        let title:String
        let outputs:[Output]
        
        static let builtinTitle = NSLocalizedString("XLII", comment: "")
        static let systemTitle = NSLocalizedString("System", comment: "")
        static let numericTitle = NSLocalizedString("Numeric", comment: "")
        
        static let titles:[String] = [OutputSelectionViewSection.builtinTitle, OutputSelectionViewSection.numericTitle, OutputSelectionViewSection.systemTitle]
    }
    
    @ObservedObject var holder:ConversionInputHolder
    @Environment(\.dismiss) var dismiss
    @Environment(\.isPresented) var isPresented
    
    @State var showSelected:Bool = false
    
    @State var selection:Set<Output> = Set<Output>()
    
    @State var searchText:String = ""
    @State var displayInputs:[OutputSelectionViewSection] = [OutputSelectionViewSection]()
    
    @AppStorage(UserDefaults.Keys.preferredBasesKey) var preferredBases:BasePreference = BasePreference.default
    
    init(holder:ConversionInputHolder){
        self.holder=holder
        self.selection=Set(holder.outputs)
    }
    
    
    
    var availableDisplayOutputs:[OutputSelectionViewSection]{
         return
        [OutputSelectionViewSection(title: OutputSelectionViewSection.builtinTitle, outputs: Output.builtin),
         OutputSelectionViewSection(title: OutputSelectionViewSection.numericTitle, outputs: preferredBases.outputs),
            OutputSelectionViewSection(title: OutputSelectionViewSection.systemTitle, outputs: Output.availableLocalizedOutputs)
         ]
    }
    
    
    var body: some View {
        
        List(selection: $selection){
            
            ForEach(displayInputs, id: \.outputs, content: {list in
                self.section(outPuts: list.outputs, title: list.title)
            })
            
        }
        .searchable(text: $searchText, placement: .automatic, prompt: Text("Search"))
        .onChange(of: selection, perform: {selection in
            let present=Set(holder.outputs)
            let inserted=selection.subtracting(present)
            let deleted=present.subtracting(selection)
         
            let new=holder.outputs.filter({present in
                deleted.contains(present) == false
            }) + Array(inserted)
            
            withAnimation{
                holder.outputs = new
            }
        })
        
        .toolbar(content: {
            
            ToolbarItem(placement: .confirmationAction, content: {
                if isPresented{
                    Button(action: {
                        dismiss()
                    }, label: {Text("Done")})
                }
                else{
                    EmptyView()
                }
            })
            
            ToolbarItem(placement: .automatic, content: {
                Toggle(isOn: $showSelected, label: {
                    Label(title: {Text("Show Selected")}, icon: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    })
                })
            })
            
        })
        
        .environment(\.editMode, .constant(.active))
        .onAppear(perform: {
            self.selection=Set(holder.outputs)
            self.displayInputs=availableDisplayOutputs
        })
        .onSubmit(of: .search, {
            
        })
        .onChange(of: searchText, perform: {text in
            self.searchTextChanged(text: text)
        })
        .onChange(of: showSelected, perform: {showSelected in
            withAnimation{
                if showSelected{
                    self.displayInputs = zip(availableDisplayOutputs,OutputSelectionViewSection.titles) .map{(list,title) in
                        let filtered=list.outputs.filter({holder.outputs.contains($0)})
                        return OutputSelectionViewSection(title: title, outputs: filtered)
                    }.filter({$0.outputs.isEmpty == false})
                }
                else{
                    self.displayInputs=availableDisplayOutputs
                }
            }
        })
        
        
    }
    
    
    func searchTextChanged(text:String){
        withAnimation{
            self.displayInputs = zip([Output.builtin, preferredBases.outputs, Output.availableLocalizedOutputs], OutputSelectionViewSection.titles).map({(outputs, title)in
                let filtered=outputs.filter({$0.description.localizedStandardContains(text.trimmingCharacters(in: .whitespaces))
                })
                return OutputSelectionViewSection(title: title, outputs: filtered)
            })
            .filter({$0.outputs.isEmpty == false})
        }
    }
    
    func section(outPuts:[Output], title:String)->some View{
        Section(content: {
            ForEach(outPuts, id: \.self, content: {output in
                HStack{
                    Text(output.description)
                    Spacer()
                    
                }.onDrag({
                    let provider=NSItemProvider(item: output.rawValue as NSString, typeIdentifier: Output.dragType)
                    return provider
                })
            })
            
        }, header: {
            Text(title)
        })
    }
}

struct OutputSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        OutputSelectionView(holder: ConversionInputHolder())
    }
}
