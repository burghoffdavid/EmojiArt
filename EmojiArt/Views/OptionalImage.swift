//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by David Burghoff on 11.03.21.
//

import SwiftUI


struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}



