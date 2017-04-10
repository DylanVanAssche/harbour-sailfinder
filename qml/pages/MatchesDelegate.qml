import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/matches.js" as Matches

ListItem {
    id: matchDelegate
    width: ListView.view.width
    contentHeight: Theme.iconSizeExtraLarge*1.2
    onClicked: pageStack.push(Qt.resolvedUrl("MessagingPage.qml"), { name: model.name, lastSeen: model.lastSeen, avatarImage: model.avatar, userIndex: index, userId: model.id, matchId: model.matchId })

    Row {
        anchors { verticalCenter: parent.verticalCenter }
        x: Theme.horizontalPageMargin
        spacing: Theme.paddingMedium

        Image {
            id: avatar
            width: Theme.iconSizeExtraLarge; height: width
            source: model.avatar
            asynchronous: true

            BusyIndicator {
                anchors { centerIn: parent }
                running: (avatar.status === Image.Ready)? false: Qt.ApplicationActive
                size: BusyIndicatorSize.Medium
            }
        }

        Label {
            anchors { verticalCenter: parent.verticalCenter }
            font.pixelSize: Theme.fontSizeLarge
            text: model.name
        }

        Image {
            width: Theme.iconSizeMedium; height: width
            anchors { verticalCenter: parent.verticalCenter }
            source: "image://theme/icon-m-favorite-selected"
            visible: model.isSuperlike
            asynchronous: true
        }
    }

    // Remorse timer item when unmatching
    RemorseItem { id: remorse }

    // Animations after unmatching or adding matches
    ListView.onAdd: AddAnimation {
        target: matchDelegate
    }

    ListView.onRemove: RemoveAnimation {
        target: matchDelegate
    }

    // Menu
    menu: ContextMenu {
        MenuItem {
            text: qsTr("About")
            visible: !model.avatar.match("__internal_user__")
            onClicked: pageStack.push(Qt.resolvedUrl('AboutMatchPage.qml'), { userId: model.id, name: model.name })
        }
        MenuItem {
            text: qsTr("Unmatch")
            onClicked: remorse.execute(matchDelegate, qsTr("Unmatching"), function() {
                Matches.unmatch(model.matchId)
                matchesModel.remove(index)
                refreshing = true // Block UI until refresh is completed
            });
        }
        MenuItem {
            text: qsTr("Report")
            visible: !model.avatar.match("__internal_user__")
            onClicked: pageStack.push(Qt.resolvedUrl("ReportPage.qml"), { user: model.name, matchId: model.matchId })
        }
    }
}
