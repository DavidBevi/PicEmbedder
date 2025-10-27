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
FileEncoder(filepath:=0, adv:=0) {
    Try src := FileOpen(filepath,"r")
    Catch
        Return
    encoded_string:="",  single:=0,  double:=0
    Loop(src.Length) {
        ;_DEC__________|_HEX____|_CHARACTER___________| These "BAD CHARS" can break things.
        ; 0…31    +32  | 00…20  | unprintable + space | We can escape them using 2 chars,
        ; 128…159 +160 | 00…A0  | unmapped + &nbspace | but even better we can replace them
        ; 34           | 22     | doublequotes        | with a single 2-bytes char.
        ; 39           | 27     | singlequotes        | Same size, shorter string.
        ; 96           | 60     | backtick
        c := Mod(src.ReadUChar()+33, 256)             ; ←Reduces bad chars
        (Mod(c,128)<33 or c=34 or c=39 or c=96)       ; If bad char
            ? (double++, encoded_string.=Chr(c+256))  ; - add 256
            : (single++, encoded_string.=Chr(c))      ; - else 0
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
pick_file(p*) {
    ; Inform user about Inspector
    If p[1]="Inspector" {
        res := MsgBox("Inspector() is an optional advanced function.`n" .
                "Proceed?", "Warning", "YN")
        If res~="N"
            Return
    }
    ; Flush encoded_string, disable related options
    Global encoded_string:="", encoded_short:=""
    _c1.Opt("+Disabled")
    _t1.Opt("c666666")
    _t1.Text := (encoded_string || "[Empty]")

    ; Disable button and open FileSelect
    _b1.opt("+Disabled")
    filepath := FileSelect(1,, "Pick a file to " (p[1]="Inspector"? "inspect": "encode"))
    filepath? {}: update_info()

    ; If invalid file → re-enable-button, return
    If !FileExist(filepath){
        _b1.opt("-Disabled")
        Return
    }

    ; Inspect
    If p[1]="Inspector" {
        Try I%"nspector"%(filepath)
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
g.OnEvent("ContextMenu", (*)=>(m:=Menu(),m.Add("Inspector",pick_file.Bind("Inspector")),m.Show()))

;Green text (info / results)
g.SetFont("s8 c1e6c39", "Segoe UI")
_t0 := g.AddText("x13", info_text)

;Buttons (encode / copy)
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



; INSPECTOR #############################################################################
Inspector(filepath) {
    Try src := FileOpen(filepath,"r")
    Catch
        Return
    kv := Map()  ; Stores KV of used values 0-255
    Loop(src.Length) {
        k := Mod(src.ReadUChar()+33,256)
        kv.Has(k)? kv[k]++: kv[k]:=1        
    }
    src.Close()

    g2 := Gui("+Resize", StrSplit(filepath, "\")[-1] " - Occurrences of every byte-value after shift")
    g2.OnEvent("Size", (g,e,w,h)=>l.Move(0,,w,h))

    g2.SetFont("s9", "Segoe UI")
    t := g2.AddText("w500","Colored cells show 'bad-values', which correspond to unsuitable chars like unprintables and quotes. These single-byte chars needs to replaced with double-byte chars, so the file size will increase. FileEmbedder performs a shift by 33 before escaping, because this greatly reduces the size-increase of small icons (the reason FileEmbedder was made).`n`n" .
        " → Gold = Unused bad-values = Good`n" .
        " → Red = Used = Bad (high numbers = high size-increase)")
    
    g2.SetFont("s9", "Consolas")
    l := g2.AddListView("x0 r16 w500 Grid Count16 NoSort",[" ×","⬚𝟎","⬚𝟏","⬚𝟐","⬚𝟑","⬚𝟒","⬚𝟓","⬚𝟔","⬚𝟕","⬚𝟖","⬚𝟗","⬚𝐀","⬚𝐁","⬚𝐂","⬚𝐃","⬚𝐄","⬚𝐅"])

    Loop 16 {
        l.Add(, ["𝟎⬚","𝟏⬚","𝟐⬚","𝟑⬚","𝟒⬚","𝟓⬚","𝟔⬚","𝟕⬚","𝟖⬚","𝟗⬚","𝐀⬚","𝐁⬚","𝐂⬚","𝐃⬚","𝐄⬚","𝐅⬚"][A_Index])
        row := A_Index
        offset := (row-1)*16
        Loop 16 {
            col := A_Index
            cell := offset+col-1
            content := (kv.Has(cell)? kv[cell] :"")
            l.Modify(row, "Col" col+1, content)
            color := (Mod(cell,128)<33 or cell=34 or cell=39 or cell=96) * (1+!content)
            color? LV_CustomGridLines(l, [0xFF0000, 0xFFEE22][color], [row,col+1]) :{}
        }
    }
    l.ModifyCol()
    g2.Show()
}


; CUSTOM-COLOR FOR INSPECTOR #############################################################################
LV_CustomGridLines(LV, Color:=0, Arr*) {
    HasProp(LV,"on")   ? {}: (LV.OnNotify(-12, NM_CUSTOMDRAW, 1), LV.on:=1)
    HasProp(LV,"cells")? {}: LV.cells:=[]
    HasProp(LV,"pens") ? {}: LV.pens:=Map()
    key := (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >> 16 & 0xFF)
    LV.pens.Has(key)   ? {}: LV.pens[key]:=DllCall("CreatePen","Int",0,"Int",1,"UInt",key)
    For el in Arr
        LV.cells.Push({r:el[1], c:el[2], clr:key})

    NM_CUSTOMDRAW(LV, LP) {
        Critical -1
        Static ps:=A_PtrSize
        Switch (DrawStage := NumGet(LP+(ps*3),"UInt")) {
            Case 0x030002:
                row := NumGet(LP+(ps*5+16),"Int")+1
                col := NumGet(LP+(ps*5+48),"Int")+1
                rect := LP+(ps*5)
                DC := NumGet(LP+(ps*4),"UPtr")
                L := NumGet(rect,"Int")+1,   T := NumGet(rect+4,"Int")
                R := NumGet(rect+8,"Int")-2, B := NumGet(rect+12,"Int")-2

                For el in LV.cells {
                    If (row=el.r && col=el.c) {
                        pen := LV.pens[el.clr]
                        prevpen := DllCall("SelectObject","Ptr",DC,"Ptr",pen??0,"UPtr")
                        DllCall("MoveToEx","Ptr",DC,"Int",L,"Int",T,"Ptr",0)
                        DllCall("LineTo","Ptr",DC,"Int",R,"Int",T), DllCall("LineTo","Ptr",DC,"Int",R,"Int",B)
                        DllCall("LineTo","Ptr",DC,"Int",L,"Int",B), DllCall("LineTo","Ptr",DC,"Int",L,"Int",T)
                        DllCall("SelectObject","Ptr",DC,"Ptr",prevpen,"UPtr")
                    }
                }
                Return 0x00
            Case 0x030001: Return 0x10
            Case 0x010001: Return 0x20
            Case 0x000001: Return 0x20
            Default: Return 0x00
        }
    }
    LV.Redraw()
}
