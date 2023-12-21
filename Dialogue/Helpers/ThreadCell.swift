//
//  ThreadCell.swift
//  Dialogue
//
//  Created by Porter Glines on 12/20/23.
//

import SwiftUI

struct ThreadCell: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var thread: ChatThread
    
#if os(iOS)
        let spacing: Double = 10
#elseif os(OSX)
        let spacing: Double = 0
#endif

    var body: some View {
        VStack (alignment: .leading, spacing: spacing) {
#if os(iOS)
            Text(thread.name == nil ? "New Thread" : thread.name == "" ? " " : thread.name!)
                .font(.system(.headline))
#elseif os(OSX)
            TextField("", text: .init(get: { thread.name == nil ? "New Thread" : thread.name == "" ? " " : thread.name! },
                                      set: { str in ChatThreadData.renameThread(str, for: thread, context: viewContext) }))
            .font(.system(.headline))
#endif
            
            HStack {
                if let lastEdited = thread.lastEdited {
                    Text(timeFormatter.string(from: lastEdited))
                } else {
                    Text("----")
                }

                Text(thread.summary ?? "")
                    .lineLimit(1)
            }
            .font(.system(.subheadline))
            .opacity(0.6)
        }
    }
}

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.doesRelativeDateFormatting = true
    formatter.dateStyle = .short
    return formatter
}()
