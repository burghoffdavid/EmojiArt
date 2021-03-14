//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by David Burghoff on 17.08.20.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let store: EmojiArtDocumentStore
    let url: URL
    init() {
        url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        store = EmojiArtDocumentStore(directory: url)
    }
    var body: some Scene {
        
        WindowGroup {
            EmojiArtDocumentChoser().environmentObject(store)
            //EmojiArtDocumentView(document: EmojiArtDocument())
        }
    }
}
