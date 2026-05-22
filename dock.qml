import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: dockWindow
    visible: true
    color: "transparent"
    
    implicitWidth: 160
    implicitHeight: screen.height
    
    anchors { left: true }
    
    WlrLayershell.namespace: "quickshell-dock"
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrLayershell.None
    WlrLayershell.exclusiveZone: 0

    property bool dockOpened: false

    property color wal_bg: "#11111b"
    property color wal_c4: "#89b4fa"
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
                    }
                    if (data && data.colors) {
                        wal_c4 = data.colors.color4 || "#89b4fa"
                        wal_c8 = data.colors.color8 || "#585b70"
                    }
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: updateColors()

    mask: Region {
        item: dockOpened ? dockBody : openTrigger
    }

    Item {
        id: openTrigger
        width: 12
        height: dockColumn.height + 24
        anchors.left: parent.left
        y: (screen.height - height) / 2

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { dockOpened = true; updateColors() }
        }
    }

    Rectangle {
        id: dockBody
        width: dockOpened ? 76 : 0
        height: dockColumn.height + 24
        
        anchors.left: parent.left
        anchors.leftMargin: 12
        y: (screen.height - height) / 2
        
        opacity: dockOpened ? 1 : 0
        color: "#4d" + wal_bg.toString().substring(1)
        radius: 18
        border.color: wal_c8
        border.width: 1
        clip: true
        
        Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true 
            
            onExited: { dockOpened = false }

            Column {
                id: dockColumn
                anchors.centerIn: parent
                spacing: 12
                visible: dockBody.width > 30 

                Repeater {
                    id: dockRepeater
                    model: [
                        { name: "Firefox", icon: "firefox-bin", exec: "firefox-bin", size: 38, bgSize: 54 },
                        { name: "Files", icon: "org.gnome.Nautilus", exec: "nautilus", size: 38, bgSize: 54 },
                        { name: "VS Code", icon: "vscode", exec: "code", size: 32, bgSize: 50 },
                        { name: "Яндекс Музыка", icon: "yandexmusic", exec: "yandex-music", size: 38, bgSize: 54 },
                        { name: "OBS", icon: "com.obsproject.Studio", exec: "obs", size: 32, bgSize: 50 },
                        { name: "Steam", icon: "steam", exec: "steam steam://open/games", size: 32, bgSize: 50 }
                    ]
                    
                    delegate: Item {
                        id: dockItem
                        width: 56; height: 56
                        anchors.horizontalCenter: parent.horizontalCenter

                        property real myScale: 1.0

                        Rectangle {
                            id: appBg
                            width: modelData.bgSize || 50
                            height: modelData.bgSize || 50
                            radius: 12
                            anchors.centerIn: parent
                            color: iconMouse.containsMouse ? "#66" + wal_c4.toString().substring(1) : "transparent"
                            scale: dockItem.myScale
                            
                            Behavior on scale {
                                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            Image {
                                source: "image://icon/" + modelData.icon
                                anchors.centerIn: parent
                                width: modelData.size || 32
                                height: modelData.size || 32
                                fillMode: Image.PreserveAspectFit
                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        source = "image://icon/application-x-executable"
                                    }
                                }
                            }

                            MouseArea {
                                id: iconMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onEntered: { dockItem.myScale = 1.2 }
                                onExited: { dockItem.myScale = 1.0 }
                                
                                onClicked: {
                                    Quickshell.execDetached(["sh", "-c", modelData.exec])
                                    dockOpened = false 
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
