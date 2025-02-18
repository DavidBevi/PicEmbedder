; PIC EMBEDDER by DavidBevi ███████████████████████████████████████████
; ENCODES pictures as text strings to embed in AHK v2 scripts. ########
; DECODES strings on-the-fly and lets you use the output. #############
#Requires AutoHotKey v2

; DEBUG HELPER used in developement ###################################
F1::(A_ThisHotkey=A_PriorHotkey and A_TimeSincePriorHotkey<200)? Reload(): {}



; █████████████████████████████████████████████████████████████████████
; DECODER SECTION #####################################################


; VARIABLES - REQUIRED ################################
IMG_STRING := "ƉŐŎŇčĊĚĊĀĀĀčŉňńŒĀĀĀĒĀĀĀĒĈĆĀĀĀŖǎƎŗĀĀĀāųŒŇłĀƮǎĜǩĀĀĀĄŧŁōŁĀĀƱƏċǼšąĀĀĀĉŰňřųĀĀĐǪĀĀĐǪāƂǓĊƘĀĀĀǆŉńŁŔĸŏƥƔƽčƃİĐƅǏĬŀƗĭĢƥŌŁƝęĘģƣŤƌǌƐĺŅǊňŬŁƗĉƒƼƓƟŴĶǦǸǱħƁǏĘľǰǩƉĠƆǯƟŘŮĢƀŘƫǤŲǫŤżŽǢƕŵĜǎƭļƮŏũİǙīāżƦƩƑŘǴƋŪĥŀŅĹǘǷǻľǨŁĸǇŚƉƉƈǍăƧǾƨģŠƍƵƒĬđǍŉƈħŋńƞƄŘƙƥǘƣĽĤĢǄĀǘĦǧŰƍǷƒńƄĘŸĲīǉģĳǙǚƜǌƓƀƀŤŻǍŝăŞŒǝŬǆƠŊǄǜǡįƢƢŒŒƗưĒǌǵƄľšǜĊĥĢĢĿĳŰŬǿǄŽƇęĀĀĀĀŉŅŎńƮłŠƂ"
EXTENSION := "png"
;
;
; CALL ################################################
TraySetIcon(Decode_IMG(IMG_STRING, EXTENSION))
;
;
; FUNCTION ############################################
Decode_IMG(encoded_string, ext) {
    ext~="."? {}: ext:=("." ext)
    tmp_byte := Buffer(1)
    tmp_file := FileOpen(A_Temp "\decoded_img." ext, "w")
    Loop Parse, encoded_string {
        NumPut("UChar", Ord(A_LoopField)-256, tmp_byte)
        tmp_file.RawWrite(tmp_byte)
    }
    tmp_file.Close()
    return(A_Temp "\decoded_img." ext)
}



; █████████████████████████████████████████████████████████████████████
; ENCODER SECTION #####################################################


; VARIABLES - OPTIONAL ################################################
SRC_IMAGE := "AHK_Icons/microdino.png"
DEST_TXT := "TMP_MicroDinoIco.txt"


; CALL ################################################################
Encode_in_TXT("",DEST_TXT)


; FUNCTION ############################################################
Encode_in_TXT(src_filepath:="", dest_filepath:="") {
    ;Section
    SrcPicker:
    If !FileExist(src_filepath) {
        src_filepath := FileSelect(1,,"𝘾𝙃𝙊𝙊𝙎𝙀 𝘼 𝙁𝙄𝙇𝙀 𝙏𝙊 𝙀𝙉𝘾𝙊𝘿𝙀","Pictures (*.png; *.bmp; *.gif; *.ico)")
    }
    If !FileExist(src_filepath) {
        If MsgBox("No file selected, retry?",,0x115)="Retry" {
            GoTo SrcPicker
        } Else GoTo EndMsgbox
    }
    ;Section
    Encoding:
    src:=FileOpen(src_filepath,"r")
    encoded_string := ""
    Loop(src.Length) {
        encoded_string .= Chr(src.ReadUChar()+256)
    }
    src.Close()
    ;Section
    Prompt_Copy2Clipboard:
    If MsgBox(encoded_string "`n`n𝘾𝙤𝙥𝙮 𝙩𝙤 𝙘𝙡𝙞𝙥𝙗𝙤𝙖𝙧𝙙?","𝙀𝙉𝘾𝙊𝘿𝙀𝘿 𝙄𝙈𝙂_𝙎𝙏𝙍𝙄𝙉𝙂:",0x04)="Yes" {
        SplitPath(src_filepath,,, &extension)
        title:= '𝘾𝙊𝙋𝙔 𝘼𝙇𝙎𝙊 𝙏𝙃𝙀 𝘿𝙀𝘾𝙊𝘿𝙀𝙍 𝙁𝙐𝙉𝘾𝙏𝙄𝙊𝙉?'
        above:= '; VARIABLES - REQUIRED ################################`nIMG_STRING := "'
        dummystring:= '𝘼𝘾𝙏𝙐𝘼𝙇_𝙀𝙉𝘾𝙊𝘿𝙀𝘿_𝙎𝙏𝙍𝙄𝙉𝙂_𝙒𝙄𝙇𝙇_𝙂𝙊_𝙃𝙀𝙍𝙀'
        below:= '"`nEXTENSION := "' extension '"`n;`n;`n; CALL ##########################'
        below.= '######################`nTraySetIcon(Decode_IMG(IMG_STRING, EXTENSION))`n'
        below.= ';`n;`n; FUNCTION ############################################`nDecode_IM'
        below.= 'G(encoded_string, ext) {`n    ext~="."? {}: ext:=("." ext)`n    tmp_byte'
        below.= ' := Buffer(1)`n    tmp_file := FileOpen(A_Temp "\decoded_img." ext, "w")'
        below.= '`n    Loop Parse, encoded_string {`n        NumPut("UChar", Ord(A_LoopFi'
        below.= 'eld)-256, tmp_byte)`n        tmp_file.RawWrite(tmp_byte)`n    }`n    tmp'
        below.= '_file.Close()`n    return(A_Temp "\decoded_img." ext)`n}'
        If MsgBox(above dummystring below,title,0x4)="Yes" {
            A_Clipboard:=(above encoded_string below)
        } Else A_Clipboard:=encoded_string
    }
    ;Section
    Prompt_Export2File:
    If MsgBox("Export into a txt file?",,"0x104")="Yes" {
        If !FileExist(dest_filepath) || MsgBox("Into " src_filepath "?",,0x4)="Yes" {
            GoTo ActualCopyIntoFile
        }
        ChooseDest:
        dest_filepath:= FileSelect("S 8",,"𝙎𝘼𝙑𝙀 𝙏𝙃𝙀 𝙀𝙉𝘾𝙊𝘿𝙀𝘿 𝙏𝙀𝙓𝙏 𝙁𝙄𝙇𝙀", 'Text File (*.txt)')
        If !dest_filepath {
            If MsgBox("No file selected, retry?",,0x115)="Retry" {
                GoTo ChooseDest
            } Else GoTo ActualCopyIntoFile
        }
    } Else GoTo EndMsgbox
    ;Section
    ActualCopyIntoFile:
    dest:=FileOpen(dest_filepath,"w")
    dest.Write(encoded_string)
    dest.Close()
    ;Section
    EndMsgbox:
    If MsgBox("𝙏𝙃𝙀 𝙀𝙉𝘿`n`nClick RETRY to encode another file.",,0x5)="Retry" {
        src_filepath := ""
        GoTo SrcPicker
    }
    Return
}

