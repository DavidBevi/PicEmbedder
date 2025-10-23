# FileEmbedder <sup><sub>v2.1.1 - previously PicEmbedder</sub></sup>

**Encode files into text** - embed resources as code and get rid of external dependencies.

**Simple to use** - just [**Download**](https://github.com/DavidBevi/PicEmbedder/blob/main/FileEmbedder_v2.1.1.ahk), launch, & follow instructions!

### ![Demo gif of v2.1.1](https://github.com/DavidBevi/PicEmbedder/blob/main/FileEmbedder_v2.1.1.gif?raw=true)

<br/>

### Abstract
**ENCODING** reads each byte of the source file as if it was a character.
> **TECHNICAL**: each char is shifted by 33 to reduce "bad chars", which are non-printables (`linefeed`, `tab`, `space`…) and quotes (`"`, `'`, `` ` ``). Bad chars are then increased by 256, becoming 2-bytes chars. This means that the encoded string uses more bytes than the file. After encoding the green text will show you the size increase.

**DECODING** does the reverse and saves the result in a file called `file` in your temp folder.
> **TECHNICAL**: each decoded char is a **`num`** that fits in 1 byte, but AHK uses multiple bytes to store it. To write only the byte that actually stores **`num`** I use the ability of `.RawWrite` of accepting `address, len`, and I use <code>StrPtr(Chr(**num**)), 1</code> instead of **`num`**.

<br/>

### Credits

This script is inspired by [iPhilip's port of JustMe's **image2include**](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=119966) and by [EpicKeyboardGuy's **Embed ANY files into your script**](https://www.reddit.com/r/AutoHotkey/comments/1ina2y7/embed_any_files_into_your_script/).
