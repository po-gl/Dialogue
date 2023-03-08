# Dialogue
An iOS and macOS chatGPT app

`Dialogue` is an iOS and macOS app that connects to OpenAI's ChatGPT API (`gpt-3.5-turbo`).
Its UI is a simple and familiar chat interface, but its conversation abilities are surprisingly natural (like any other project using the GPT-3.5 model). Ask it general queries, coding questions, or to create poetry. The task-agnostic, few-shot model will typically give a convincing response, even when wrong. See OpenAI's [website](https://openai.com/blog/chatgpt) for more information on ChatGPT or their [paper](https://arxiv.org/pdf/2005.14165.pdf) on GPT-3 or this [paper](https://arxiv.org/abs/1706.03762) on the underlying Transformer model.

Features:
- Chat interface connecting to OpenAI's ChatGPT api (`gpt-3.5-turbo`)
- Markdown rendering of messages (lists, tables, code syntax, etc.)
- Preview links with rich media (the model can't utilize the internet so links are often dead)
- Close/Open thread to control conversational memory
- Change model settings (token limit and message memory)

## Installation

You'll need to supply your own OpenAI API key, so sign up on OpenAI's [site](https://platform.openai.com/docs/introduction) and create an API key. Then copy it into a file named `apikey.env` in `Dialogue/Dialogue/`. You can use the following commands, replacing `YOUR_API_KEY` with your key.

```
git clone https://github.com/po-gl/Dialogue.git
cd Dialogue
echo YOUR_API_KEY > ./Dialogue/apikey.env
```

Note that **your API key is not not hidden in a compiled app**, so do not share it with anyone you don't trust. If sharing your app is something you want to do, host a webserver that will make API calls and send results back to the app.

---

This app was fun to make, and I find myself using it instead of Google more often than I thought I would.

<p align="middle"> 
  <img align="center" width="280" alt="iOS dark" src="https://user-images.githubusercontent.com/42399205/223598252-21d7b4e2-045f-4deb-a32f-11a2f09ad38c.png">
  <img align="center" width="380" alt="macOS light" src="https://user-images.githubusercontent.com/42399205/223598368-c193375a-da85-464a-a72d-2adea81e6537.png">
</p>
