import QtQuick 2.2
import QtQuick.Window 2.0
import Sailfish.Silica 1.0
import "js/messages.js" as Messages

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

        IconButton { // Like/Unlike button for messages
            anchors { left: layout.right; verticalCenter: parent.verticalCenter }
            visible: item.alignRight // Only like messages from other users
            icon.source: model.liked? "../resources/images/icon-liked.png": "../resources/images/icon-notliked.png"
            icon.scale: Theme.iconSizeSmall/icon.width
            opacity: model.liked? 1.0: 0.5
            onClicked: {
                if(!model.liked) { // model.liked is the opposite of the action we need to do
                    Messages.like(model.id) // Takes some time until Tinder update his data after this
                }
                else {
                    Messages.unlike(model.id)
                }
                messagesModel.setProperty(model.index, "liked", !model.liked) // Update model
            }

            Behavior on opacity {
                FadeAnimation {}
            }
        }

        Column {
            id: layout
            anchors { left: (item.alignRight? parent.left: undefined); right: (!item.alignRight? parent.right: undefined); margins: -shadow.anchors.margins; verticalCenter: parent.verticalCenter }
            spacing: Theme.paddingSmall

            Text {
                width: messagePage.width*0.8
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

            Row {
                width: timestamp.width + (iconLiked.visible? Theme.paddingLarge + iconLiked.width: 0)
                anchors { right: parent.right }
                spacing: Theme.paddingLarge

                Label {
                    id: timestamp
                    font.pixelSize: Theme.fontSizeTiny
                    text: model.createdDate
                }

                Image {
                    id: iconLiked
                    width: Theme.iconSizeSmall
                    height: width
                    visible: model.liked && !item.alignRight
                    source: "../resources/images/icon-liked.png"
                }
            }
        }
    }
}
