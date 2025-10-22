#Requires AutoHotKey v2
Esc::(A_ThisHotkey=A_PriorHotkey and A_TimeSincePriorHotkey<200)? Reload(): {}


; VARIABLES #############################################################################
info_text        := "This AHK script lets you encode and copy any file into text.`n" .
                    "To remake and use the file(s) you need the decoder function, below.`n" .
                    "Tip: in your AHK script, copy just one decoder and as many encoded files as you want."
encoded_string   := ""
encoded_short    := "[Empty]`t`t`t`t`t`t`t"
decoder_printable:= 'FileRemaker(encoded_string) {`n' .
                    '    f := FileOpen(A_Temp "\file", "w")`n' .
                    '    For ch in StrSplit(encoded_string)`n' .
                    '        f.RawWrite(StrPtr(Chr(Mod(Ord(ch)-33,256))),1)`n' .
                    '    Return(A_Temp "\file")`n}'
example_printable:= "; Example→ TraySetIcon(FileRemaker(encoded_string))"


; EMBEDDED-TRAY-ICON #############################################################################
tray_icon := "ªqoh.+;+!!!.jies!!!3!!!3)ħ!!!wï¯x!!!ĢƔshc!Ïï=Ċ!!!%ƈbnb!!Ò°,ĝƂ&!!!*ƑizƔ!!1ċ!!1ċĢ£ô+¹!!!«jebuYpÖµò.¡A-e,<R³´Z3DÊhÙ%ÂõAđ3ĖęđòW%H&ød¯dY±Ɣ³¥Dąö9Ē­ă2ƇEåÐ±¡uò+ÛCĕ®¨õČ;vå@ë·ºƜÓgÅj©FƜªM*Ċêė-Ĝƌ/ÁxƖt²FÔ{x|ôƅ·%Ù6H<¼č:ė@q.Ə²J2FéĊ¦ZĂ\+FCCXPÃr.Ƒoƛ5!!!!jfoeÏcƁ£"
TraySetIcon(FileRemaker(tray_icon))


; ENCODER #############################################################################
FileEncoder(filepath) {
    Try src := FileOpen(filepath,"r")
    Catch
        Return
    encoded_string := ""
    single:=0, double:=0
    Loop(src.Length) {
        ; SHIFT TO REDUCE PERCENTAGE OF BAD CHARS
        c := Mod(src.ReadUChar()+33, 256)
        ; ESCAPE REMAINING BAD CHARS (do byte-doubling)
        ; [0…31] always unprintable + [32] space
        ; [128…159] sometimes unpr + [160] nbsp
        ; [34] doub-quotes   [39] sing-quote   [96] backtick
        (Mod(c,128)<33 or c=34 or c=39 or c=96)?
            (double++, encoded_string.=Chr(c+256)):
            (single++, encoded_string.=Chr(c) )
    }
    src.Close()
    update_info(filepath, single?, double?)
    Return(encoded_string)
}


; DECODER #############################################################################
FileRemaker(encoded_string) {
    f := FileOpen(A_Temp "\file", "w")
    For ch in StrSplit(encoded_string)
        f.RawWrite(StrPtr(Chr(Mod(Ord(ch)-33,256))),1)
    Return(A_Temp "\file")
}


