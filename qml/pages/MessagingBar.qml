import QtQuick 2.0
import QtQuick.Window 2.0
import Sailfish.Silica 1.0
import "js/messages.js" as Messages

Row {
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

    BackgroundItem {
        id: showGifGallery
        width: Theme.iconSizeLarge
        height: width
        onClicked: {
            var dialog = pageStack.push(Qt.resolvedUrl("GifGalleryPage.qml"))
            dialog.finished.connect(function() {
                Messages.sendGif(matchId, dialog.selectedGif.original, dialog.selectedGif.id) // Send GIF
            })
        }

        Label {
            anchors.centerIn: parent
            text: qsTr("GIF")
        }
    }

    TextArea {
        id: inputBox
        width: parent.width - submit.width - showGifGallery.width
        placeholderText: qsTr("Hi ") + name + "!"
    }

    IconButton {
        id: submit
        icon.source: "../resources/images/icon-send.png"
        icon.scale: Theme.iconSizeSmall/icon.width
        onClicked: {
            Messages.send(matchId, inputBox.text) // Send message
            messagesModel.append({from: "myself", message: inputBox.text, createdDate: qsTr("Just now"), isGif: false, liked: false})
            inputBox.text = "" // Clear input
            view.positionViewAtEnd()
        }
    }
}
