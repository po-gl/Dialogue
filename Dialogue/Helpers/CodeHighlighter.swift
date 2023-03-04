//
//  CodeHighlighter.swift
//  Dialogue
//
//  Created by Porter Glines on 3/2/23.
//
//  Comes from the swift-markdown-ui demo files

import MarkdownUI
import Splash
import SwiftUI


// MARK Code syntax highligher for Splash

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
    static func splash(theme: Splash.Theme) -> Self {
        SplashCodeSyntaxHighlighter(theme: theme)
    }
}

struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>
    
    init(theme: Splash.Theme) {
        self.syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }
    
    func highlightCode(_ content: String, language: String?) -> Text {
        return self.syntaxHighlighter.highlight(content)
    }
}

// MARK: Text Output Format

struct TextOutputFormat: OutputFormat {
    private let theme: Splash.Theme
    
    init(theme: Splash.Theme) {
        self.theme = theme
    }
    
    func makeBuilder() -> Builder {
        Builder(theme: self.theme)
    }
}

extension TextOutputFormat {
    struct Builder: OutputBuilder {
        private let theme: Splash.Theme
        private var accumulatedText: [Text]
        
        fileprivate init(theme: Splash.Theme) {
            self.theme = theme
            self.accumulatedText = []
        }
        
        mutating func addToken(_ token: String, ofType type: TokenType) {
            let color = self.theme.tokenColors[type] ?? self.theme.plainTextColor
#if os(iOS)
            self.accumulatedText.append(Text(token).foregroundColor(.init(uiColor: color)))
#elseif os(OSX)
            self.accumulatedText.append(Text(token).foregroundColor(.init(color)))
#endif
        }
        
        mutating func addPlainText(_ text: String) {
#if os(iOS)
            self.accumulatedText.append( Text(text).foregroundColor(.init(uiColor: self.theme.plainTextColor)) )
#elseif os(OSX)
            self.accumulatedText.append( Text(text).foregroundColor(.init(self.theme.plainTextColor)) )
#endif
        }
        
        mutating func addWhitespace(_ whitespace: String) {
            self.accumulatedText.append(Text(whitespace))
        }
        
        func build() -> Text {
            self.accumulatedText.reduce(Text(""), +)
        }
    }
}
