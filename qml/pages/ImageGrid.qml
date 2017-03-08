import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/util.js" as Util

Item {
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

    Image {
        id: image1
        width: (images.length > 1)? 2*parent.width/3: parent.width  //Enlarge the first picture when it's the only one
        height: width
        anchors { top: parent.top; left: parent.left }
        source: images[0]===undefined? "../resources/images/image-placeholder.png": images[0]
        opacity: zoom && (images.length > 1)? 0.20: 1.0
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
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
            enabled: image1.source=="../resources/images/image-placeholder.png"? false: true
            onClicked: {
                _zoomImage = image1.source
                zoom = !zoom
            }
        }

        BusyIndicator {
            anchors { centerIn: parent }
            running: (image1.status === Image.Ready)? false: Qt.ApplicationActive
            size: BusyIndicatorSize.Large
        }
    }

    Image {
        id: image2
        width: parent.width/3
        height: width
        anchors { top: parent.top; left: image1.right }
        source: images[1]===undefined? "../resources/images/image-placeholder.png": images[1]
        visible: (images.length > 1)? true: false
        opacity: zoom && visible? 0.20: 1.0
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
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
            enabled: image2.visible && image2.source=="../resources/images/image-placeholder.png"? false: true
            onClicked: {
                _zoomImage = image2.source
                zoom = !zoom
            }
        }

        BusyIndicator {
            anchors { centerIn: parent }
            running: (image2.status === Image.Ready)? false: Qt.ApplicationActive
            size: BusyIndicatorSize.Medium
        }
    }

    Image {
        id: image3
        width: parent.width/3
        height: width
        anchors { top: image2.bottom; left: image1.right }
        source: images[2]===undefined? "../resources/images/image-placeholder.png": images[2]
        visible: (images.length > 2)? true: false
        opacity: zoom && visible? 0.20: 1.0
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
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
            enabled: image3.visible && image3.source=="../resources/images/image-placeholder.png"? false: true
            onClicked: {
                _zoomImage = image3.source
                zoom = !zoom
            }
        }

        BusyIndicator {
            anchors { centerIn: parent }
            running: (image3.status === Image.Ready)? false: Qt.ApplicationActive
            size: BusyIndicatorSize.Medium
        }
    }

    Image {
        id: image4
        width: parent.width/3
        height: width
        anchors { top: image1.bottom; left: parent.left }
        source: images[3]===undefined? "../resources/images/image-placeholder.png": images[3]
        visible: (images.length > 3)? true: false
        opacity: zoom && visible? 0.20: 1.0
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        onStatusChanged: {
            switch(status)
            {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[3]===undefined? visible = false: visible = true;
                    break;
            }
        }

        Behavior on opacity { FadeAnimation {} }

        MouseArea {
            anchors { fill: parent }
            enabled: image4.visible && image4.source=="../resources/images/image-placeholder.png"? false: true
            onClicked: {
                _zoomImage = image4.source
                zoom = !zoom
            }
        }

        BusyIndicator {
            anchors { centerIn: parent }
            running: (image4.status === Image.Ready)? false: Qt.ApplicationActive
            size: BusyIndicatorSize.Medium
        }
    }

    Image {
        id: image5
        width: parent.width/3
        height: width
        anchors { top: image1.bottom; left: image4.right }
        source: images[4]===undefined? "../resources/images/image-placeholder.png": images[4]
        visible: (images.length > 4)? true: false
        opacity: zoom && visible? 0.20: 1.0
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        onStatusChanged: {
            switch(status)
            {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[4]===undefined? visible = false: visible = true;
                    break;
            }
        }

        Behavior on opacity { FadeAnimation {} }

        MouseArea {
            anchors { fill: parent }
            enabled: image5.visible && image5.source=="../resources/images/image-placeholder.png"? false: true
            onClicked: {
                _zoomImage = image5.source
                zoom = !zoom
            }
        }

        BusyIndicator {
            anchors { centerIn: parent }
            running: (image5.status === Image.Ready)? false: Qt.ApplicationActive
            size: BusyIndicatorSize.Medium
        }
    }

    Image {
        id: image6
        width: parent.width/3
        height: width
        anchors { top: image3.bottom; left: image5.right }
        source: images[5]===undefined? "../resources/images/image-placeholder.png": images[5]
        visible: (images.length > 5)? true: false
        opacity: zoom && visible? 0.20: 1.0
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        onStatusChanged: {
            switch(status)
            {
                case Image.Error:
                case Image.Null:
                    visible = false;
                    break;

                case Image.Loading:
                case Image.Ready:
                    images[5]===undefined? visible = false: visible = true;
                    break;
            }
        }

        Behavior on opacity { FadeAnimation {} }

        MouseArea {
            anchors { fill: parent }
            enabled: image6.visible && image6.source=="../resources/images/image-placeholder.png"? false: true
            onClicked: {
                _zoomImage = image6.source
                zoom = !zoom
            }
        }

        BusyIndicator {
            anchors { centerIn: parent }
            running: (image6.status === Image.Ready)? false: Qt.ApplicationActive
            size: BusyIndicatorSize.Medium
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
