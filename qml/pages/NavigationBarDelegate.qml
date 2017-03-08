import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: parent.width/3   // Sailfinder V3.X
    height: parent.height
    property string iconSource
    property int swipeviewIndex
    property bool loading

    BackgroundItem {
        width: parent.width
        height: parent.height
        onClicked: swipeview.currentIndex = swipeviewIndex

        Image {
            width: parent.height*0.5
            height: width
            anchors { centerIn: parent }
            z: 2
            source: iconSource
            opacity: loading? 0.15: 1.0
            Behavior on opacity { FadeAnimation {} }
        }

        Rectangle {
            anchors { fill: parent }
            color: "black"
            opacity: loading? 1.0: 0.0
            Behavior on opacity { FadeAnimation {} }

            BusyIndicator {
                anchors { centerIn: parent }
                size: BusyIndicatorSize.Medium
                running: loading
            }
        }
    }
}
