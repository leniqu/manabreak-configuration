import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Row {
    id: sysActionsRoot
    spacing: 16
    anchors.verticalCenter: parent.verticalCenter

    // === 1. ВИДЖЕТ WI-FI ===
    Wifi {}

    // === 2. ВИДЖЕТ РАСКЛАДКИ КЛАВИАТУРЫ ===
    Item {
        width: layoutText.width
        height: 32
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: layoutText
            text: "EN" 
            color: layoutMouse.containsMouse ? "#b4befe" : "#a6adc8"
            font.family: "Rubik"
            font.pixelSize: 15
            font.bold: true
            anchors.centerIn: parent

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Process {
            id: getLayoutProc
            command: ["sh", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | cut -c1-2 | tr 'a-z' 'A-Z'"]
            running: true
            stdout: StdioCollector {
                waitForEnd: false
                onTextChanged: {
                    var out = text.trim()
                    if (out !== "" && out.length <= 3) {
                        layoutText.text = out
                    }
                }
            }
        }

        Timer {
            interval: 400; running: true; repeat: true
            onTriggered: { 
                getLayoutProc.running = false
                getLayoutProc.running = true 
            }
        }

        MouseArea {
            id: layoutMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                var p = Qt.createQmlObject('import Quickshell.Io; Process {}', sysActionsRoot)
                p.command = ["sh", "-c", "hyprctl switchxkblayout next && sleep 0.02 && NEW_LANG=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap') && notify-send -a 'Система' -i 'input-keyboard' -t 1200 'Раскладка изменена' \"Текущий язык: $NEW_LANG\""]
                p.running = true
                getLayoutProc.running = false
                getLayoutProc.running = true
            }
        }
    }

    // === 3. РЕАКТИВНЫЙ ВИДЖЕТ ЗВУКА ===
    Item {
        id: volumeWidget
        width: volRow.width
        height: 32
        anchors.verticalCenter: parent.verticalCenter

        property string volPercent: "100%"
        property string volIcon: "" 

        Row {
            id: volRow
            spacing: 6
            anchors.centerIn: parent

            Text {
                text: volumeWidget.volIcon
                color: volMouse.containsMouse ? "#89b4fa" : "#74c7ec"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16 
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                text: volumeWidget.volPercent
                color: volMouse.containsMouse ? "#b4befe" : "#cdd6f4"
                font.family: "Rubik"
                font.pixelSize: 15
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        // Процессы регулировки (лимит -l 1.0 жестко зафиксирован на 100%)
        Process { 
            id: volUpProc
            command: ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "5%+"]
            running: false
            onRunningChanged: if (!running && volMouse.activeScoll) getVolProc.trigger()
        }
        Process { 
            id: volDownProc; 
            command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
            running: false 
            onRunningChanged: if (!running && volMouse.activeScoll) getVolProc.trigger()
        }
        Process { 
            id: volMuteProc; 
            command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
            running: false 
            onRunningChanged: if (!running) getVolProc.trigger()
        }

        // Парсер PipeWire громкости
        Process {
            id: getVolProc
            command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if($3==\"[MUTED]\") print \"MUTE\"; else print int($2*100)}'"]
            running: true
            
            // Быстрый ручной перезапуск процесса
            function trigger() {
                running = false
                running = true
            }

            stdout: StdioCollector {
                waitForEnd: false
                onTextChanged: {
                    var out = text.trim()
                    if (out !== "") {
                        if (out === "MUTE") {
                            volumeWidget.volIcon = "" 
                            volumeWidget.volPercent = "Mute"
                        } else {
                            var val = parseInt(out)
                            if (!isNaN(val)) {
                                volumeWidget.volPercent = val + "%"
                                if (val === 0) volumeWidget.volIcon = ""
                                else if (val < 50) volumeWidget.volIcon = ""
                                else volumeWidget.volIcon = ""
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            id: volMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            // Вспомогательный флаг, чтобы понимать, что крутим именно мы
            property bool activeScoll: false

            onWheel: (wheel) => {
                volMouse.activeScoll = true
                if (wheel.angleDelta.y > 0) {
                    volUpProc.running = false
                    volUpProc.running = true
                } else {
                    volDownProc.running = false
                    volDownProc.running = true
                }
            }

            onClicked: {
                volMouse.activeScoll = false
                volMuteProc.running = false
                volMuteProc.running = true
            }
        }

        // Поллинг на случай, если громкость изменили кнопками клавиатуры
        Timer {
            interval: 300; running: true; repeat: true
            onTriggered: { 
                volMouse.activeScoll = false
                getVolProc.trigger()
            }
        }
    }

    // === 4. ЛОГОТИП GENTOO ===
    Text {
        id: startButton
        text: ""
        color: buttonMouseArea.containsMouse ? "#d1b3ff" : "#cba6f7"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 24
        font.bold: true
        anchors.verticalCenter: parent.verticalCenter

        scale: buttonMouseArea.containsMouse ? 1.15 : 1.0

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true 
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                globalPowerMenu.isOpened = !globalPowerMenu.isOpened
            }
        }
    }
}
