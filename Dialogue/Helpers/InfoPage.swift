//
//  InfoPage.swift
//  Dialogue
//
//  Created by Porter Glines on 2/11/23.
//

import SwiftUI

struct InfoPage: View {
    var body: some View {
        VStack (spacing: 0) {
            ScrollView {
                VStack (alignment: .leading, spacing: 20) {
                    HeaderText("About ChatGPT")
                    Text("OpenAI has trained a model called [ChatGPT](https://openai.com/blog/chatgpt/) to interact in a conversational way. It's impressive in its ability to answer naturally and hold engaging dialog. ")
                    
                    Text("The underlying model of ChatGPT is the _**ML Transformer**_; in fact, the \"GPT\" in the name stands for _Generative Pre-trained Transformer_. The ML Transformer is a neural network aimed at natural language processing first [presented in 2017](https://arxiv.org/abs/1706.03762) by researchers at Google. Since then, OpenAI has built upon the Transformer in their numerous [publications](https://openai.com/publications/).")
                    
                    Text("ChatGPT is powerful, but it isn't perfect.")
                    
                    HeaderText("Limitations")
                        .padding(.top, 60)
                    Text("**ChatGPT is sometimes confidently wrong.** It may give convincingly worded answers that are incorrect,. Like any information you encounter in life, use good judgement and consult secondary sources.")
                    
                    Text("**Answers do not use up-to-date information.** ChatGPT is trained on data that stopped in 2021. Thus, the model has no knowledge of events past 2021.")
                    
                    Text("**ChatGPT can't search the internet.** It has no external capabilities, so ChatGPT can't verify information, search websites, or provide links. ChatGPT generates answers based only on its internal knowledge.")
                    
                    GroupBox {
                        Text("_Note there are more powerful version of ChatGPT, such as Microsoft's Bing chat, that do use up-to-date information and have external capabilities._")
                    }
                }
                .padding(.top, 90)
                .padding([.leading, .trailing, .bottom], 25)
            }
        }
    }
    
    @ViewBuilder
    private func HeaderText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 30, weight: .bold))
    }
}

struct InfoPage_Previews: PreviewProvider {
    static var previews: some View {
        InfoPage()
    }
}
