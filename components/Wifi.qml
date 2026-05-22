import QtQuick
import Quickshell.Io

Item {
    width: wifiColumn.width
    height: wifiIcon.height
    anchors.verticalCenter: parent.verticalCenter

    Column {
        id: wifiColumn
        spacing: 4
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: wifiIcon
            text: ""
            color: "#89b4fa"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 18
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    wifiMenu.visible = !wifiMenu.visible
                }
            }
        }

        Rectangle {
            id: wifiMenu
            visible: false
            width: wifiName.width + 20
            height: 30
            color: "#1e1e2e"
            radius: 8
            border.color: "#313244"
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: wifiName
                text: wifiCheck.output.trim() !== "" && wifiCheck.output.trim() !== "Disconnected" ? wifiCheck.output.trim() : "Нет сети"
                color: "#cdd6f4"
                font.family: "Rubik"
                font.pixelSize: 13
                anchors.centerIn: parent
            }
        }
    }

    Process {
        id: wifiCheck
        command: ["sh", "-c", "iwgetid -r 2>/dev/null || echo 'Disconnected'"]
        running: true
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: {
            wifiCheck.running = false
            wifiCheck.running = true
        }
    }
}
