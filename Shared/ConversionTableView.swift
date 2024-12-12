//
//  ConversionTableView.swift
//  XLII
//
//  Created by Morten Bertz on 2022/02/21.
//

import SwiftUI
import XLIICore

struct ConversionTableView: View {
    
    @ObservedObject var holder:ConversionInputHolder
    let displayItems:[Output]
    @State var draggedItem:Output? = nil
    
    let selectedConversion:NumericParsingResult
    
    @State var selectedDisplayItem:NumeralConversionHolder?
    @State var presentDetail:Bool = false
    
    @AppStorage(UserDefaults.Keys.daijiCompleteKey) var useDaijiForAll = false
    @AppStorage(UserDefaults.Keys.uppercaseCyrillicKey) var uppercaseCyrillic:Bool = false
    @AppStorage(UserDefaults.Keys.uppercaseNumericLettersKey) var uppercaseNumericLetters:Bool = true
    
    var context:NumeralConversionHolder.ConversionContext{
        var ctx=NumeralConversionHolder.ConversionContext()
        ctx.convertAllToDaiji=useDaijiForAll
        ctx.uppercaseCyrillic=uppercaseCyrillic
        ctx.uppercaseNumericBases=uppercaseNumericLetters
        return ctx
    }
    
    var body: some View {
        ScrollView{
            ForEach(displayItems, content: {outPut in
                let hh=NumeralConversionHolder(input: selectedConversion.value, output: outPut, originalText: selectedConversion.originalText, context: context)

                
                NumericalConversionView(holder: hh, isSelected: selectedDisplayItem == hh)

#if os(macOS)
                    .gesture(TapGesture(count: 2).onEnded({
                        guard selectedDisplayItem != nil,
                                hh.output.buttons != nil else{
                            return
                        }
                        presentDetail.toggle()
                    }))
#endif
                    .simultaneousGesture(TapGesture().onEnded({
                        selectedDisplayItem = hh
#if os(iOS)
                        if hh.output.buttons != nil{
                            presentDetail.toggle()
                        }
#endif
                    }))
                    .onDrag({
                        draggedItem = outPut
                        return hh.itemProvider
                    }, preview: {Text(hh.formattedOutput).font(.largeTitle)})
                    .onDrop(of: [Output.dragType], delegate: ContentViewReorderDropDelegate(item:outPut, items: $holder.outputs, draggedItem: $draggedItem))
                    .contextMenu(menuItems: {
                        Button(action: {
                            hh.speak()
                        }, label: {
                            Label(title: {Text("Speak")}, icon: {Image(systemName: "play.rectangle.fill")})
                        })
                        
                        copyButtons(holder: hh)
                        
                        if holder.outputs.contains(outPut){
                            Button(role: .destructive, action: {
                                withAnimation(.default) {
                                    guard let holderIDX=holder.outputs.firstIndex(of: outPut)
                                            else{return}
                                    holder.outputs.remove(at: holderIDX)
                                }
                            }, label: {
                                Label(title: {Text("Remove")}, icon: {Image(systemName: "trash")})
                            })
                        }
                        
                    })
                    
            })
        }.sheet(isPresented: $presentDetail, onDismiss: {
            
        }, content: {
            if let selectedDisplayItem=selectedDisplayItem {
                let holder=ConversionDetailHolder(item: selectedDisplayItem)
                ConversionDetailView()
                    .environmentObject(holder)
                    .toolbar(content: {
                        ToolbarItem(placement: .confirmationAction, content: {
                            Button(action: {
                                presentDetail.toggle()
                            }, label: {Text("Done")})
                        })
                    })
                    
            }
            else{
                EmptyView() //should never happen
            }
            
        })
    }
    
    @ViewBuilder
    func copyButtons(holder: NumeralConversionHolder) -> some View{
        
        let copy=Button(action: {
            Pasteboard.general.add(text: holder.formattedOutput)
            
        }, label: {Label(title: {Text("Copy")}, icon: {Image(systemName: "arrow.right.doc.on.clipboard")})})
        
        switch holder.output{
        case .arabisch:
            copy
            Button(action: {
                Pasteboard.general.add(text: String(holder.input))
            }, label: {Label(title: {Text("Copy Unformatted")}, icon: {Image(systemName: "arrow.right.doc.on.clipboard")})})
        default:
            copy
        }
    }
}

struct ConversionTableView_Previews: PreviewProvider {
    static var previews: some View {
        let holder=ConversionInputHolder()
        holder.input="93"
        
        return ConversionTableView(holder: holder,
                                   displayItems: [.japanisch_bank,
                                                  .numeric(base: 16)
                                                  ,.localized(locale: Locale(identifier: "el_GR"))],
                                   selectedConversion: holder.results.first ?? .empty)
        
    }
}


struct ContentViewReorderDropDelegate:DropDelegate{
    //https://avitsadok.medium.com/reorder-items-in-swiftui-lazyvstack-6d238efab04
    let item:Output
    @Binding var items:[Output]
    @Binding var draggedItem:Output?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        guard let draggedItem = self.draggedItem,
              items.contains(item),
              items.contains(draggedItem) else {
                  return DropProposal(operation: .forbidden)
        }
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem,
              items.contains(draggedItem) else {
                  return
              }
        if draggedItem != item,
           let from = items.firstIndex(of: draggedItem),
           let to = items.firstIndex(of: item){
            
            withAnimation(.default) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}
