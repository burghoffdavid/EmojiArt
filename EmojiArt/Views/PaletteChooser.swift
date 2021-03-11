//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by David Burghoff on 11.03.21.
//

import SwiftUI

struct PaletteChooser: View {
    @Binding var chosenPalette: String
    
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: { chosenPalette = document.palette(after: chosenPalette)},
                onDecrement: { chosenPalette = document.palette(before: chosenPalette) },
                label: {
                    EmptyView()
            })
            Text(document.paletteNames[chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(chosenPalette: Binding.constant(""), document: EmojiArtDocument())
    }
}
