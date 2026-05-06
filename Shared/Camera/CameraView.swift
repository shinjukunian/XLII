//
//  CameraView.swift
//  RoemischeZahl
//
//  Created by Morten Bertz on 2021/05/02.
//

import SwiftUI
import Combine
import XLIICore

struct CameraView: View {
    
    @StateObject var recognizer=Recognizer()
    
    @State var outputType:Output = .japanisch
    
    @State var convert:Bool = true

    @State var selectedTextElement:Recognizer.TextElement?
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var holder:ConversionInputHolder
    
    var body: some View {
        
        if let image=recognizer.image{
            StaticImageAnalysisView(image: image, outputType: outputType)
                .environmentObject(recognizer)
            
        }
        else{
            LiveCameraView(convert: $convert, outputType: $outputType, selectedTextElement: $selectedTextElement)
                .environmentObject(recognizer)
                .overlay(alignment: .bottom, content: {
                    VStack{
                        CameraShutterButton(action: {
                            recognizer.captureImage()
                        })
                        CameraControllsView(useROI: $recognizer.useROI, convert: $convert, outputType: $outputType, onDismissPressed: {
                            
                            if let selectedTextElement = selectedTextElement {
                                holder.input = selectedTextElement.text
                            }
//                            else if let first=recognizer.foundElements.first(where: {$0.type.isNumber}){
//                                holder.input = first.text
//                            }
                            dismiss()
                        })
                    }
                    
                })
        }
        

    }
    
    
    
    
    
    
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
