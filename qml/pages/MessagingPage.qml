import QtQuick 2.2
import QtQuick.Window 2.0
import Sailfish.Silica 1.0
import "js/messages.js" as Messages

Page {
    id: messagePage

    property string name: qsTr("Unknown")
    property string userId
    property string matchId
    property string lastSeen: qsTr("Unknown")
    property string avatarImage: "../resources/images/icon-noimage.png"
    property int messagesCount
    property int userIndex

    MessagingHeader { id: headerBar }

    MessagingView { id: view }

    MessagingGifGallery { id: gifGallery }

    MessagingBar { id: inputBar }

    // Placeholder when no messages are available
    SilicaFlickable {
        ViewPlaceholder {
            enabled: !Qt.inputMethod.visible && !messagesCount
            text: qsTr("No messages") + " :("
            hintText: qsTr("Say hi to ") + name + "!"
        }
    }

    Connections {
        target: Qt.inputMethod
    }

    ListModel {
        id: gifsModel
    }

    ListModel {
        id: messagesModel
        Component.onCompleted: Messages.load()
    }
}
