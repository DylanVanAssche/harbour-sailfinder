import QtQuick 2.2
import QtQuick.Window 2.0
import Sailfish.Silica 1.0
import "js/messages.js" as Messages

Item {
    id: gifGallery
    width: parent.width
    height: parent.height/2.75
    anchors.bottom: inputBar.top
    opacity: 0.0

    Behavior on opacity {
        FadeAnimation {}
    }

    Rectangle {
        id: background
        anchors { fill: parent }
        width: parent.width
        height: parent.height
        color: Theme.secondaryHighlightColor
    }

    OpacityRampEffect {
        sourceItem: background
        direction: OpacityRamp.BottomToTop
        offset: 0.75
        slope: 3.0/offset
    }

    Label {
        anchors { centerIn: parent }
        font.pixelSize: Theme.fontSizeLarge
        font.bold: true
        text: qsTr("Search for GIFs")
    }

    SlideshowView {
        width: parent.width
        height: parent.height
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        itemWidth: width
        model: gifsModel

        delegate: AnimatedImage {
            id: gifDelegate
            width: parent.width/1.2
            height: parent.height*0.75
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            source: (status === Image.Error)? "../resources/images/icon-noimage.gif": model.url
            asynchronous: true

            BusyIndicator {
                anchors { centerIn: parent }
                size: BusyIndicatorSize.Medium
                running: (gifDelegate.status === AnimatedImage.Loading && Qt.ApplicationActive)? true: false
                color: Theme.primaryColor
            }

            MouseArea {
                anchors { fill: parent }
                onClicked: {
                    Messages.sendGif(matchId, model.original, model.id)
                    messagesModel.append({from: "myself", message: model.url, createdDate: qsTr("Just now"), isGif: true}); // Send GIF, clear and scroll down
                    gifGallery.opacity = 0.0
                    gifsModel.clear()
                }
            }
        }
    }
}
