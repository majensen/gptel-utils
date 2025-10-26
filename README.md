# gptel-utils.el - Convenience features for Emacs LLM Interface `gptel`

[`gptel`](https://github.com/karthink/gptel) is a very complete Emacs package 
for chat interaction with almost any LLM.  `gptel-utils.el`  provides some
additional functionality to the gptel package, including the following features:

- Autosave of chat buffers (if desired) to a local directory of your choice
- Quick switch to an open chat buffer
- Next/previous navigation among open chat buffers

## Autosave chats

To automatically save chats, set the custom variables `gptel-utils-autosave-chats` to `t`,
and `gptel-utils-autosave-dir` to the desired local directory. (The default is 
`~/.gptel/saved-chats`.)

Chats will save after each model response. Chat files are named `chat-<model>-<timestamp>.[org|md]`.

## Navigate multiple chat buffers

`gptel-utils-switch-to-chat` will immediately jump to the first open chat buffer created.
`gptel-utils-next-chat` and `gptel-utils-prev-chat` will switch ring-wise to other open 
chat buffers, if any.


