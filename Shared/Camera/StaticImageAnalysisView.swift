//
//  StaticImageAnalysisView.swift
//  XLII
//
//  Created by Morten Bertz on 2022/03/06.
//

import SwiftUI
import XLIICore

struct StaticImageAnalysisView: View {
    
    @State var selectedTextElement:Recognizer.TextElement? = nil
    
    @EnvironmentObject var recognizer:Recognizer
    
    let image:UIImage
    @State var convert:Bool = false
    @State var outputType:Output
    
    @State var textElements=[Recognizer.TextElement]()
    @Environment(\.dismiss) var dismiss
    @AppStorage(UserDefaults.Keys.preferredBasesKey) var preferredBases:BasePreference = BasePreference.default
    @EnvironmentObject var holder:ConversionInputHolder
    
    
    var body: some View {
        StaticImageAnalysisContentView(selectedElement: $selectedTextElement, elements: textElements, output: outputType, image: image, convert:convert)
        .safeAreaInset(edge: .bottom, content: {
            ZStack{
                Rectangle().fill(.regularMaterial)
                HStack{
                    
                    Toggle(isOn: $convert, label: {
                        Text("Convert All")
                    }).fixedSize()
                    
                    Picker(selection: $outputType, content: {
                        ForEach(Output.builtin + preferredBases.outputs, content: {output in
                            Text(output.description).tag(output)
                        })
                    }, label: {}).pickerStyle(.menu).fixedSize()
                    
                    Spacer()
                    
                    Button(role: .cancel ,action: {
                        if let selectedTextElement=selectedTextElement{
                            holder.input=selectedTextElement.text
                        }
                        dismiss()
                        
                        
                    }, label: {
                        Text("Dismiss")
                    })
                }
                .padding()
            }.fixedSize(horizontal: false, vertical: true)
        })
        .task {
            guard let image=self.image.cgImage else{
                return
            }
            let elements = await recognizer.analyze(image: image)
            self.textElements = elements
        }

    }
}

struct StaticImageAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        let image=UIImage(named: "ReceiptSwiss.jpg")!
        let recognizer=Recognizer()
        
        return StaticImageAnalysisView(image: image, convert: false, outputType: .japanisch)
            .environmentObject(recognizer)
    }
}
