import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: launcherComponent
    width: 320
    height: 450

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

            // === 1. ПОЛЕ ВВОДА ПОИСКА ===
            TextField {
                id: searchField
                Layout.fillWidth: true
                height: 40
                placeholderText: "Поиск приложений..."
                placeholderTextColor: "#6c7086"
                color: "#cdd6f4"
                
                font.family: "Rubik"
                font.pixelSize: 15
                font.bold: false

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
            }

            // === 2. СПИСОК РЕЗУЛЬТАТОВ ===
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
                        var p = Qt.createQmlObject('import Quickshell.Io; Process {}', launcherComponent)
                        p.command = ["sh", "-c", model.exec + " &"]
                        p.running = true
                        launcherRoot.isOpened = false
                    }
                }
            }
        }
    }

    ListModel {
        id: appsModel
    }

    // Системный парсер приложений на Gentoo
    Process {
        id: filterProc
        command: ["sh", "-c", "grep -E '^Name=|^Exec=' /usr/share/applications/*.desktop | awk -F= -v q=\"" + searchField.text + "\" 'BEGIN{IGNORECASE=1} /^[^:]*Name=/ {name=$2} /^[^:]*Exec=/ {exec=$2; if(name ~ q || exec ~ q) print name\"|\"exec}' | sort -u | head -n 30"]
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
                            appsModel.append({ "name": parts[0], "exec": parts[1] })
                        }
                    }
                }
            }
        }
    }
}
