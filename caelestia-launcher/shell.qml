import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: launcherRoot

    PanelWindow {
        id: launcherWindow
        color: "transparent"
        implicitWidth: 340
        implicitHeight: 500
        
        anchors {
            top: true
            left: true
        }
        
        WlrLayershell.namespace: "quickshell-launcher"
        WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.margins.top: 54
        WlrLayershell.margins.left: 10

        Rectangle {
            id: launcherBg
            anchors.fill: parent
            color: "#bf11111b" 
            radius: 16
            border.color: "#1e1e2e"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    height: 40
                    placeholderText: "Поиск приложений..."
                    placeholderTextColor: "#6c7086"
                    color: "#cdd6f4"
                    focus: true 
                    font.family: "Rubik"
                    font.pixelSize: 15

                    background: Rectangle {
                        color: "#1e1e2e"
                        radius: 8
                        border.color: searchField.activeFocus ? "#cba6f7" : "#313244"
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }

                    onTextChanged: {
                        appsModel.clear()
                        filterProc.running = false
                        filterProc.running = true
                    }
                    
                    Keys.onEscapePressed: {
                        Qt.quit()
                    }
                }

                ListView {
                    id: appsListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: appsModel

                    delegate: ItemDelegate {
                        width: appsListView.width
                        height: 38

                        background: Rectangle {
                            color: hovered ? "#313244" : "transparent"
                            radius: 6
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 12

                            Text {
                                text: ""
                                color: hovered ? "#cba6f7" : "#b4befe"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: model.name
                                color: hovered ? "#f5c2e7" : "#cdd6f4"
                                font.family: "Rubik"
                                font.pixelSize: 15
                                font.bold: true
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        onClicked: {
                            var p = Qt.createQmlObject("import Quickshell.Io; Process {}", launcherRoot)
                            p.command = ["sh", "-c", model.exec + " &"]
                            p.running = true
                            Qt.quit()
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: appsModel
    }

    Process {
        id: filterProc
        command: ["sh", "-c", "grep -E '^Name=|^Exec=' /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null | awk -F= -v q=\"" + searchField.text + "\" 'BEGIN{IGNORECASE=1} /^[^:]*Name=/ {name=\$2} /^[^:]*Exec=/ {exec=\$2; if(name ~ q || exec ~ q) print name\"|\"exec}' | sort -u | head -n 30"]
        running: true
        stdout: StdioCollector {
            waitForEnd: true
            onTextChanged: {
                var lines = text.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line !== "") {
                        var parts = line.split("|")
                        if (parts.length >= 2) {
                            var cleanExec = parts[1].replace(/%[fFuUidDnNoNsStT]/g, "").trim()
                            appsModel.append({ "name": parts[0], "exec": cleanExec })
                        }
                    }
                }
            }
        }
    }
}
