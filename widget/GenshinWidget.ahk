; Genshin Impact Notes Widget
; Modern game-style UI with automatic updates

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off

; Configuration
global API_URL := "http://localhost:6326/api/genshin/notes"
global UPDATE_INTERVAL := 1 * 60 * 60000  ; 1 hour
global ICON_PATH := "Z:\Applications\Genshin Impact game\GenshinImpact.exe"
global UI_MODE := "compact"  ; Options: "full", "compact", "mini"
; full = normal detailed view
; compact = icon-only grid view (2x3 grid)
; mini = single line icon-only view

; Create main GUI
global myGui := Gui("-AlwaysOnTop -Caption +ToolWindow", "Genshin Widget")
myGui.BackColor := "0x1a1a2e"

; Set window size and position based on UI mode
if (UI_MODE = "mini") {
    myGui.Show("w300 h45 x" . (A_ScreenWidth - 320) . " y30")
} else if (UI_MODE = "compact") {
    myGui.Show("w180 h180 x" . (A_ScreenWidth - 200) . " y30")
} else {
    myGui.Show("w280 h400 x" . (A_ScreenWidth - 300) . " y30")
}

myGui.SetFont("s10 c0xeaeaea", "Segoe UI")

if (UI_MODE = "full") {
    ; Full UI Mode - Normal detailed view
    ; Header with game icon
    if FileExist(ICON_PATH) {
        myGui.AddPicture("x10 y10 w40 h40", ICON_PATH)
    } else {
        myGui.AddPicture("x10 y10 w40 h40 Background0x1a1a2e", "")
    }
    myGui.AddText("x60 y15 w140 c0xffd700", "Genshin Impact")
    global lastUpdateText := myGui.AddText("x60 y35 w140 c0xaaaaaa", "Daily Notes")

    ; Refresh button (subtle, beside close)
    refreshBtn := myGui.AddText("x230 y10 w20 h20 c0x4ecdc4 Center Background0x2a2a3e", "🔄")
    refreshBtn.OnEvent("Click", (*) => FetchData())

    ; Close button
    closeBtn := myGui.AddText("x260 y10 w20 h20 c0xff6b6b Center Background0x2a2a3e", "✕")
    closeBtn.OnEvent("Click", (*) => ExitApp())

    ; Account Info
    myGui.AddText("x10 y65 c0xffd700", "━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    global uidText := myGui.AddText("x10 y80 w120", "UID: Loading...")
    global nicknameText := myGui.AddText("x140 y80 w140", "Nickname: --")

    ; Resin Section
    myGui.AddText("x10 y110 c0x16c79a", "⚡ Original Resin")
    global resinText := myGui.AddText("x10 y130 w260", "0 / 200")
    global resinTimeText := myGui.AddText("x10 y150 w260 c0xaaaaaa", "Full in: Calculating...")

    ; Dailies Section
    myGui.AddText("x10 y180 c0x4ecdc4", "📋 Daily Commissions")
    global dailiesText := myGui.AddText("x10 y200 w260", "0 / 4 completed")

    ; Realm Currency Section
    myGui.AddText("x10 y230 c0xf39c12", "🏠 Realm Currency")
    global realmText := myGui.AddText("x10 y250 w260", "0 / 2400")
    global realmTimeText := myGui.AddText("x10 y270 w260 c0xaaaaaa", "Full in: Calculating...")

    ; Weekly Boss Section
    myGui.AddText("x10 y300 c0xe74c3c", "⚔️ Weekly Boss Discount")
    global weeklyText := myGui.AddText("x10 y320 w260", "0 / 3 remaining")

    ; Expedition Section
    myGui.AddText("x10 y350 c0x9b59b6", "🗺️ Expeditions")
    global expeditionText := myGui.AddText("x10 y370 w260", "Loading...")

} else if (UI_MODE = "compact") {
    ; Compact UI Mode - Icon-only grid view (2x3)
    myGui.SetFont("s9")
    
    ; Close button
    closeBtn := myGui.AddText("x160 y5 w15 h15 c0xff6b6b Center", "✕")
    closeBtn.OnEvent("Click", (*) => ExitApp())
    
    ; Refresh button
    refreshBtn := myGui.AddText("x140 y5 w15 h15 c0x4ecdc4 Center", "🔄")
    refreshBtn.OnEvent("Click", (*) => FetchData())
    
    ; Grid layout - 2 columns, 3 rows
    ; Row 1: Resin | Dailies
    global resinIcon := myGui.AddText("x10 y25 w30 h30 c0x16c79a Center", "⚡")
    global resinText := myGui.AddText("x45 y30 w60", "0/200")
    
    global dailiesIcon := myGui.AddText("x10 y65 w30 h30 c0x4ecdc4 Center", "📋")
    global dailiesText := myGui.AddText("x45 y70 w60", "0/4")
    
    ; Row 2: Realm | Weekly
    global realmIcon := myGui.AddText("x10 y105 w30 h30 c0xf39c12 Center", "🏠")
    global realmText := myGui.AddText("x45 y110 w60", "0/2400")
    
    global weeklyIcon := myGui.AddText("x10 y145 w30 h30 c0xe74c3c Center", "⚔️")
    global weeklyText := myGui.AddText("x45 y150 w60", "0/3")
    
    ; Expedition on the right side
    global expeditionIcon := myGui.AddText("x110 y25 w30 h30 c0x9b59b6 Center", "🗺️")
    global expeditionText := myGui.AddText("x110 y60 w60 Center", "0/5")
    
    ; Time indicators (smaller)
    global resinTimeText := myGui.AddText("x45 y48 w60 c0x888888", "")
    global realmTimeText := myGui.AddText("x45 y128 w60 c0x888888", "")
    global lastUpdateText := myGui.AddText("x110 y80 w60 c0x666666 Center", "")
    
    ; Hidden elements for compatibility
    global uidText := myGui.AddText("x0 y0 w0 h0", "")
    global nicknameText := myGui.AddText("x0 y0 w0 h0", "")

} else if (UI_MODE = "mini") {
    ; Mini UI Mode - Single line icon-only view
    myGui.SetFont("s9")
    
    ; Close button
    closeBtn := myGui.AddText("x280 y5 w15 h15 c0xff6b6b Center", "✕")
    closeBtn.OnEvent("Click", (*) => ExitApp())
    
    ; Refresh button
    refreshBtn := myGui.AddText("x260 y5 w15 h15 c0x4ecdc4 Center", "🔄")
    refreshBtn.OnEvent("Click", (*) => FetchData())
    
    ; Single line layout
    global resinIcon := myGui.AddText("x10 y12 w20 h20 c0x16c79a", "⚡")
    global resinText := myGui.AddText("x32 y15 w45", "0/200")
    
    global dailiesIcon := myGui.AddText("x80 y12 w20 h20 c0x4ecdc4", "📋")
    global dailiesText := myGui.AddText("x102 y15 w30", "0/4")
    
    global realmIcon := myGui.AddText("x135 y12 w20 h20 c0xf39c12", "🏠")
    global realmText := myGui.AddText("x157 y15 w50", "0/2400")
    
    global weeklyIcon := myGui.AddText("x210 y12 w20 h20 c0xe74c3c", "⚔️")
    global weeklyText := myGui.AddText("x232 y15 w20", "0/3")
    
    ; Hidden elements for compatibility
    global expeditionIcon := myGui.AddText("x0 y0 w0 h0", "")
    global expeditionText := myGui.AddText("x0 y0 w0 h0", "")
    global resinTimeText := myGui.AddText("x0 y0 w0 h0", "")
    global realmTimeText := myGui.AddText("x0 y0 w0 h0", "")
    global lastUpdateText := myGui.AddText("x0 y0 w0 h0", "")
    global uidText := myGui.AddText("x0 y0 w0 h0", "")
    global nicknameText := myGui.AddText("x0 y0 w0 h0", "")
}

myGui.Show()

; Make draggable
myGui.OnEvent("Close", (*) => ExitApp())
DragWindow(myGui)

; Auto-update timer
SetTimer(FetchData, UPDATE_INTERVAL)
FetchData()  ; Initial fetch

return

FetchData() {
    global uidText, nicknameText, resinText, resinTimeText
    global dailiesText, realmText, realmTimeText, weeklyText
    global expeditionText, lastUpdateText, API_URL, UI_MODE
    
    try {
        ; Use WinHttp - no console window
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", API_URL, false)
        whr.Send()
        json := whr.ResponseText
        
        if (json = "") {
            ShowError("Error: Empty response")
            return
        }
        
        ; Clean up the JSON string - remove any BOM or whitespace
        json := Trim(json)
        json := RegExReplace(json, "^\xEF\xBB\xBF", "")  ; Remove UTF-8 BOM
        
        ; Manual simple JSON parsing for our specific structure
        if (!InStr(json, '"success":true')) {
            ShowError("Error: API returned failure")
            return
        }
        
        ; Extract values using RegEx
        RegExMatch(json, '"uid":"(\d+)"', &uidMatch)
        RegExMatch(json, '"nickname":"([^"]+)"', &nickMatch)
        RegExMatch(json, '"region":"([^"]+)"', &regionMatch)
        
        if (UI_MODE = "full") {
            if (uidMatch)
                uidText.Text := "UID: " . uidMatch[1]
            if (nickMatch && regionMatch)
                nicknameText.Text := nickMatch[1] . " (" . regionMatch[1] . ")"
        }
        
        ; Stamina
        RegExMatch(json, '"currentStamina":(\d+)', &currentStam)
        RegExMatch(json, '"maxStamina":(\d+)', &maxStam)
        RegExMatch(json, '"recoveryTime":"?(\d+)"?', &recovTime)
        
        if (currentStam && maxStam) {
            resinText.Text := currentStam[1] . " / " . maxStam[1]
            if (recovTime && recovTime[1] > 0)
                resinTimeText.Text := "Full in: " . FormatSeconds(recovTime[1])
            else
                resinTimeText.Text := "Full in: 0 sec"
        }
        
        ; Dailies
        RegExMatch(json, '"task":(\d+)', &dailyTask)
        RegExMatch(json, '"maxTask":(\d+)', &maxTask)
        if (dailyTask && maxTask)
            dailiesText.Text := dailyTask[1] . " / " . maxTask[1] . " completed"
        
        ; Realm
        RegExMatch(json, '"currentCoin":(\d+)', &currentCoin)
        RegExMatch(json, '"maxCoin":(\d+)', &maxCoin)
        RegExMatch(json, '"realm":\{[^}]*"recoveryTime":"?(\d+)"?', &realmRecov)
        
        if (currentCoin && maxCoin) {
            realmText.Text := currentCoin[1] . " / " . maxCoin[1]
            if (realmRecov && realmRecov[1] > 0)
                realmTimeText.Text := "Full in: " . FormatSeconds(realmRecov[1])
            else
                realmTimeText.Text := "Full in: 0 sec"
        }
        
        ; Weekly
        RegExMatch(json, '"resinDiscount":(\d+)', &discount)
        RegExMatch(json, '"resinDiscountLimit":(\d+)', &discountLimit)
        if (discount && discountLimit)
            weeklyText.Text := discount[1] . " / " . discountLimit[1] . " remaining"
        
        ; Expeditions
        RegExMatch(json, '"expedition":\{[^}]*"completed":(true|false)', &expComplete)
        finishedCount := 0
        totalCount := 0
        pos := 1
        while (pos := RegExMatch(json, '"status":"(Finished|Ongoing)"', &statusMatch, pos)) {
            totalCount++
            if (statusMatch[1] = "Finished")
                finishedCount++
            pos += StrLen(statusMatch[0])
        }
        
        if (totalCount > 0)
            expeditionText.Text := finishedCount . " / " . totalCount . " completed"
        
        ; Last update - show time in brackets after Daily Notes
        lastUpdateText.Text := "Last Updated (" . FormatDateTime(A_Now) . ")"
        
    } catch as e {
        ShowError("Error: " . e.Message)
    }
}

FormatSeconds(seconds) {
    hours := seconds // 3600
    minutes := Mod(seconds // 60, 60)
    secs := Mod(seconds, 60)
    
    if (hours > 0)
        return Format("{} hr {} min", hours, minutes)
    else if (minutes > 0)
        return Format("{} min {} sec", minutes, secs)
    else
        return Format("{} sec", secs)
}

FormatSecondsShort(seconds) {
    hours := seconds // 3600
    minutes := Mod(seconds // 60, 60)
    
    if (hours > 0)
        return Format("{}h{}m", hours, minutes)
    else if (minutes > 0)
        return Format("{}m", minutes)
    else
        return Format("{}s", seconds)
}

FormatDateTime(timestamp) {
    return FormatTime(timestamp, "HH:mm")
}

ShowError(msg) {
    global lastUpdateText
    lastUpdateText.Text := msg
}

; JSON parser for AHK v2
Jxon_Load(&src, args*) {
    key := "", is_key := false
    stack := [ tree := [] ]
    next := '"{[01234567890-tfn'
    pos := 0
    
    while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
        if InStr(" `t`n`r", ch)
            continue
        if !InStr(next, ch, true) {
            testArr := StrSplit(SubStr(src, 1, pos), "`n")
            ln := testArr.Length
            col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))
            msg := Format("{}: line {} col {} (char {})"
            ,   (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                : (next == "'") ? "Unterminated string starting at"
                : (next == "\") ? "Invalid \escape"
                : (next == ":") ? "Expecting ':' delimiter"
                : (next == '"') ? "Expecting object key enclosed in double quotes"
                : (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
                : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                : ["Expecting JSON value(string, number, [true, false, null], object or array)", ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1)][1]
            , ln, col, pos)
            throw Error(msg, -1, ch)
        }
        
        obj := stack[1]
        is_array := (obj is Array)
        
        if InStr(",}", ch) {
            is_key := (!is_array && ch == ",")
            next := is_key ? '"' : '"{[0123456789-tfn'
        } else if InStr("]", ch) {
            next := ","
        } else if InStr("tfn", ch) {
            if      (SubStr(src, pos, 4) == "true")
                value := true, pos += 3
            else if (SubStr(src, pos, 5) == "false")
                value := false, pos += 4
            else if (SubStr(src, pos, 4) == "null")
                value := "", pos += 3
            else
                throw Error("Invalid JSON value", -1, SubStr(src, pos))
            
            is_array ? obj.Push(value) : obj[key] := value
            next := is_array ? ",]" : ",}"
            
        } else if (ch == '"') {
            i := pos
            while (i := InStr(src, '"',, i+1)) {
                value := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
                if (SubStr(value, -1) != "\")
                    break
            }
            if (!i)
                throw Error("Unterminated string", -1)
            
            value := StrReplace(value, "\/", "/")
            value := StrReplace(value, '\"', '"')
            value := StrReplace(value, "\b", "`b")
            value := StrReplace(value, "\f", "`f")
            value := StrReplace(value, "\n", "`n")
            value := StrReplace(value, "\r", "`r")
            value := StrReplace(value, "\t", "`t")
            
            pos := i
            
            if is_key {
                key := value, next := ":"
                continue
            }
            
            is_array ? obj.Push(value) : obj[key] := value
            next := is_array ? ",]" : ",}"
            
        } else if InStr("{[", ch) {
            if is_array
                obj.Push(value := (ch == "{") ? Map() : Array())
            else
                obj[key] := value := (ch == "{") ? Map() : Array()
            
            stack.InsertAt(1, value)
            next := (ch == "{") ? '"}' : '"{[0123456789-tfn'
            is_key := false
            
        } else {
            if (ch == "-")
                value := "-", ch := SubStr(src, ++pos, 1)
            else
                value := ""
            
            if InStr("0123456789", ch) {
                while InStr("0123456789", ch) {
                    value .= ch, ch := SubStr(src, ++pos, 1)
                }
                
                if (ch == ".") {
                    value .= ".", ch := SubStr(src, ++pos, 1)
                    while InStr("0123456789", ch) {
                        value .= ch, ch := SubStr(src, ++pos, 1)
                    }
                }
                
                if InStr("eE", ch) {
                    value .= ch, ch := SubStr(src, ++pos, 1)
                    if InStr("+-", ch)
                        value .= ch, ch := SubStr(src, ++pos, 1)
                    while InStr("0123456789", ch) {
                        value .= ch, ch := SubStr(src, ++pos, 1)
                    }
                }
                
                pos--
                is_array ? obj.Push(value + 0) : obj[key] := value + 0
                next := is_array ? ",]" : ",}"
            }
        }
    }
    return tree[1]
}

DragWindow(GuiObj) {
    ; Make window draggable by clicking anywhere
    OnMessage(0x201, WM_LBUTTONDOWN)
    
    WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
        if (hwnd = GuiObj.Hwnd)
            PostMessage(0xA1, 2,,, hwnd)
    }
}
