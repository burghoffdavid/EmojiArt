//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by David Burghoff on 17.08.20.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let store = EmojiArtDocumentStore(named: "Emoji Art")
    
    var body: some Scene {
        
        WindowGroup {
            EmojiArtDocumentChoser().environmentObject(store)
            //EmojiArtDocumentView(document: EmojiArtDocument())
        }
    }
}
