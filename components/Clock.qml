import QtQuick

Text {
    id: clockText
    color: "#cdd6f4"       
    font.family: "Rubik"
    font.pixelSize: 16     
    font.bold: true        

    Timer {
        interval: 1000      
        running: true       
        repeat: true        
        triggeredOnStart: true 
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
        }
    }
}
