import QtQuick 2.0
import QtQuick.Window 2.0
import Sailfish.Silica 1.0
import "js/gif.js" as Gif
import "js/messages.js" as Messages

Row {
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

    BackgroundItem {
        id: showGifGallery
        width: Theme.iconSizeLarge
        height: width
        onClicked: {
            gifGallery.opacity = !gifGallery.opacity
        }

        Label {
            anchors.centerIn: parent
            text: qsTr("GIF")
        }
    }

    TextArea {
        id: inputBox
        width: parent.width - submit.width - showGifGallery.width
        placeholderText: (gifGallery.opacity === 1.0)? qsTr("Powered by GIPHY"): qsTr("Hi ") + name + "!"
        onPlaceholderTextChanged: text = "" // Clear input when switching between GIF search and messaging
    }

    IconButton {
        id: submit
        icon.source: (gifGallery.opacity === 1.0)? "../resources/images/icon-search.png": "../resources/images/icon-send.png"
        icon.scale: Theme.iconSizeSmall/icon.width
        onClicked: {
            if (gifGallery.opacity === 1.0) {
                Gif.search(inputBox.text)
            }
            else {
                Messages.send(matchId, inputBox.text)
                messagesModel.append({from: "myself", message: inputBox.text, createdDate: qsTr("Just now"), isGif: false})
                inputBox.text = "" // Clear input
                view.positionViewAtEnd()
            }
        }
    }
}
