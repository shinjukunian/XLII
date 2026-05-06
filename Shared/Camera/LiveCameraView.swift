//
//  LiveCameraView.swift
//  XLII
//
//  Created by Morten Bertz on 2022/03/06.
//

import SwiftUI
import XLIICore

struct LiveCameraView: View {
    
    @Binding var convert:Bool
    @Binding var outputType:Output
    @State var lastScaleValue: CGFloat = 1.0
    @State var zoomScale: CGFloat = 2.0
    @EnvironmentObject var recognizer:Recognizer
    @Binding var selectedTextElement:Recognizer.TextElement?
    
    @State var textElements:[Recognizer.TextElement] = []
    
    var body: some View {
        ZStack{
            previewView
            CameraResultView(textElements: textElements, convert: convert, outputType: outputType, aspectRatio: recognizer.videoAspectRatio, ROI: recognizer.useROI ? recognizer.defaultRegionOfInterest : nil, selectedElement: $selectedTextElement)

        }
        .ignoresSafeArea()
        .overlay(alignment: .top, content: {
            Text(recognizer.state.prompt)
                .padding(3)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 5)
        })
        
        .gesture(MagnificationGesture().onChanged { val in
            let delta = val / self.lastScaleValue
            self.lastScaleValue = val
            let newScale = self.zoomScale * delta
            self.zoomScale = newScale
            
        }.onEnded { val in
            self.lastScaleValue = 1.0
        })
        .task {
            for await result in recognizer.stream{
                self.textElements = result
            }
        }
        
    }
    var previewView:some View{
        let h=PreviewHolder(recognizer: recognizer, zoomScale: $zoomScale)
        let width=CGFloat(700)
        #if os(macOS)
        return h.frame(minWidth: width, maxWidth: .infinity, minHeight: width/recognizer.videoAspectRatio, maxHeight: .infinity, alignment: .center)
        #else
        return h
        #endif
            
    }
}

struct LiveCameraView_Previews: PreviewProvider {
    static var previews: some View {
        LiveCameraView(convert: .constant(true), outputType: .constant(.japanisch), selectedTextElement: .constant(nil)).environmentObject(Recognizer())
    }
}
