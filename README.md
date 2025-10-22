# FileEmbedder <sup><sub>v2.1.1 - previously PicEmbedder</sub></sup>

**Encode files into text** - embed resources as code and get rid of external dependencies.

**Simple to use** - just [**Download**](https://github.com/DavidBevi/PicEmbedder/blob/main/FileEmbedder_v2.1.1.ahk), launch, & follow instructions!

### ![Demo gif of v2.1.1](https://github.com/DavidBevi/PicEmbedder/blob/main/FileEmbedder_v2.1.1.gif?raw=true)

<br/>

### Abstract
Each byte of the source file is converted to a character. Since some chars are not printable (like `linefeed` and `tab`) and others are undesirable (like `"`, `'`, `/``), these "bad" chars are transformed into chars that are encoded in 2 bytes.

Before this conversion every char gets shifted by 33 (char 0 becomes 33 and so on) in order to minimize "bad" chars that need the transformation, therefore limiting the file increase (most evident on txt and small files, like icons).

<br/>

### Credits

This script is inspired by [iPhilip's port of JustMe's **image2include**](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=119966) and by [EpicKeyboardGuy's **Embed ANY files into your script**](https://www.reddit.com/r/AutoHotkey/comments/1ina2y7/embed_any_files_into_your_script/).
