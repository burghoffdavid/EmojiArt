//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by David Burghoff on 12.03.21.
//

import SwiftUI

struct PaletteEditor: View {
    
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View{
        VStack(spacing: 0){
            ZStack{
                Text("PaletteEditor")
                    .font(.headline)
                    .padding()
                HStack{
                    Spacer()
                    Button(action: {
                        isShowing = false
                    }, label: {Text("Done")}).padding()
                }
                
            }
           
            Divider()
            Form{
                Section{
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began{
                            document.renamePalette(chosenPalette, to: paletteName)
                        }
                    })
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began{
                            document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                            emojisToAdd = ""
                        }
                    })
                }
                Section(header: Text("Remove Emoji")){
                    VStack{
                        Grid(chosenPalette.map{String($0)},id:\.self ){emoji in
                            Text(emoji)
                                .font(Font.system(size: fontSize))
                                .onTapGesture {
                                    chosenPalette = document.removeEmoji(emoji, fromPalette: chosenPalette)
                                }
                        }
                        .frame(height: height)
                    }
                }
            }
        }
        .onAppear{paletteName = document.paletteNames[chosenPalette] ?? ""}
    }
    //Mark: - Drawing Constants
    private var height: CGFloat{
        CGFloat((chosenPalette.count - 1 )/6) * 70 + 70
    }
    private let fontSize: CGFloat = 40
}
