import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("ERROR!")
            }

            SectionHeader { text: qsTr("Report this error") }

            Label {
                anchors {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                wrapMode: Text.WordWrap
                text: qsTr("The error has been copied to your clipboard, please report it on Github or on Openrepos.net (Github is preferred).")
            }

            Label {
                id: errorText
                anchors
                {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: Clipboard.text
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Sailfinder bug tracker")
                onClicked:
                {
                    Qt.openUrlExternally("https://github.com/modulebaan/Sailfinder/issues")
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Sailfinder on Openrepos.net")
                onClicked:
                {
                    Qt.openUrlExternally("https://openrepos.net/content/minitreintje/sailfinder")
                }
            }

            // Spacer
            Rectangle {
                width: parent.width
                height: 30
                color: "transparent"
            }
        }
    }
}
