//import QtQuick 2.0
//import Sailfish.Silica 1.0
//import "js/matches.js" as Matches

//SilicaFlickable {
//    width: parent.width; height: parent.height
//    contentHeight: aboutMatchColumn.height
//    Component.onCompleted: Matches.about(userId)

//    property string userId
//    property bool loadingAbout: true

//    VerticalScrollDecorator {}

//    Column {
//        id: aboutMatchColumn
//        width: parent.width
//        spacing: Theme.paddingLarge

//        TextLabel { labelText: "Sailfinder " + qsTr("is an unofficial Tinder client for Sailfish OS. You can use almost all the features of the official client on your Sailfish OS smartphone!") }


//        /*ImageGrid { id: avatars; visible: loadingAbout }

//        TextArea {
//            id: bio
//            width: parent.width
//            readOnly: true
//            wrapMode: TextEdit.Wrap
//            label: qsTr("Biography")
//            visible: text && settings.showBio && !loadingAbout
//        }

//        GlassButton { id: instagram; show: settings.showInstagram && !loadingAbout; iconSource: "../resources/images/icon-instagram.png"; itemScale: 0.5 }
//        GlassButton { id: job; show: settings.showJob && !loadingAbout; iconSource: "../resources/images/icon-job.png"; itemScale: 0.5 }
//        GlassButton { id: school; show: settings.showSchool && !loadingAbout; iconSource: "../resources/images/icon-school.png"; itemScale: 0.5 }*/
//    }

//    /*BusyIndicator {
//        anchors { centerIn: parent }
//        size: BusyIndicatorSize.Large
//        running: Qt.ApplicationActive && loadingAbout
//    }*/
//}


import QtQuick 2.2
import Sailfish.Silica 1.0
import "js/matches.js" as Matches

Page {
    property string userId
    property string name
    property string header: qsTr("About") + " " + name
    property bool loadingAbout: true

    Component.onCompleted: Matches.about(userId)

    // Placeholder
    Label {
        anchors { centerIn: parent }
        font.pixelSize: Theme.fontSizeExtraLarge
        font.bold: true
        visible: loadingAbout
        text: qsTr("Loading") + "..."
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: aboutColumn.height

        VerticalScrollDecorator {}

        Column {
            id: aboutColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: header }

            ImageGrid { id: avatars; visible: !loadingAbout }

            TextArea {
                id: bio
                width: parent.width
                readOnly: true
                wrapMode: TextEdit.Wrap
                label: qsTr("Biography")
                visible: text && settings.showBio && !loadingAbout
            }

            GlassButton { id: instagram; show: settings.showInstagram && !loadingAbout; iconSource: "../resources/images/icon-instagram.png"; itemScale: 0.5 }
            GlassButton { id: job; show: settings.showJob && !loadingAbout; iconSource: "../resources/images/icon-job.png"; itemScale: 0.5 }
            GlassButton { id: school; show: settings.showSchool && !loadingAbout; iconSource: "../resources/images/icon-school.png"; itemScale: 0.5 }

        }
    }
}
