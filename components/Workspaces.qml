import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Rectangle {
    width: wsRow.width + 20  
    height: 36               
    radius: height / 2       
    color: wal_c0
    border.color: wal_c8
    border.width: 1
    anchors.verticalCenter: parent.verticalCenter

    property color wal_c0: "#1e1e2e"
    property color wal_c5: "#cba6f7"
    property color wal_c8: "#585b70"
    property color wal_fg: "#cdd6f4"
    property color wal_c7: "#bac2de"

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
                        wal_fg = data.special.foreground || "#cdd6f4"
                    }
                    if (data && data.colors) {
                        wal_c0 = data.colors.color0 || "#1e1e2e"
                        wal_c5 = data.colors.color5 || "#cba6f7"
                        wal_c8 = data.colors.color8 || "#585b70"
                        wal_c7 = data.colors.color7 || "#bac2de"
                    }
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: updateColors()

    Row {
        id: wsRow
        spacing: 8           
        anchors.centerIn: parent

        Repeater {
            model: [1, 2, 3, 4, 5]
            
            delegate: Rectangle {
                id: wsButton
                width: 28    
                height: 28
                radius: width / 2 
                anchors.verticalCenter: parent.verticalCenter
                
                property var hyprWs: Hyprland.workspaces.values.find(w => w.id === modelData)
                property bool isActive: hyprWs ? hyprWs.active : false

                color: isActive ? wal_c5 : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    text: modelData.toString()
                    color: isActive ? wal_c0 : (hyprWs ? wal_fg : wal_c7)
                    font.family: "Rubik" 
                    font.pixelSize: 14   
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.message("dispatch workspace " + modelData)
                    }
                }
            }
        }
    }
}
