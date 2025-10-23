# FileEmbedder <sup><sub>v2.1.1 - previously PicEmbedder</sub></sup>

**Encode files into text** - embed resources as code and get rid of external dependencies.

**Simple to use** - just [**Download**](https://github.com/DavidBevi/PicEmbedder/blob/main/FileEmbedder_v2.1.1.ahk), launch, & follow instructions!

### ![Demo gif of v2.1.1](https://github.com/DavidBevi/PicEmbedder/blob/main/FileEmbedder_v2.1.1.gif?raw=true)

<br/>

### Abstract
Each byte of the source file is read as if it was a character. Result includes non-printable chars (`linefeed`, `tab`, `space`…), so these "bad" chars are shifted by 256, becoming 2-bytes chars. Quotes (`"`, `'`, `` ` ``) undergo the same process.

Before this process every char gets shifted by 33, because in my testings this reduces "bad" chars that need 2 bytes, limiting size-increase (most evident on txts and small files, like icons).

Decoding does the same in reverse and saves the result in a file called `file` in your temp folder.
> **TECHNICAL**: each decoded byte is a **`num`** that fits in a byte, but AHK uses multiple bytes to store it. To write only the byte that stores **`num`** I use the ability of `.RawWrite` of accepting `address, len`, with <code>StrPtr(Chr(**num**)), 1</code> instead of **`num`**.

<br/>

### Credits

This script is inspired by [iPhilip's port of JustMe's **image2include**](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=119966) and by [EpicKeyboardGuy's **Embed ANY files into your script**](https://www.reddit.com/r/AutoHotkey/comments/1ina2y7/embed_any_files_into_your_script/).
