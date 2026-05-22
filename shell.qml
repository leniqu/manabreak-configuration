import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "components"

ShellRoot {
    id: launcherRoot
    property bool globalPowerMenuOpened: false

    property color wal_bg: "#11111b"
    property color wal_fg: "#cdd6f4"
    property color wal_c0: "#1e1e2e"
    property color wal_c1: "#f38ba8"
    property color wal_c2: "#a6e3a1"
    property color wal_c3: "#f9e2af"
    property color wal_c4: "#89b4fa"
    property color wal_c5: "#cba6f7"
    property color wal_c6: "#94e2d5"
    property color wal_c7: "#bac2de"
    property color wal_c8: "#585b70"
    Behavior on wal_bg { ColorAnimation { duration: 400 } }
    Behavior on wal_fg { ColorAnimation { duration: 400 } }
    Behavior on wal_c0 { ColorAnimation { duration: 400 } }
    Behavior on wal_c1 { ColorAnimation { duration: 400 } }
    Behavior on wal_c2 { ColorAnimation { duration: 400 } }
    Behavior on wal_c3 { ColorAnimation { duration: 400 } }
    Behavior on wal_c4 { ColorAnimation { duration: 400 } }
    Behavior on wal_c5 { ColorAnimation { duration: 400 } }
    Behavior on wal_c6 { ColorAnimation { duration: 400 } }
    Behavior on wal_c7 { ColorAnimation { duration: 400 } }
    Behavior on wal_c8 { ColorAnimation { duration: 400 } }
    function updateColors() {
        walProcess.running = false
        walProcess.running = true
    }

    Process {
        id: walProcess
        command: ["sh", "-c", "cat ~/.cache/wal/colors.json 2>/dev/null || echo '{}'"]
        running: false
        stdout: StdioCollector {
            waitForEnd: true
            onTextChanged: {
                try {
                    var data = JSON.parse(text.trim())
                    if (data && data.special) {
                        launcherRoot.wal_bg = data.special.background || "#11111b"
                        launcherRoot.wal_fg = data.special.foreground || "#cdd6f4"
                    }
                    if (data && data.colors) {
                        launcherRoot.wal_c0 = data.colors.color0 || "#1e1e2e"
                        launcherRoot.wal_c1 = data.colors.color1 || "#f38ba8"
                        launcherRoot.wal_c2 = data.colors.color2 || "#a6e3a1"
                        launcherRoot.wal_c3 = data.colors.color3 || "#f9e2af"
                        launcherRoot.wal_c4 = data.colors.color4 || "#89b4fa"
                        launcherRoot.wal_c5 = data.colors.color5 || "#cba6f7"
                        launcherRoot.wal_c6 = data.colors.color6 || "#94e2d5"
                        launcherRoot.wal_c7 = data.colors.color7 || "#bac2de"
                        launcherRoot.wal_c8 = data.colors.color8 || "#585b70"
                    }
                } catch (e) {}
            }
        }
    }

    // Обновляем цвета каждые 2 секунды
Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: updateColors()
}
    Component.onCompleted: updateColors()

    PanelWindow {
        id: topBar
        color: "transparent"
        anchors { top: true; left: true; right: true }
        implicitHeight: 44 
        WlrLayershell.namespace: "quickshell-bar"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: implicitHeight + WlrLayershell.margins.top
        WlrLayershell.margins { top: 4; left: 2; right: 2 }

        Rectangle {
            anchors.fill: parent
            color: "#bf" + wal_bg.toString().substring(1)
            radius: 22; border.color: wal_c8; border.width: 1

            Item {
                anchors.fill: parent; anchors.leftMargin: 15; anchors.rightMargin: 15
                Row { height: 32; anchors.left: parent.left; spacing: 10; anchors.verticalCenter: parent.verticalCenter; Workspaces {} }
                Row { id: centerRow; anchors.horizontalCenter: parent.horizontalCenter; anchors.verticalCenter: parent.verticalCenter; Clock {} }
                Row { id: rightRow; height: parent.height; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; SysActions {} }
            }
        }
    }

    PanelWindow {
        id: rightEdgeTrigger
        visible: !launcherRoot.globalPowerMenuOpened
        color: "transparent"
        implicitWidth: 10; implicitHeight: screen.height - 52
        anchors { top: false; right: true; bottom: true; left: false }
        WlrLayershell.namespace: "quickshell-edge-trigger"; WlrLayershell.layer: WlrLayer.Overlay; WlrLayershell.exclusiveZone: 0
        WlrLayershell.margins { top: 48; bottom: 4; right: 0 }

        MouseArea {
            anchors.fill: parent; hoverEnabled: true; z: 100; cursorShape: Qt.PointingHandCursor
            onContainsMouseChanged: { if (containsMouse) launcherRoot.globalPowerMenuOpened = true }
        }
    }

    PanelWindow {
        id: globalPowerMenu
        property bool isOpened: launcherRoot.globalPowerMenuOpened
        visible: false; color: "transparent"
        anchors { top: false; right: true; bottom: true; left: false }
        implicitWidth: 206; implicitHeight: screen.height - 60 
        WlrLayershell.namespace: "quickshell-side-control"; WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None; WlrLayershell.exclusiveZone: 0 
        WlrLayershell.margins { top: 50; bottom: 4; right: 2 } 

        onVisibleChanged: { if (visible) { mprisBackend.updateAll(); updateColors() } }
        onIsOpenedChanged: { if (isOpened) { globalPowerMenu.visible = true; closeAnim.stop(); openAnim.start() } else { openAnim.stop(); closeAnim.start() } }

        ParallelAnimation {
            id: openAnim
            NumberAnimation { target: sideContentContainer; property: "x"; from: 206; to: 0; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { target: sideContentContainer; property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        }
        ParallelAnimation {
            id: closeAnim
            NumberAnimation { target: sideContentContainer; property: "x"; to: 206; duration: 180; easing.type: Easing.InCubic }
            NumberAnimation { target: sideContentContainer; property: "opacity"; to: 0.0; duration: 120 }
            onFinished: { if (!launcherRoot.globalPowerMenuOpened) globalPowerMenu.visible = false }
        }

        Rectangle {
            id: sideContentContainer
            width: 200; height: parent.height
            color: "#bf" + wal_bg.toString().substring(1)
            radius: 20; border.color: wal_c8; border.width: 1; x: 206; opacity: 0

            Item {
                id: sideContentWrapper
                anchors.fill: parent; anchors.margins: 14

                ColumnLayout {
                    anchors.fill: parent; spacing: 14

                    Text {
                        text: "⚡ fastbar"; color: wal_c4
                        font { family: "Rubik"; pixelSize: 17; bold: true; letterSpacing: 1 }
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Column {
                        Layout.fillWidth: true; spacing: 10
                        Row {
                            Text { text: " "; color: wal_c5; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                            Item { width: 16 } 
                            Text { text: "Мониторинг"; color: wal_c5; font.family: "Rubik"; font.pixelSize: 16; font.bold: true }
                        }
                        Rectangle { height: 1; color: wal_c8; anchors.left: parent.left; anchors.right: parent.right }
                        Item { width: 1; height: 2 }

                        Column {
                            anchors.left: parent.left; anchors.right: parent.right; spacing: 4
                            Item {
                                anchors.left: parent.left; anchors.right: parent.right; height: 18
                                Text { text: " "; color: wal_c5; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; anchors.left: parent.left }
                                Text { text: Math.round(cpuTimer.cpuUsage) + "%"; color: wal_fg; font.family: "Rubik"; font.pixelSize: 16; font.bold: true; anchors.right: parent.right }
                            }
                            Rectangle {
                                height: 5; color: wal_c0; radius: 2.5; anchors.left: parent.left; anchors.right: parent.right
                                Rectangle { 
                                    width: parent.width * (Math.min(cpuTimer.cpuUsage, 100) / 100); height: parent.height; color: wal_c5; radius: 2.5 
                                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                                }
                            }
                        }
                        
                        Column {
                            anchors.left: parent.left; anchors.right: parent.right; spacing: 4
                            Item {
                                anchors.left: parent.left; anchors.right: parent.right; height: 18
                                Text { text: " "; color: wal_c2; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; anchors.left: parent.left }
                                Text { text: Math.round(ramCheck.ramUsage) + "%"; color: wal_fg; font.family: "Rubik"; font.pixelSize: 16; font.bold: true; anchors.right: parent.right }
                            }
                            Rectangle {
                                height: 5; color: wal_c0; radius: 2.5; anchors.left: parent.left; anchors.right: parent.right
                                Rectangle { 
                                    width: parent.width * (Math.min(ramCheck.ramUsage, 100) / 100); height: parent.height; color: wal_c2; radius: 2.5 
                                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                                }
                            }
                        }

                        Column {
                            anchors.left: parent.left; anchors.right: parent.right; spacing: 4
                            Item {
                                anchors.left: parent.left; anchors.right: parent.right; height: 18
                                Text { text: " "; color: wal_c3; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; anchors.left: parent.left }
                                Text { text: diskTextProc.diskText !== "" ? diskTextProc.diskText : "..."; color: wal_fg; font.family: "Rubik"; font.pixelSize: 16; font.bold: true; anchors.right: parent.right }
                            }
                            Rectangle {
                                height: 5; color: wal_c0; radius: 2.5; anchors.left: parent.left; anchors.right: parent.right
                                Rectangle { 
                                    width: parent.width * (Math.max(0, Math.min(100 - diskPercProc.diskPercent, 100)) / 100); height: parent.height; color: wal_c3; radius: 2.5 
                                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                                }
                            }
                        }
                    }

                    Weather { Layout.fillWidth: true }
                    
                    Column {
                        id: playerBlock
                        Layout.fillWidth: true; spacing: 10
                        Row {
                            Text { text: " "; color: wal_c4; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                            Item { width: 16 } 
                            Text { text: "Музыка"; color: wal_c4; font.family: "Rubik"; font.pixelSize: 16; font.bold: true }
                        }
                        Rectangle { height: 1; color: wal_c8; anchors.left: parent.left; anchors.right: parent.right }

                        Column {
                            anchors.left: parent.left; anchors.right: parent.right; spacing: 2
                            Text {
                                text: mprisBackend.title !== "" ? mprisBackend.title : "Музыка молчит"
                                color: wal_fg; font.family: "Rubik"; font.pixelSize: 16; font.bold: true
                                horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; anchors.left: parent.left; anchors.right: parent.right
                            }
                            Text {
                                text: mprisBackend.artist !== "" ? mprisBackend.artist : "Нет трека"
                                color: wal_c7; font.family: "Rubik"; font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; anchors.left: parent.left; anchors.right: parent.right
                            }
                        }

                        Slider {
                            id: progressSlider
                            anchors { left: parent.left; right: parent.right; leftMargin: 2; rightMargin: 2 }
                            from: 0; to: mprisBackend.length > 0 ? mprisBackend.length : 100
                            value: mprisBackend.position; live: false
                            background: Rectangle { height: 4; radius: 2; color: wal_c0; Rectangle { width: progressSlider.visualPosition * parent.width; height: parent.height; color: wal_c4; radius: 2 } }
                            handle: Rectangle { x: progressSlider.visualPosition * (progressSlider.width - width); y: (progressSlider.height - height) / 2; width: 10; height: 10; radius: 5; color: wal_c6 }
                            onMoved: {
                                var p = Qt.createQmlObject('import Quickshell.Io; Process {}', playerBlock)
                                p.command = ["playerctl", "position", Math.round(progressSlider.value)]
                                p.running = true
                            }
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter; spacing: 12
                            Rectangle {
                                width: 42; height: 36; radius: 8; color: mPrev.containsMouse ? wal_c8 : wal_c0
                                Text { text: "⏮"; color: wal_c4; font.pixelSize: 14; anchors.centerIn: parent }
                                MouseArea { id: mPrev; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process {}', playerBlock); p.command = ["playerctl", "previous"]; p.running = true } }
                            }
                            Rectangle {
                                width: 52; height: 36; radius: 8; color: mToggle.containsMouse ? wal_c8 : wal_c0; border.color: mprisBackend.status === "Playing" ? wal_c4 : "transparent"; border.width: 1
                                Text { text: mprisBackend.status === "Playing" ? "⏸" : "▶"; color: wal_c4; font.pixelSize: 14; anchors.centerIn: parent }
                                MouseArea { id: mToggle; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process {}', playerBlock); p.command = ["playerctl", "play-pause"]; p.running = true } }
                            }
                            Rectangle {
                                width: 42; height: 36; radius: 8; color: mNext.containsMouse ? wal_c8 : wal_c0
                                Text { text: "⏭"; color: wal_c4; font.pixelSize: 14; anchors.centerIn: parent }
                                MouseArea { id: mNext; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process {}', playerBlock); p.command = ["playerctl", "next"]; p.running = true } }
                            }
                        }
                    }
                    
                    Column {
                        Layout.fillWidth: true; spacing: 10
                        Row {
                            Text { text: " "; color: wal_c3; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                            Item { width: 16 }
                            Text { text: "Действия"; color: wal_c3; font.family: "Rubik"; font.pixelSize: 16; font.bold: true }
                        }
                        Rectangle { height: 1; color: wal_c8; anchors.left: parent.left; anchors.right: parent.right }
                        Item { width: 1; height: 2 }
                        Rectangle {
                            height: 44; radius: 10; color: mouseWall.containsMouse ? wal_c8 : wal_c0; anchors { left: parent.left; right: parent.right }
                            Row { anchors.centerIn: parent; spacing: 10
                                Text { text: ""; color: wal_c2; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                                Text { text: "Обои"; color: wal_fg; font.family: "Rubik"; font.pixelSize: 16 }
                            }
                            MouseArea { id: mouseWall; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; anchors.fill: parent; onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process {}', globalPowerMenu); p.command = ["waypaper", "--random"]; p.running = true } }
                        }
                        Rectangle {
                            height: 44; radius: 10; color: mouseNotif.containsMouse ? wal_c8 : wal_c0; anchors { left: parent.left; right: parent.right }
                            Row { anchors.centerIn: parent; spacing: 10
                                Text { text: ""; color: wal_c3; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                                Text { text: "Уведомления"; color: wal_fg; font.family: "Rubik"; font.pixelSize: 16 }
                            }
                            MouseArea { id: mouseNotif; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; onClicked: { launcherRoot.globalPowerMenuOpened = false; var p = Qt.createQmlObject('import Quickshell.Io; Process {}', globalPowerMenu); p.command = ["swaync-client", "-t", "-sw"]; p.running = true } }
                        }
                    }
                    
                    Column {
                        Layout.fillWidth: true; spacing: 10
                        Row {
                            Text { text: " "; color: wal_c1; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                            Item { width: 16 }
                            Text { text: "Система"; color: wal_c1; font.family: "Rubik"; font.pixelSize: 16; font.bold: true }
                        }
                        Rectangle { height: 1; color: wal_c8; anchors.left: parent.left; anchors.right: parent.right }
                        Item { width: 1; height: 2 }
                        Row {
                            anchors.left: parent.left; anchors.right: parent.right; spacing: 6
                            Rectangle {
                                width: (parent.width - 12) / 3; height: 44; radius: 10; color: mouseOff.containsMouse ? wal_c1 : wal_c0
                                Text { text: ""; color: mouseOff.containsMouse ? wal_bg : wal_c1; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; anchors.centerIn: parent }
                                MouseArea { id: mouseOff; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; anchors.fill: parent; onClicked: { launcherRoot.globalPowerMenuOpened = false; var p = Qt.createQmlObject('import Quickshell.Io; Process {}', globalPowerMenu); p.command = ["sh", "-c", "systemctl poweroff"]; p.running = true } }
                            }
                            Rectangle {
                                width: (parent.width - 12) / 3; height: 44; radius: 10; color: mouseReb.containsMouse ? wal_c2 : wal_c0
                                Text { text: ""; color: mouseReb.containsMouse ? wal_bg : wal_c2; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; anchors.centerIn: parent }
                                MouseArea { id: mouseReb; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; anchors.fill: parent; onClicked: { launcherRoot.globalPowerMenuOpened = false; var p = Qt.createQmlObject('import Quickshell.Io; Process {}', globalPowerMenu); p.command = ["sh", "-c", "systemctl reboot"]; p.running = true } }
                            }
                            Rectangle {
                                width: (parent.width - 12) / 3; height: 44; radius: 10; color: mouseExit.containsMouse ? wal_c3 : wal_c0
                                Text { text: ""; color: mouseExit.containsMouse ? wal_bg : wal_c3; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; anchors.centerIn: parent }
                                MouseArea { id: mouseExit; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; z: 10; anchors.fill: parent; onClicked: { launcherRoot.globalPowerMenuOpened = false; var p = Qt.createQmlObject('import Quickshell.Io; Process {}', globalPowerMenu); p.command = ["sh", "-c", "hyprctl dispatch exit"]; p.running = true } }
                            }
                        }
                    }

                    Column {
                        Layout.fillWidth: true; spacing: 4
                        Row {
                            spacing: 8; anchors.horizontalCenter: parent.horizontalCenter
                            Text { text: ""; color: wal_c8; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15 }
                            Text { text: uptimeCheck.uptimeText !== "" ? uptimeCheck.uptimeText : "..."; color: wal_c5; font.family: "Rubik"; font.pixelSize: 16; font.bold: true }
                        }
                        Text { text: dateCheck.dateText !== "" ? dateCheck.dateText : "..."; color: wal_c7; font.family: "Rubik"; font.pixelSize: 16; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent; hoverEnabled: true; propagateComposedEvents: true; z: 10
                onContainsMouseChanged: { if (!containsMouse) launcherRoot.globalPowerMenuOpened = false }
            }
        }
    }

    Item {
        id: mprisBackend
        property string title: ""; property string artist: ""; property string status: "Paused"; property real position: 0; property real length: 100
        function updateAll() {
            titleP.running = false; titleP.running = true; artistP.running = false; artistP.running = true
            statusP.running = false; statusP.running = true; posP.running = false; posP.running = true; lenP.running = false; lenP.running = true
        }
        Process { id: titleP; command: ["playerctl", "metadata", "title"]; stdout: StdioCollector { onTextChanged: mprisBackend.title = text.trim() } }
        Process { id: artistP; command: ["playerctl", "metadata", "artist"]; stdout: StdioCollector { onTextChanged: mprisBackend.artist = text.trim() } }
        Process { id: statusP; command: ["playerctl", "status"]; stdout: StdioCollector { onTextChanged: mprisBackend.status = text.trim() } }
        Process { id: posP; command: ["playerctl", "position"]; stdout: StdioCollector { onTextChanged: if(text.trim()!=="") mprisBackend.position = parseFloat(text.trim()) } }
        Process { id: lenP; command: ["sh", "-c", "playerctl metadata mpris:length | awk '{print $1/1000000}'"]; stdout: StdioCollector { onTextChanged: if(text.trim()!=="") mprisBackend.length = parseFloat(text.trim()) } }
    }

    Process { id: uptimeCheck; command: ["sh", "-c", "uptime -p | sed 's/up //; s/ hours,/ ч,/; s/ hour,/ ч,/; s/ minutes/ мин/; s/ minute/ мин/; s/ days,/ дн,/; s/ day,/ дн,/'"]; running: true; property string uptimeText: ""; stdout: StdioCollector { waitForEnd: false; onTextChanged: if (text.trim() !== "") uptimeCheck.uptimeText = text.trim() } }
    Process { id: dateCheck; command: ["sh", "-c", "LC_TIME=ru_RU.UTF-8 date '+%A, %d %B'"]; running: true; property string dateText: ""; stdout: StdioCollector { waitForEnd: false; onTextChanged: if (text.trim() !== "") dateCheck.dateText = text.trim() } }
    Process { id: diskTextProc; command: ["sh", "-c", "df -h / | awk 'NR==2 {print $4}' | sed 's/G/ ГБ/'"]; running: true; property string diskText: ""; stdout: StdioCollector { waitForEnd: false; onTextChanged: if (text.trim() !== "") diskTextProc.diskText = text.trim() } }
    Process { id: diskPercProc; command: ["sh", "-c", "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'"]; running: true; property real diskPercent: 0; stdout: StdioCollector { waitForEnd: false; onTextChanged: if (text.trim() !== "") diskPercProc.diskPercent = parseFloat(text.trim()) } }
    Process { id: ramCheck; command: ["sh", "-c", "free | awk '/Mem:/ {print $3/$2 * 100}'"]; running: true; property real ramUsage: 0; stdout: StdioCollector { waitForEnd: false; onTextChanged: if (text.trim() !== "") ramCheck.ramUsage = parseFloat(text.trim()) } }
    Process {
        id: cpuCheck; command: ["sh", "-c", "grep 'cpu ' /proc/stat | awk '{idle=$5; total=$2+$3+$4+$5+$6+$7+$8; print (total-idle)/total*100}'"]; running: false
        stdout: StdioCollector { waitForEnd: false; onTextChanged: if (text.trim() !== "") cpuTimer.cpuUsage = parseFloat(text.trim()) }
    }
    Timer {
        id: cpuTimer; interval: 1000; running: true; repeat: true; property real cpuUsage: 0
        onTriggered: {
            ramCheck.running = false; ramCheck.running = true; cpuCheck.running = false; cpuCheck.running = true
            if (globalPowerMenu.visible) {
                mprisBackend.updateAll()
                uptimeCheck.running = false; uptimeCheck.running = true; diskTextProc.running = false; diskTextProc.running = true
                diskPercProc.running = false; diskPercProc.running = true; dateCheck.running = false; dateCheck.running = true
            }
        }
    }
}
