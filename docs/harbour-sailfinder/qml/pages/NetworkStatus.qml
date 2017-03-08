import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../pages/js/helper.js" as Helper

Item {
    anchors.fill: parent
    width: parent.width
    height: parent.height
    z: 10 // overlay
    
    Rectangle {
        id: network_error_message
        width: parent.width
        height: Theme.itemSizeLarge
        z: 1 // on top
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: Theme.secondaryHighlightColor
        opacity: app.network_error? 1.0: 0.0
        
        Behavior on opacity {
            FadeAnimation {}
        }
        
        Label {
            anchors.centerIn: parent
            text: qsTr("Network connection error :-(")
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Theme.itemSizeHuge*2.5
        height: width
        radius: width/2
        color: Theme.secondaryHighlightColor
        visible: app.network_error

        BusyIndicator {
            id: progressIndicatorNetwork
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: app.network_error
        }

        Label {
            anchors.top: progressIndicatorNetwork.bottom
            anchors.topMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            visible: app.network_error
            text: qsTr("Checking connection")
            font.bold: true
        }

    }
    
    Rectangle {
        id: network_error_overlay
        anchors.fill: parent
        width: parent.width
        height: Screen.height
        color: "white"
        opacity: app.network_error? 0.3: 0.0
        
        Behavior on opacity {
            FadeAnimation {}
        }
    }

    TouchBlocker {
        anchors.fill: network_error_overlay
        enabled: app.network_error
    }

    Timer {
        id: recheck_connection_timer
        running: app.network_error
        repeat: true
        interval: 2000
        onTriggered:
        {
            python.call('network.connection',[], function() {});
        }
    }
}
