import QtQuick 2.0
import Sailfish.Silica 1.0

ProgressCircle {
    id: loginProgress
    anchors { centerIn: parent}
    opacity: authenticating? 1.0: 0.0
    z: authenticating? 1: -1
    width: Theme.itemSizeExtraLarge*2
    height: width
    //value: authenticatingProgress
    onValueChanged: console.log(value)

    Behavior on opacity { FadeAnimation {} }
    
    Timer {
        interval: 33
        repeat: true
        onTriggered: loginProgress.value = (loginProgress.value + 0.005) % 1.0;
        running: Qt.application.active
    }
    
    Label {
        text: authenticatingText
        anchors.centerIn: parent
    }
}
