//
//  LinkPreview.swift
//  Dialogue
//
//  Created by Porter Glines on 3/5/23.
//

import SwiftUI
import LinkPresentation

#if os(iOS)
struct LinkPreview: UIViewRepresentable {
    let metadata: LPLinkMetadata
    
    func makeUIView(context: Context) -> some UIView {
        let view = ResizableLPLinkView(metadata: metadata)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

#elseif os(OSX)
struct LinkPreview: NSViewRepresentable {
    let metadata: LPLinkMetadata
    
    func makeNSView(context: Context) -> some NSView {
        let view = ResizableLPLinkView(metadata: metadata)
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}
#endif

class ResizableLPLinkView: LPLinkView {
    override var intrinsicContentSize: CGSize { CGSize(width: 0, height: super.intrinsicContentSize.height) }
}


struct LinkPreview_Previews: PreviewProvider {
    static var previews: some View {
        Wrapper()
    }
    
    struct Wrapper: View {
        @State var metadata: LPLinkMetadata?
        let linkText = "https://en.wikipedia.org/wiki/Calico_cat"
        
        var body: some View {
            VStack {
                if let metadata {
                    LinkPreview(metadata: metadata)
                        .frame(maxWidth: 200)
                        .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                        .animation(.easeInOut, value: metadata)
                } else {
                    Text("No usable metadata")
                }
            }
        }
    }
}

extension LPLinkMetadata {
    static func load(for url: URL?) async -> LPLinkMetadata? {
        guard let url else { return nil }
        // This will cause a purple warning about a method running on the main thread
        // this is a poor interaction between Webkit and the Security framework on Apple's side
        // https://developer.apple.com/forums/thread/714467?answerId=734799022#734799022
        let metadata = try? await LPMetadataProvider().startFetchingMetadata(for: url)
        return metadata
    }
}

extension URL {
    static func getURL(for text: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let match = detector?.firstMatch(in: text, range: NSMakeRange(0, text.count))
        let url = match?.url
        guard url?.scheme == "https", url?.host != nil else { return nil }
        return url
    }
}
