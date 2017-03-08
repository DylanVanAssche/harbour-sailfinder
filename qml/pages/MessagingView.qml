import QtQuick 2.2
import QtQuick.Window 2.0
import Sailfish.Silica 1.0

SilicaListView {
    anchors { top: headerBar.bottom; left: parent.left; right: parent.right; bottom: inputBar.top }
    width: parent.width
    clip: true
    model: messagesModel
    header: Item {
        height: view.spacing
        anchors { left: parent.left; right: parent.right }
    }
    footer: Item {
        height: view.spacing
        anchors { left: parent.left; right: parent.right }
    }
    spacing: Theme.paddingMedium
    Component.onCompleted: positionViewAtEnd() // Scroll to the last messages
    onCountChanged: positionViewAtEnd()

    delegate: Item {
        id: item
        height: shadow.height
        anchors { left: parent.left; right: parent.right; margins: view.spacing }

        readonly property bool alignRight: (model.from === userId)? true: false
        readonly property int maxContentWidth: messagePage.width*0.9

        Rectangle {
            id: shadow
            anchors { fill: layout; margins: -Theme.paddingSmall }
            color: "white"
            radius: 3
            opacity: (item.alignRight ? 0.05 : 0.15)
            antialiasing: true
        }

        /*IconButton { // Sailfinder V3.X
            anchors.left: layout.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.verticalCenter: layout.verticalCenter
            icon.source: "../images/message_dislike.png"
            visible: item.alignRight
            opacity: 0.5
            onClicked:
            {
                if(icon.source.match("dislike.png"))
                {
                    icon.source = "../images/message_like.png"
                    opacity = 1.0
                    python.call('api.like_message',[true, model._id], function(like, message_id) {});
                    console.log("[INFO] Message " + model._id + " liked")
                }
                else if(icon.source.match("like.png"))
                {
                    icon.source = "../images/message_dislike.png"
                    opacity = 0.5
                    python.call('api.like_message',[false, model._id], function(like, message_id) {});
                    console.log("[INFO] Message: " + model._id + " disliked")
                }
            }
            Behavior on opacity {
                FadeAnimation {}
            }
        }*/

        Column {
            id: layout
            anchors { left: (item.alignRight? parent.left: undefined); right: (!item.alignRight? parent.right: undefined); margins: -shadow.anchors.margins; verticalCenter: parent.verticalCenter }
            spacing: Theme.paddingSmall

            Text {
                width: messagePage.width*0.8 //Math.min(page.width*0.8, contentWidth)
                anchors { left: (item.alignRight? parent.left: undefined); right: (!item.alignRight? parent.right: undefined)}
                color: Theme.primaryColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeMedium
                text: model.message
                visible: !model.isGif
            }

            AnimatedImage {
                id: gif
                width: Theme.itemSizeExtraLarge*3
                height: width
                visible: model.isGif
                fillMode: visible? Image.PreserveAspectFit: Image.Pad
                source: visible? model.message: "../resources/images/icon-noimage.gif"
                asynchronous: true

                BusyIndicator {
                    anchors.centerIn: parent
                    size: BusyIndicatorSize.Medium
                    running: (gif.status==AnimatedImage.Loading)? true: false
                }
            }

            Label {
                id: timestamp
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeTiny
                text: model.createdDate
            }
        }
    }
}
