import QtQuick 2.2
import Sailfish.Silica 1.0
import "js/messages.js" as Messages
import "js/gif.js" as Gif

Page {
    property var selectedGif
    signal finished

    SilicaListView {
        width: parent.width; height: parent.height - searchBar.height
        anchors { top: parent.top; bottom: searchBar.top; left: parent.left; right: parent.right }
        model: gifsModel
        opacity: count? 1.0: 0.0
        contentHeight: Theme.itemSizeHuge*1.5
        delegate: ListItem {
            width: ListView.view.width
            contentHeight: Theme.itemSizeHuge*1.5

            AnimatedImage {
                width: parent.width
                height: parent.height/1.1
                anchors { centerIn: parent }
                source: (status === Image.Error)? "../resources/images/icon-noimage.gif": model.url
                asynchronous: true
            }

            onClicked: {
                var gifData = new Object
                gifData.id = model.id
                gifData.original = model.original
                selectedGif = gifData
                finished()
                pageStack.pop()
            }
        }

        Behavior on opacity {
            FadeAnimation {}
        }

        ListModel {
            id: gifsModel
            onCountChanged: count > 0? busy.running = false: undefined
        }
    }

    BusyIndicator { // Search indication
        id: busy
        anchors { centerIn: parent }
        size: BusyIndicatorSize.Large
        running: false
    }

    Item {
        id: searchBar
        width: parent.width
        height: Theme.itemSizeLarge
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        Rectangle {
            anchors { fill: parent }
            opacity: Theme.highlightBackgroundOpacity
            color: "black"
        }

        Row {
            width: parent.width
            spacing: Theme.paddingLarge

            TextField {
                id: searchInput
                width: parent.width - Theme.itemSizeSmall
                anchors { verticalCenter: parent.verticalCenter }
                focus: true
                label: qsTr("Search for GIFs"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-search"
                EnterKey.onClicked: {
                    Gif.search(searchInput.text)
                    focus = false
                    busy.running = true
                }
                inputMethodHints: Qt.ImhNoAutoUppercase
            }

            IconButton {
                width: Theme.iconSizeSmall
                height: width
                anchors { verticalCenter: parent.verticalCenter }
                icon.source: "../resources/images/icon-search.png"
                icon.scale: Theme.iconSizeSmall/icon.width
                onClicked: {
                    Gif.search(searchInput.text)
                    searchInput.focus = false
                    busy.running = true
                }
            }
        }
    }

    SilicaFlickable {
        ViewPlaceholder {
            enabled: gifsModel.count == 0 && !Qt.inputMethod.visible && !busy.running
            text: qsTr("GIF gallery")
            hintText: qsTr("Powered by GIPHY")
        }

        Connections {
            target: Qt.inputMethod
        }
    }
}
