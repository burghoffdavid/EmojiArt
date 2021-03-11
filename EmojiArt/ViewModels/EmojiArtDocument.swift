//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by David Burghoff on 17.08.20.
//

import SwiftUI

class EmojiArtDocument: ObservableObject{
    static let palette: String = "🍾🦇🐢"
    let defaults = UserDefaults.standard

    @Published private var emojiArt: EmojiArt = EmojiArt(){
        didSet{
            defaults.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
    }
    
    private static let untitled = "EmojiArtDocument.Untitled"

    init(){
        emojiArt = EmojiArt(json: defaults.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
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

    func setBackgroundURL(_ url: URL?){
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    func removeBackgroundImage(){
        backgroundImage = nil
    }
    
    private func fetchBackgroundImageData(){
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async{
                if let imageData = try? Data(contentsOf: url){
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL{
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
    
    func deleteDocument(){
        emojiArt = EmojiArt()
        backgroundImage = nil
        defaults.setValue(nil, forKey: EmojiArtDocument.untitled)
    }
}
// not violating MVVM since it is in ViewModel
extension EmojiArt.Emoji{
    var fontSize: CGFloat {CGFloat(self.size)}
    var location: CGPoint{CGPoint(x: CGFloat(x), y: CGFloat(y))}
}
