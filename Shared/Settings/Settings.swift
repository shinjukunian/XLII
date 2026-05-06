//
//  Settings.swift
//  XLII
//
//  Created by Morten Bertz on 2022/02/21.
//

import SwiftUI

#if os(iOS)
import MessageUI
#endif

struct SettingsView: View {
    
    @AppStorage(UserDefaults.Keys.daijiCompleteKey) var daijiForAll:Bool = false
    @Environment(\.dismiss) var dismiss
    @AppStorage(UserDefaults.Keys.allowBasesBesides10Key) var otherBases:Bool = true
    
    @AppStorage(UserDefaults.Keys.uppercaseCyrillicKey) var uppercaseCyrillic:Bool = false
    
    @AppStorage(UserDefaults.Keys.uppercaseNumericLettersKey) var uppercaseNumericLetters:Bool = true
    
    @AppStorage(UserDefaults.Keys.preferredBasesKey) var historyData = HistoryPreference.empty.rawValue
    
    
    @Environment(\.openURL) var openURL
    @State var showBaseSelection:Bool = false
    
    var body: some View {
        form
    }
    
    var form: some View{
        Form{
            Section(content: {
                Toggle(isOn: $daijiForAll, label: {Text("Convert all characters to  Daiji")})
                    .help(Text("Convert all characters to Daiji. This usage is archaic."))
                
                Toggle(isOn: $uppercaseCyrillic, label: {Text("Use uppercase letters for Cyrillic conversion")})
                
                Toggle(isOn: $uppercaseNumericLetters, label: {Text("Use uppercase letters for conversion to higher numeric bases")})
                
                
                Toggle(isOn: $otherBases, label: {Text("Allow bases other than 10 for numeric input")})
                    .help(Text("Parse numeric input for other bases, e.g. binary or hexadecimal."))

                if otherBases{
#if os(iOS)
                    NavigationLink(destination: {
                        BaseSelectionView()
                    }, label: {
                        Text("Select Bases")
                    })
#else
                    Button(action: {
                        showBaseSelection.toggle()
                    }, label: {
                        Label(title: {Text("Select Bases")}, icon: {
                            
                        })
                    }).sheet(isPresented: $showBaseSelection, content: {
                        BaseSelectionView().frame(minWidth: 300, minHeight: 300)
                    })
#endif
                }
            
            }, header: {
                Text("Formatting")
            })
            
#if os(iOS)
            Section(content: {
                NavigationLink(destination: {
                    
                    MailView(result: .constant(nil))
                    
                }, label: {
                    Text("Feedback")
                })
                
                .disabled(!MFMailComposeViewController.canSendMail())
                
            }, header: {
                Text("Feedback")
            })
            .navigationBarTitleDisplayMode(.inline)
            
#endif
            Section(content: {
                Button(role: .destructive, action: {
                    historyData = HistoryPreference.empty.rawValue
                }, label: {
                    Label(title: {
                        Text("Delete History")
                    }, icon: {})
                })
            }, header: {Text("History")})
        }
        .navigationTitle(Text("Settings"))
#if os(iOS)
        .toolbar(content: {
            ToolbarItem(placement: .confirmationAction, content: {
                if #available(iOS 26.0, *) {
                    Button(role: .confirm, action: {
                        dismiss()
                    }, label: {Text("Done")})
                } else {
                    Button(action: {
                        dismiss()
                    }, label: {Text("Done")})
                }
               
            })
        })
#endif
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
