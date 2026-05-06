//
//  ContentView.swift
//  Shared
//
//  Created by Miho on 2021/04/29.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct ContentView: View {
    
    struct URLItem:Identifiable,Equatable,Hashable{
        let url:URL
        var id: String{
            return url.absoluteString
        }
    }
    
    @StateObject var holder=ConversionInputHolder()
    @State private var presentingCamera = false
    
    @AppStorage(UserDefaults.Keys.showSideBarKey) var showSideBar:Bool = false
    
    @State var droppedURL:URLItem? = nil
    
    var body: some View{
        InputView(holder: holder)
            .toolbar(content: {
                
            })
//            .frame(minWidth:250, maxWidth: 350)
            .padding(.top)
            .edgesIgnoringSafeArea([.bottom])
        
        .inspector(isPresented: $showSideBar, content: {
            OutputSelectionView(holder: holder)
//                .frame(minWidth:200, maxWidth: 400)
        })

        .toolbar(content: {
            ToolbarItem(placement: .automatic, content: {
                CameraButton(showCamera: $presentingCamera)
            })
            ToolbarItem(placement: .automatic, content: {
                SidebarButton(showSideBar: $showSideBar)
            })
        })
        .touchBar(content: {
            CameraButton(showCamera: $presentingCamera)
            SidebarButton(showSideBar: $showSideBar)
        })
        .sheet(isPresented: $presentingCamera, content: {
            CameraView()
        })
        .focusedValue(\.showingSidebar, $showSideBar)
        .onOpenURL(perform: {url in
            if let number=url.numberFromDeepLink{
                holder.input=String(number)
            }
            else if url.isFileURL,
                    let uti=try? url.resourceValues(forKeys: Set([URLResourceKey.contentTypeKey])).contentType,
                    NSImage.importImageTypes.contains(uti){
                self.droppedURL=URLItem(url: url)
            }
        })
        .sheet(item: $droppedURL, content: {item in
            if let image=NSImage(contentsOf: item.url){
                StaticImageAnalysisView(image: image, outputType: .japanisch)
                    .environmentObject(holder)
                    .environmentObject(Recognizer())
            }
        })
        //        .importsItemProviders(NSImage.importImageTypes, onImport: {providers in
        //            guard let imageProvider=providers.first(where: {$0.hasRepresentationConforming(toTypeIdentifier: UTType.image.identifier)})else{
        //                return false
        //            }
        //
        //
        //            return true
        //        })
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let holder=ConversionInputHolder()
        holder.input="m"
        return ContentView(holder: holder)
    }
}



