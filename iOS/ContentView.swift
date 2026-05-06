//
//  ContentView.swift
//  XLII (iOS)
//
//  Created by Morten Bertz on 2022/02/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var holder=ConversionInputHolder()
    
    @State var showLanguageSelection = false
    @State var showSettings = false
    @State private var presentingCamera = false
    
    @Environment(\.horizontalSizeClass) var horizontalSize:UserInterfaceSizeClass?
    
    @AppStorage(UserDefaults.Keys.showSideBarKey) var showSideBar:Bool = true
    
    var body: some View {
        content
            
            .ignoresSafeArea(.container, edges: [.bottom])
            
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar(content: {
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    if horizontalSize == .regular{
                        SidebarButton(showSideBar: $showSideBar)
                    }
                    else{
                        EmptyView()
                    }
                })
                ToolbarItem(placement: .primaryAction, content: {
                    CameraButton(showCamera: $presentingCamera)
                })
                
            })
            .fullScreenCover(isPresented: $presentingCamera, content: {
                CameraView().environmentObject(holder)
            })
            .sheet(isPresented: $showSettings, content: {
                NavigationStack{
                    SettingsView()  
                }
            })
            .onAppear{
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .onOpenURL(perform: {url in
                guard let number=url.numberFromDeepLink else{
                    return
                }
                holder.input=String(number)
            })
    }
    
    @ViewBuilder
    var settingsButton: some View{
        Button(action: {
            showSettings=true
        }, label: {
            Label(title: {Text("Show Settings")}, icon: {Image(systemName: "gearshape.2")})
        })//.disabled(holder.numericInput == nil)
    }
    
    @ViewBuilder
    var content: some View{
        if horizontalSize == .regular && showSideBar == true{
            
            HStack{
                InputView(holder: holder)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            settingsButton
                        })
                    })
                    .padding(.vertical)
                    
                Divider().background(Color.accentColor)
                OutputSelectionView(holder: holder)
            }
            

            
        }
        else{
            InputView(holder: holder)
                .toolbar(content: {
                    
                    ToolbarItemGroup(placement: .navigationBarLeading, content: {
                      
                        Button(action: {
                            showLanguageSelection=true
                        }, label: {
                            Image(systemName: "plus.rectangle")
                        }).disabled(holder.results.isEmpty)
                    })
                    
                    ToolbarItemGroup(placement: .navigationBarLeading, content: {
                        Spacer()
                        settingsButton
                    })
                    
                })
                .padding(.vertical)
                .sheet(isPresented: $showLanguageSelection, onDismiss: {}, content: {
                    NavigationStack{
                        OutputSelectionView(holder: holder)
                            .navigationTitle(Text("Output Selection"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                })
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let holder=ConversionInputHolder()
        holder.input="m"
        return ContentView(holder: holder)
            .previewInterfaceOrientation(.portrait)
    }
}
