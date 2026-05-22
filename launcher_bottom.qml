import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: launcherWindow
    visible: true
    color: "transparent"
    
    implicitHeight: 470
    implicitWidth: 550
    
    anchors { bottom: true }
    
    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrLayershell.Exclusive
    WlrLayershell.exclusiveZone: 0

    property var historyCache: ({})

    // Pywal цвета
    property color wal_bg: "#11111b"
    property color wal_fg: "#cdd6f4"
    property color wal_c0: "#1e1e2e"
    property color wal_c4: "#89b4fa"
    property color wal_c5: "#cba6f7"
    property color wal_c8: "#585b70"

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
                        wal_bg = data.special.background || "#11111b"
                        wal_fg = data.special.foreground || "#cdd6f4"
                    }
                    if (data && data.colors) {
                        wal_c0 = data.colors.color0 || "#1e1e2e"
                        wal_c4 = data.colors.color4 || "#89b4fa"
                        wal_c5 = data.colors.color5 || "#cba6f7"
                        wal_c8 = data.colors.color8 || "#585b70"
                    }
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: {
        updateColors()
        loadHistoryProc.running = true
        loadAppsProc.running = true
        slideAnimation.start()
        fadeIn.start()
    }

    Shortcut {
        sequence: "Escape"
        onActivated: Qt.quit()
    }

    Rectangle {
        id: bodyBox
        width: 550; height: 450
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -450
        opacity: 0

        NumberAnimation {
            id: slideAnimation
            target: bodyBox
            property: "anchors.bottomMargin"
            to: 20
            duration: 400
            easing.type: Easing.OutCubic
            onFinished: searchInput.forceActiveFocus()
        }

        NumberAnimation {
            id: fadeIn
            target: bodyBox
            property: "opacity"
            from: 0; to: 1
            duration: 300
            easing.type: Easing.OutCubic
        }
        
        color: "#bf" + wal_bg.toString().substring(1)
        radius: 16
        border.color: wal_c5
        border.width: 1

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 15; spacing: 12

            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Поиск приложений..."
                color: wal_fg
                placeholderTextColor: wal_c8
                font.pixelSize: 15
                focus: true
                
                background: Rectangle {
                    color: wal_c0
                    radius: 10
                    border.color: searchInput.activeFocus ? wal_c5 : "transparent"
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
                
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) { Qt.quit(); event.accepted = true }
                    else if (event.key === Qt.Key_Down) { appList.moveCurrentIndexDown(); event.accepted = true }
                    else if (event.key === Qt.Key_Up) { appList.moveCurrentIndexUp(); event.accepted = true }
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (appList.currentItem) appList.currentItem.launchApp()
                        event.accepted = true
                    }
                }
                
                onTextChanged: {
                    filterAndSortApps(text)
                    appList.currentIndex = 0
                }
            }

            ScrollView {
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ListView {
                    id: appList
                    width: parent.width
                    model: sortedModel
                    spacing: 4
                    highlightFollowsCurrentItem: true

                    delegate: Item {
                        id: delegateItem
                        width: appList.width
                        height: 45

                        function launchApp() {
                            if (model.exec) {
                                runProc.command = [
                                    "sh", "-c", 
                                    "echo '" + model.name + "' >> ~/.cache/launcher_history.txt && setsid " + model.exec + " >/dev/null 2>&1 &"
                                ]
                                runProc.running = true
                                Qt.quit()
                            }
                        }

                        ItemDelegate {
                            anchors.fill: parent
                            property bool isSelected: ListView.isCurrentItem || hovered

                            background: Rectangle {
                                color: parent.isSelected ? wal_c8 : "transparent"
                                radius: 8
                                border.color: ListView.isCurrentItem ? wal_c5 : "transparent"
                                border.width: ListView.isCurrentItem ? 1 : 0
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                            }

                            contentItem: RowLayout {
                                anchors.fill: parent; anchors.margins: 6; spacing: 12

                                Image {
                                    source: model.icon ? ("image://icon/" + model.icon) : "image://icon/application-x-executable"
                                    Layout.preferredWidth: 28; Layout.preferredHeight: 28
                                    fillMode: Image.PreserveAspectFit
                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            source = "image://icon/application-x-executable"
                                        }
                                    }
                                }

                                Text {
                                    text: model.name ? model.name : ""
                                    color: wal_fg
                                    font.pixelSize: 15; font.bold: true
                                    Layout.fillWidth: true; elide: Text.ElideRight
                                }
                            }

                            onClicked: delegateItem.launchApp()
                        }
                    }
                }
            }
        }
    }

    ListModel { id: allAppsModel }
    ListModel { id: sortedModel }

    function filterAndSortApps(query) {
        var cleanQuery = query.toLowerCase().trim()
        var apps = []
        
        for (var i = 0; i < allAppsModel.count; i++) {
            var item = allAppsModel.get(i)
            if (!item.name) continue
            
            var matches = cleanQuery === "" || item.name.toLowerCase().indexOf(cleanQuery) !== -1
            if (cleanQuery !== "" && !matches) continue
            
            var score = (historyCache[item.name] || 0)
            apps.push({ name: item.name, icon: item.icon, exec: item.exec, score: score })
        }
        
        apps.sort(function(a, b) {
            return b.score - a.score
        })
        
        sortedModel.clear()
        for (var j = 0; j < apps.length; j++) {
            sortedModel.append({ name: apps[j].name, icon: apps[j].icon, exec: apps[j].exec })
        }
    }

    Process {
        id: loadAppsProc
        command: ["sh", "-c", "CACHE=~/.cache/launcher_apps.cache; if [ -f \"$CACHE\" ] && [ $(stat -c %Y \"$CACHE\") -gt $(date -d '1 hour ago' +%s) ]; then cat \"$CACHE\"; else for f in /usr/share/applications/*.desktop; do name=$(grep -m1 '^Name=' \"$f\" | sed 's/Name=//' | tr -d '\\r'); icon=$(grep -m1 '^Icon=' \"$f\" | sed 's/Icon=//' | tr -d '\\r'); exec=$(grep -m1 '^Exec=' \"$f\" | sed 's/Exec=//; s/ %.*//' | tr -d '\\r'); if [ -n \"$name\" ] && [ -n \"$exec\" ]; then echo \"$name|$icon|$exec\"; fi; done | tee \"$CACHE\"; fi"]
        running: false
        stdout: StdioCollector {
            waitForEnd: true
            onTextChanged: {
                var lines = text.trim().split("\n")
                allAppsModel.clear()
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("|")
                    if (parts.length >= 3) {
                        allAppsModel.append({
                            name: parts[0],
                            icon: parts[1] || "",
                            exec: parts[2] || ""
                        })
                    }
                }
                filterAndSortApps("")
            }
        }
    }

    Process {
        id: runProc
        command: []
        running: false
    }

    Process {
        id: loadHistoryProc
        command: ["sh", "-c", "touch ~/.cache/launcher_history.txt && cat ~/.cache/launcher_history.txt"]
        running: false
        stdout: StdioCollector {
            waitForEnd: true
            onTextChanged: {
                var lines = text.trim().split("\n")
                historyCache = {}
                for (var i = 0; i < lines.length; i++) {
                    var name = lines[i].trim()
                    if (name !== "") {
                        historyCache[name] = (historyCache[name] || 0) + 1
                    }
                }
                filterAndSortApps(searchInput.text)
            }
        }
    }
}