; FILE_PICKER #############################################################################
pick_file(*) {
    ; Flush encoded_string, disable related options
    Global encoded_string:="", encoded_short:=""
    _c1.Opt("+Disabled")
    _t1.Opt("c666666")
    _t1.Text := (encoded_string || "[Empty]")

    ; Disable button and open FileSelect
    _b1.opt("+Disabled")
    filepath := FileSelect(1,, "Pick a file to encode in text")
    filepath? {}: update_info()

    ; If invalid file → re-enable-button, return
    If !FileExist(filepath){
        _b1.opt("-Disabled")
        Return
    }

    ; Encode
    _t1.Text := ("Encoding " StrSplit(filepath, "\")[-1] "...")
    spinner(50)
    Try result := FileEncoder(filepath)
    Catch {
        update_info()
        _b1.Opt("-Disabled")
        _t1.Opt("cb14040")
        _t1.Text := "[Conversion error]"
        spinner(-1)
        MsgBox("Conversion error", "Error", "IconX")
        Return
    }
    encoded_string := ('encoded_string := "' result '"')
    encoded_short := (SubStr(encoded_string, 1, 53) '…"')
    _b1.Opt("-Disabled")
    _c1.Opt("-Disabled")
    _t1.Opt("cDefault")
    _t1.Text := encoded_short
    spinner(-1)
    SetTimer((*)=>(_b1.Text := "𝐄𝐍𝐂𝐎𝐃𝐄𝐃"),-2)
    SetTimer((*)=>(_b1.Text := "Select the file to encode"),-1000)

}


; CPY #############################################################################
copy_text(*) {
    A_Clipboard := (((_c1.Value && encoded_string)? encoded_string "`n`n" :"") .
        (_c2.Value? decoder_printable "`n`n" :"") (_c3.Value? example_printable "`n`n" :"")) || f()
    _b2.Text := "𝐂𝐎𝐏𝐈𝐄𝐃"
    SetTimer((*)=>(_b2.Text := "Copy to clipboard the selected things below"),-1000)
    f(a:="Frqjudwv/#|rx#irxqg#wkh#hdvwhu#hjj$")=>(Chr(Ord(SubStr(a,1,1))-3) (StrLen(a)>1?f(SubStr(a,2)):""))
}


; UPDATE-INFO #############################################################################
update_info(filepath:=0, single:=0, double:=0) {
    If !filepath && !single && !double {
        _t0.Text := info_text
        Return
    }
    _t0.Text := "✅ " StrSplit(filepath,"\")[-1] " encoded!`nLen: " single+double " chars (" .
                single " single-byte chars + " double " double-byte chars)`nSize: " single+double*2 .
                " bytes (" Round((single+double*2)/(single+double),2) "x size increase)"
}


; SPINNER #############################################################################
spinner(p:=-1) {
    f(*)=> (_b1.Text := (_t1.Text ~= "Encod")? 
                SubStr("◜◠◝◞◡◟", Mod(f.i++,6)+1, 1): 
                "Select the file to encode" )
    f.i:=0
    SetTimer(f,p)
}


; GUI #############################################################################
g := Gui("-DPIScale", "FileEmbedder")
g.OnEvent("Close", (*)=>ExitApp())

;Green text (info / results)
g.SetFont("s8 c1e6c39", "Segoe UI")
_t0 := g.AddText("x13", info_text)

;Buttons
g.SetFont("s9 cDefault", "Segoe UI")
_b1 := g.AddButton("x10","Select the file to encode")
_b1.OnEvent('Click', pick_file)
_b2 := g.AddButton("x+10", "Copy to clipboard the selected things below")
_b2.OnEvent('Click', copy_text)

;1st checkmark group (copy string)
g.SetFont("s9 bold", "Segoe UI")
_c1 := g.AddCheckbox("x12 Checked Disabled", " Copy the encoded string")
g.SetFont("s8 norm", "Consolas")
_t1 := g.AddText("x33 y+1 c666666", encoded_short)

;2nd checkmark group (copy decoder)
g.SetFont("s9 bold", "Segoe UI")
_c2 := g.AddCheckbox("x12 Checked", " Copy the decoder function")
g.SetFont("s8 norm", "Consolas")
_t2 := g.AddText("x33 y+1", decoder_printable)

;3rd checkmark group (copy example)
g.SetFont("s9 bold", "Segoe UI")
_c3 := g.AddCheckbox("x12 Checked", " Copy an example")
g.SetFont("s8 norm", "Consolas")
_t3 := g.AddText("x33 y+1", example_printable)



; RUN SCRIPT #############################################################################
g.Show()
