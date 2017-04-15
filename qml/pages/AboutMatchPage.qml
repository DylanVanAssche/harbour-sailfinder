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
