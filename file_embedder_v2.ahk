; FILE EMBEDDER by DavidBevi #############################################################################
; ENCODES files as text strings to embed in AHK v2 scripts.
; DECODES strings on-the-fly and lets you use the output.


#Requires AutoHotKey v2
Esc::(A_ThisHotkey=A_PriorHotkey && A_TimeSincePriorHotkey<200)? Reload(): {}


; EMBEDDED-TRAY-ICON #############################################################################
tray_icon := "ƉŐŎŇčĊĚĊĀĀĀčŉňńŒĀĀĀĒĀĀĀĒĈĆĀĀĀŖǎƎŗĀĀĀāųŒŇłĀƮǎĜǩĀĀĀĄŧŁōŁĀĀƱƏċǼšąĀĀĀĉŰňřųĀĀĐǪĀĀĐǪāƂǓĊƘĀĀĀƊŉńŁŔĸŏƵƔǑčƀĠČńċěıƒƓĹĒģƩŇƸĄơǔĠǰĒǵǸǰǑĶĄħąǗŃƎŃĸƐųƒƄģǤǕĘǱƌǢđŦĤǄƯƐƀŔǑĊƺĢǴƍƇǔǫĚŕǄğǊƖƙŻƲņƤŉƈĥŻƉĬĉǩǉǶČǻūĎƠŗŵœƑĥƳŚŗśǓŤƖĄƸĕħěƛǬęǶğŐčŮƑĩđĥǈǩƅĹǡĻĊĥĢĢķįƢőčŰŎźĔĀĀĀĀŉŅŎńƮłŠƂ"
TraySetIcon(FileRemaker(tray_icon))


; ENCODER #############################################################################
FileEncoder(filepath) {
    Try src := FileOpen(filepath,"r")
    Catch
        Return 0
    encoded_string := ""
    Loop(src.Length)
        encoded_string .= Chr(src.ReadUChar()+256)
    src.Close()
    Return(encoded_string)
}


; DECODER #############################################################################
FileRemaker(encoded_string) {
    _b := Buffer(1),  _f := FileOpen(A_Temp "\file", "w")
    For ch in StrSplit(encoded_string)
        NumPut("UChar", Ord(ch)-256, _b), _f.RawWrite(_b)
    _f.Close()
    Return(A_Temp "\file")
}


; FILE_PICKER #############################################################################
fpicker.Title := "Pick a file to encode"
fpicker(*) {
    ; Disable button while FileSelect is open
    bt.opt("+Disabled")
    filepath := FileSelect(1,, fpicker.title)

    ; Either change text to 'loading' or restore button + return
    If filepath {
        bt.Text := "Encoding..."
    } Else {
        bt.opt("-Disabled")
        Return
    }

    ; SPINNER-SUBFUNC
    sp.c:="⠿⠧⠇⠏⠟⠻⠹⠸⠼⠾",  sp.i:=0,
    sp(*)=>(t1.Text:=(bt.Text~="Encod"?SubStr(sp.c,sp.i,1):"1:"), sp.i:=Mod(sp.i+1,10))
    SetTimer(sp, filepath?50:0)

    ; Prepare clipboard and message
    clp := ""
    msg := "𝐒𝐔𝐂𝐂𝐄𝐒𝐒! 𝐓𝐇𝐄 𝐅𝐎𝐋𝐋𝐎𝐖𝐈𝐍𝐆 𝐂𝐎𝐃𝐄 𝐈𝐒 𝐍𝐎𝐖 𝐑𝐄𝐀𝐃𝐘 𝐓𝐎 𝐁𝐄 𝐏𝐀𝐒𝐓𝐄𝐃:`n`n"

    ; Copy encoded string?    
    If c1.Value = 1 {
        Try encoded_str := FileEncoder(filepath)
        Catch {
            MsgBox("Error converting " filepath, "Error")
            bt.opt("-Disabled")
            Return
        }
        clp .= 'encoded_str := "' encoded_str '"`n`n'
        msg .= 'encoded_str := "' SubStr(encoded_str, 1, 33) '" [...]`n`n'
    }

    ; Copy decoder func?
    If c2.Value = 1 {
        fn :=   'FileRemaker(encoded_string) {`n' .
                '    _b := Buffer(1),  _f := FileOpen(A_Temp "\file", "w")`n' .
                '    For ch in StrSplit(encoded_string)`n' .
                '        NumPut("UChar", Ord(ch)-256, _b),  _f.RawWrite(_b)`n' .
                '    _f.Close()`n' .
                '    Return(A_Temp "\file")`n}`n`n'
        clp .= fn
        msg .= fn
    }
    
    ; Restore button
    bt.Text := "Open file picker"
    bt.opt("-Disabled")

    ; Update clipboard and show confirmation msgbox
    A_Clipboard := clp
    Try MsgBox(msg, "File encoded into " StrLen(encoded_str) " chars")
    Catch {
        MsgBox("Please select at least one option", "Nothing done")
    }

}


; GUI_MOVER #############################################################################
gui_mover(*) {
    Static wasactive := 0

    ; FPICKER pos getter
    Try WinGetPos(&fx, &fy, &fw, &fh, fpicker.Title)
    Catch {
        g.Show("NoActivate")
        wasactive := 0
        Return
    }
    
    ; FPICKER status getter
    Try act := (WinGetTitle("A")=fpicker.Title)
    isactive := act ?? 0

    ; G pos getter
    Try WinGetPos(&gx, &gy, &gw, &gh, g.Title)
    Catch {
        isactive? g.Show("NoActivate") :{}
        Return
    }
    
    ; G status setter
    isactive ? g.Show("NoActivate x" fx+fw " y" fy+fh-gh) :
    wasactive ? g.Hide() :{}
    
    ; Save status for next loop
    wasactive := isactive
}


; GUI #############################################################################
g := Gui("-DPIScale +ToolWindow +AlwaysOnTop", "File→Text encoder")
g.SetFont("s10")
t1 := g.AddText("x10","1:")
bt := g.AddButton("x+2 yp-6 hp+12", "Open file picker")
bt.OnEvent('Click', fpicker)

t2 := g.AddText("x10","2:  Click 'open' to copy:")
c1 := g.AddCheckbox("x20 Checked", " the encoded string")
c2 := g.AddCheckbox("x20", " the decoder function")

g.OnEvent("Close", (*)=>ExitApp())

SetTimer(gui_mover, 50)

fpicker()
