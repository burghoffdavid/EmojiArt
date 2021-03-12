//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by David Burghoff on 17.08.20.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Identifiable{
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    static let palette: String = "🍾🦇🐢"
    let defaults = UserDefaults.standard

    @Published private var emojiArt: EmojiArt
    
    @Published var steadyStatePanOffset: CGSize = .zero
    @Published var steadyStateZoomScale: CGFloat = 1.0
    
    private var autoSaveCancellable: AnyCancellable?
    
    init(id: UUID? = nil){
        self.id = id ?? UUID()
        let defaultsKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: defaults.data(forKey: defaultsKey)) ?? EmojiArt()
        autoSaveCancellable = $emojiArt.sink{emojiArt in
            print("\(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] {emojiArt.emojis}

    //Access to the Model

    //MARK: - Intents
    func addEmoji(_ emoji:String, at location: CGPoint, size: CGFloat){
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func removeEmoji(_ emoji:EmojiArt.Emoji){
        emojiArt.removeEmoji(emoji: emoji)
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].size = Int(CGFloat(CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }

    var backgroundURL: URL?{
        get{
            emojiArt.backgroundURL
        }
        set{
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    
    }
    
    func removeBackgroundImage(){
        backgroundImage = nil
    }
    
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData(){
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map{data, urlResponse in UIImage(data: data)}
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \.backgroundImage, on: self)
        }
    }
    
    func deleteDocument(){
        emojiArt = EmojiArt()
        backgroundImage = nil
        //defaults.setValue(nil, forKey: EmojiArtDocument.untitled)
    }
}
// not violating MVVM since it is in ViewModel
extension EmojiArt.Emoji{
    var fontSize: CGFloat {CGFloat(self.size)}
    var location: CGPoint{CGPoint(x: CGFloat(x), y: CGFloat(y))}
}
