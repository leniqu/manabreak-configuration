import QtQuick
import Quickshell.Io

Column {
    width: parent.width
    spacing: 2 

    // ИСПРАВЛЕНО: Убрали центрирование. Фиолетовый заголовок теперь строго слева!
    Text {
        text: " ПОГОДА" 
        color: "#cba6f7"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15
        font.bold: true
    }

    // Город остаётся по центру над температурой
    Text {
        text: weatherLogic.city
        color: "#a6adc8"
        font.family: "Rubik"
        font.pixelSize: 17
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Градусы остаются по центру
    Text {
        text: weatherLogic.weatherTemp
        color: "#cdd6f4"
        font.family: "Rubik"
        font.pixelSize: 35
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Process {
        id: weatherLogic
        command: ["sh", "-c", "curl -s 'wttr.in/Moscow?format=%t,%C,%l'"]
        running: true
        
        property string weatherTemp: "...°C"
        property string city: "Moscow"

        stdout: StdioCollector {
            waitForEnd: true
            onTextChanged: {
                var raw = text.trim();
                if (raw === "" || raw.indexOf("Error") !== -1 || raw.indexOf("502") !== -1) {
                    weatherLogic.weatherTemp = "N/A";
                    weatherLogic.city = "Moscow";
                    return;
                }
                
                var parts = raw.split(",");
                if (parts.length >= 1) {
                    var tempStr = parts[0];
                    
                    var match = tempStr.match(/[+-]?\d+/);
                    if (match) {
                        var num = parseInt(match);
                        weatherLogic.weatherTemp = (num > 0 ? "+" : "") + num + "°C";
                    } else {
                        weatherLogic.weatherTemp = "N/A";
                    }
                }
                
                if (parts.length >= 3) {
                    var rawCity = parts[2].trim();
                    weatherLogic.city = rawCity.charAt(0).toUpperCase() + rawCity.slice(1);
                }
            }
        }
    }

    Timer {
        interval: 900000; running: true; repeat: true
        onTriggered: {
            weatherLogic.running = false;
            weatherLogic.running = true;
        }
    }
}
