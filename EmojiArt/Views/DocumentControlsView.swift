import SwiftUI

struct DocumentControlsView: View {
    
    @State var showingEditSheet: Bool = false
    @State var showBackgroundURLInputModal: Bool = false
    @Binding var selectedEmojis: Set<EmojiArt.Emoji>
    @State var userURLInput: String = ""
    @EnvironmentObject var document : EmojiArtDocument
    
    var body: some View {
        HStack{
            Button(action: {
                showingEditSheet = true
            }){
                Image(systemName: "pencil.circle")
            }
            .actionSheet(isPresented: $showingEditSheet){
                ActionSheet(title: Text("Edit"),
                            message: Text("Choose Option"),
                            buttons: [
                                .default(Text("insert Background from URL")){
                                    showBackgroundURLInputModal = true
                                },
                                .destructive(Text("Delete all Emojis")){
                                    for emoji in document.emojis{
                                        document.removeEmoji(emoji)
                                    }
                                },
                                .destructive(Text("Delete Background")){
                                    document.removeBackgroundImage()
                                },
                                .destructive(Text("Delete Document")){
                                    document.deleteDocument()
                                },
                                .cancel()
                            ])
            }
            .sheet(isPresented: $showBackgroundURLInputModal){
                VStack {
                    Text("Please insert your image URL below")
                    TextField("UserURLInput", text: $userURLInput)
                    HStack{
                        Button("Submit"){
                            let url = URL(string: userURLInput)
                            document.backgroundURL = url
                            showBackgroundURLInputModal = false
                        }
                    }
                    Button("Cancel"){
                        showBackgroundURLInputModal = false
                    }
                }
            }
            Button(action: {
                selectedEmojis.removeAll()
            }){
                Image(systemName: "checkmark.circle")
            }
            Button(action: {
                for emoji in document.emojis{
                    selectedEmojis.insert(emoji)
                }
            }){
                Image(systemName: "checkmark.circle.fill")
            }
            Button(action: {
                for selectedEmoji in selectedEmojis{
                    document.removeEmoji(selectedEmoji)
                }
            }){
                Image(systemName: "trash.circle.fill")
            }
        }
        .padding()
        .font(.system(size: 40))
        
    }
}
