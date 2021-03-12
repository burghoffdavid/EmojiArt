//
//  EmojiArtDocumentChoser.swift
//  EmojiArt
//
//  Created by David Burghoff on 12.03.21.
//

import SwiftUI

struct EmojiArtDocumentChoser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView{
            List{
                ForEach(store.documents){document in
                    NavigationLink(destination:EmojiArtDocumentView(document: document)
                        .navigationBarTitle(store.name(for: document))
                    ){
                        EditableText(store.name(for:document), isEditing: editMode.isEditing){ name in
                            store.setName(name, for: document)
                        }
                    }
                }
                .onDelete{indexSet in
                    indexSet.map{ self.store.documents[$0] }.forEach{ document in
                        store.removeDocument(document)
                    }
                }
            }
            
            .navigationBarTitle(store.name)
            .navigationBarItems(leading: Button(action: {
                store.addDocument()
            }, label: {
                Image(systemName: "plus").imageScale(.large)
            }),
            trailing: EditButton()
            
            )
            .environment(\.editMode, $editMode)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EmojiArtDocumentChoser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChoser()
    }
}
