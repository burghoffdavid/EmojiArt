//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by David Burghoff on 17.08.20.
//

import SwiftUI



struct EmojiArtDocumentView: View {
    //Access to ViewModel
    @ObservedObject var document: EmojiArtDocument
    // Palette
    @State private var chosenPalette: String = ""
    //temporarily save selected Emojis
    @State var selectedEmojis: Set = Set<EmojiArt.Emoji>()
    // View related State Variables
    @State private var showPaletteEditor = false
    @State private var explainBackgroundPaste = false
    
    var body: some View {
        VStack {
            HStack{
                PaletteChooser(chosenPalette: $chosenPalette, document: document)
                Image(systemName: "keyboard")
                    .imageScale(.large)
                    .onTapGesture {
                        showPaletteEditor = true
                    }
                    .sheet(isPresented: $showPaletteEditor){
                        PaletteEditor(chosenPalette: $chosenPalette, isShowing: $showPaletteEditor)
                            .environmentObject(document)
                            .frame(minWidth: 300, minHeight: 500)
                    }
                ScrollView(.horizontal){
                    HStack{
                        ForEach(chosenPalette.map{String($0)}, id: \.self){ emoji in // \.self KEypath, specify var on another Object
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag{return NSItemProvider(object: emoji as NSString)}
                        }
                    }
                }
                .padding(.horizontal)
                DocumentControlsView(selectedEmojis: $selectedEmojis)
                    .environmentObject(document)
                    
            }
            GeometryReader{ geometry in
                ZStack{
                    Rectangle().foregroundColor(.white).overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    if !isLoading {
                        ForEach(document.emojis){emoji in
                            Text(emoji.text)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedEmojis.contains(matching: emoji) ? Color.red : Color.clear, lineWidth: 4)
                                )
                                .font(animatableWithSize: emoji.fontSize * zoomScale)
                                .position(position(for: emoji, in: geometry.size))
                                .gesture(tapEmoji(emoji))
                                .gesture(dragEmoji(emoji))
                        }
                    }else{
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    }
                }
                .clipped()
                .gesture(panGesture())
                .gesture(zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(document.$backgroundImage){ image in
                    zoomToFit(image, in: geometry.size)
                }
                .onAppear{
                    chosenPalette = document.defaultPalette
                }
                .onDrop(of: ["public.image","public.text"], isTargeted: nil){ providers, location in
                    var location = geometry.convert(location, from : .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - panOffset.width, y: location.y-panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                    return self.drop(providers: providers, at: location)
                }
//                .navigationBarItems(trailing: Button(action: {
//                    if let url = UIPasteboard.general.url, url != document.backgroundURL{
//                        confirmBackgroundPaste = true
//                    }else{
//                        explainBackgroundPaste = true
//                    }
//                }, label: {
//                    Image(systemName: "doc.on.clipboard").imageScale(.large)
//                        .alert(isPresented: $explainBackgroundPaste){
//                            Alert(title: Text("Paste Bacground"),
//                                  message: Text("Copy the URL of an image to the clpi board and touch the button to make it the background of your document"),
//                                  dismissButton: .default(Text("OK")))
//                        }
//                }))
            }
        }
        .alert(isPresented: $confirmBackgroundPaste){
            Alert(title: Text("Paste Background"),
                  message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                  primaryButton: .default(Text("OK")){
                    document.backgroundURL = UIPasteboard.general.url
                  },
                  secondaryButton: .cancel())
        }
    }
    @State private var confirmBackgroundPaste = false
    
    var isLoading: Bool{
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    //MARK: - Backbround Gestures
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * (selectedEmojis.isEmpty ? gestureZoomScale : 1)
    }
    
    
    @State private var steadyStateEmojiZoomScale: CGFloat = 1.0
    @GestureState private var gestureEmojiZoomScale: CGFloat = 1.0
    
    private var emojiZoomScale: CGFloat {
        document.steadyStateZoomScale * gestureZoomScale
    }
    
    
    private func zoomGesture() -> some Gesture{
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                if !selectedEmojis.isEmpty{
                    for selectedEmoji in selectedEmojis{
                        print(selectedEmoji)
                        document.scaleEmoji(selectedEmoji, by: 1 + latestGestureScale - gestureZoomScale)
                    }
                }
                    gestureZoomScale = latestGestureScale
            }
            .onEnded{ finalGestureScale in
                if selectedEmojis.isEmpty{
                    document.steadyStateZoomScale *= finalGestureScale
                }
            }
    }
    
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize{
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture () -> some Gesture{
        DragGesture()
            .updating($gesturePanOffset){ latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded {finalDragGestureValue in
                document.steadyStatePanOffset = document.steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture{
        TapGesture(count: 2)
            .onEnded {
                withAnimation{
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
            .exclusively(before:
                TapGesture(count: 1)
                .onEnded{
                    selectedEmojis.removeAll()
                }
            )
    }
    // Mark: - Emoji Gestures
    
    private func toggleMatching(emoji:EmojiArt.Emoji, set:Set<EmojiArt.Emoji>) -> Set<EmojiArt.Emoji>{
        var newSet = set
        var notInSet = true
        for element in set{
            if emoji.id == element.id{
                newSet.remove(element)
                notInSet = false
            }
        }
        if notInSet{newSet.insert(emoji)}
        return newSet
    }
    
    private func tapEmoji(_ emoji: EmojiArt.Emoji)-> some Gesture{
        TapGesture()
            .onEnded{
                selectedEmojis = toggleMatching(emoji: emoji, set: selectedEmojis)
                print("new Set: \(selectedEmojis)")
        }
    }
    
    @State private var steadyStateEmojiOffset: CGSize = .zero
    @GestureState private var gestureEmojiOffset: CGSize = .zero
    
    private var emojiOffset:CGSize{
        (steadyStateEmojiOffset + gestureEmojiOffset) * zoomScale
    }
    
    private func dragEmoji(_ emoji: EmojiArt.Emoji) -> some Gesture{
        DragGesture()
            .updating($gestureEmojiOffset){latestGestureValue, gestureEmojiOffset, transaction in
                if selectedEmojis.contains(matching: emoji){
//                    gestureEmojiOffset = latestGestureValue.translation / zoomScale
                    for selectedEmoji in selectedEmojis{
                        document.moveEmoji(selectedEmoji, by: latestGestureValue.translation - gestureEmojiOffset)
                    }
                }else {
                    document.moveEmoji(emoji, by: latestGestureValue.translation - gestureEmojiOffset)
                }
                gestureEmojiOffset = latestGestureValue.translation
            }
    }

    
    private func zoomToFit(_ image: UIImage?, in size: CGSize){
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            document.steadyStatePanOffset = .zero
            document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize)-> CGPoint{
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool{
        var found = providers.loadFirstObject(ofType: URL.self) {url in
            self.document.backgroundURL = url
        }
        if !found{
            found = providers.loadObjects(ofType: String.self){string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize )
            }
        }
        return found
    }
    //MARK: - Drawing Constants
    private let defaultEmojiSize: CGFloat = 40
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}

