import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1

Item {
    id: page
    width: parent.width
    height: width
    opacity: show? 1.0: 0.0
    visible: (opacity==0)? false: true

    Behavior on height { NumberAnimation {} }
    Behavior on opacity { FadeAnimation {} }

    property bool zoom
    property bool show: true
    property string _zoomImage
    property variant images: []

    GridLayout {
        id: grid
        anchors { fill: parent }
        columnSpacing: 0
        rowSpacing: 0
        columns: 3

        Image {
            width: (images.length > 1)? 2*page.width/3: page.width  //Enlarge the first picture when it's the only one
            height: (images.length > 1)? 2*page.width/3: page.width
            source: images[0]===undefined? "../resources/images/image-placeholder.png": images[0]
            visible: images[0]===undefined? false: true
            opacity: zoom && (images.length > 1)? 0.20: 1.0
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Layout.columnSpan: 2
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            onStatusChanged: {
                switch(status)
                {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[0] === undefined? visible = false: visible = true;
                    break;
                }
            }

            Behavior on opacity { FadeAnimation {} }

            MouseArea {
                anchors { fill: parent }
                enabled: parent.source=="../resources/images/image-placeholder.png"? false: true
                onClicked: {
                    _zoomImage = parent.source
                    zoom = !zoom
                }
            }

            BusyIndicator {
                anchors { centerIn: parent }
                running: (parent.status === Image.Ready)? false: Qt.ApplicationActive
                size: BusyIndicatorSize.Large
            }
        }

        Image {
            width: page.width/3
            height: page.width/3
            source: images[1]===undefined? "../resources/images/image-placeholder.png": images[1]
            visible: images[1]===undefined? false: true
            opacity: zoom && (images.length > 1)? 0.20: 1.0
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onStatusChanged: {
                switch(status)
                {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[1] === undefined? visible = false: visible = true;
                    break;
                }
            }

            Behavior on opacity { FadeAnimation {} }

            MouseArea {
                anchors { fill: parent }
                enabled: parent.source=="../resources/images/image-placeholder.png"? false: true
                onClicked: {
                    _zoomImage = parent.source
                    zoom = !zoom
                }
            }

            BusyIndicator {
                anchors { centerIn: parent }
                running: (parent.status === Image.Ready)? false: Qt.ApplicationActive
                size: BusyIndicatorSize.Large
            }
        }

        Image {
            width: page.width/3
            height: page.width/3
            source: images[2]===undefined? "../resources/images/image-placeholder.png": images[2]
            visible: images[2]===undefined? false: true
            opacity: zoom && (images.length > 2)? 0.20: 1.0
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onStatusChanged: {
                switch(status)
                {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[2] === undefined? visible = false: visible = true;
                    break;
                }
            }

            Behavior on opacity { FadeAnimation {} }

            MouseArea {
                anchors { fill: parent }
                enabled: parent.source=="../resources/images/image-placeholder.png"? false: true
                onClicked: {
                    _zoomImage = parent.source
                    zoom = !zoom
                }
            }

            BusyIndicator {
                anchors { centerIn: parent }
                running: (parent.status === Image.Ready)? false: Qt.ApplicationActive
                size: BusyIndicatorSize.Large
            }
        }

        Image {
            width: page.width/3
            height: page.width/3
            source: images[3]===undefined? "../resources/images/image-placeholder.png": images[3]
            visible: images[3]===undefined? false: true
            opacity: zoom && (images.length > 3)? 0.20: 1.0
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onStatusChanged: {
                switch(status)
                {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[3] === undefined? visible = false: visible = true;
                    break;
                }
            }

            Behavior on opacity { FadeAnimation {} }

            MouseArea {
                anchors { fill: parent }
                enabled: parent.source=="../resources/images/image-placeholder.png"? false: true
                onClicked: {
                    _zoomImage = parent.source
                    zoom = !zoom
                }
            }

            BusyIndicator {
                anchors { centerIn: parent }
                running: (parent.status === Image.Ready)? false: Qt.ApplicationActive
                size: BusyIndicatorSize.Large
            }
        }

        Image {
            width: page.width/3
            height: page.width/3
            source: images[4]===undefined? "../resources/images/image-placeholder.png": images[4]
            visible: images[4]===undefined? false: true
            opacity: zoom && (images.length > 4)? 0.20: 1.0
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onStatusChanged: {
                switch(status)
                {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[4] === undefined? visible = false: visible = true;
                    break;
                }
            }

            Behavior on opacity { FadeAnimation {} }

            MouseArea {
                anchors { fill: parent }
                enabled: parent.source=="../resources/images/image-placeholder.png"? false: true
                onClicked: {
                    _zoomImage = parent.source
                    zoom = !zoom
                }
            }

            BusyIndicator {
                anchors { centerIn: parent }
                running: (parent.status === Image.Ready)? false: Qt.ApplicationActive
                size: BusyIndicatorSize.Large
            }
        }

        Image {
            width: parent.width/3
            height: parent.width/3
            source: images[5]===undefined? "../resources/images/image-placeholder.png": images[5]
            visible: images[5]===undefined? false: true
            opacity: zoom && (images.length > 5)? 0.20: 1.0
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            onStatusChanged: {
                switch(status)
                {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[5] === undefined? visible = false: visible = true;
                    break;
                }
            }

            Behavior on opacity { FadeAnimation {} }

            MouseArea {
                anchors { fill: parent }
                enabled: parent.source=="../resources/images/image-placeholder.png"? false: true
                onClicked: {
                    _zoomImage = parent.source
                    zoom = !zoom
                }
            }

            BusyIndicator {
                anchors { centerIn: parent }
                running: (parent.status === Image.Ready)? false: Qt.ApplicationActive
                size: BusyIndicatorSize.Large
            }
        }
    }

    //Zoomed image
    Image {
        id: zoomedImage
        width: height
        height: parent.height*0.95
        anchors { centerIn: parent }
        source: _zoomImage
        opacity: zoom && (images.length > 1)? 1.0: 0.0 // Disable zoom when only one image displayed
        z: zoom && (images.length > 1)? 1: -1 //Hide zoom image when zoomed out
        fillMode: Image.PreserveAspectCrop
        clip: true
        asynchronous: true

        Behavior on opacity { FadeAnimation {} }

        MouseArea {
            anchors { fill: parent }
            enabled: zoom  // Disable when zoomed out
            onClicked: zoom = !zoom
        }

        BusyIndicator {
            anchors { centerIn: parent }
            running: (zoomedImage.status === Image.Ready)? false: Qt.ApplicationActive
            size: BusyIndicatorSize.Large
        }
    }
}
