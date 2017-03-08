import QtQuick 2.2
import Sailfish.Silica 1.0


// Sailfinder V3.X external account support TO DO
Dialog {
    property string user: "LOL"
    property string dialogTitle
    property int type

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: reportColumn.height

        VerticalScrollDecorator {}

        Column {
            id: reportColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader { title: dialogTitle; acceptText: qsTr("Report") }

            TextSwitch {
                id: spam
                text: qsTr("SPAM")
                description: user + " " + qsTr("sends you SPAM or other content that you don't want.")
                onCheckedChanged: {
                    if (checked) {
                    other.checked = false
                    inappropriate.checked = false
                    }
                }
            }

            TextSwitch {
                id: inappropriate
                text: qsTr("Inappropriate")
                description: user + " " + qsTr("is inappropriate or offensive against you.")
                onCheckedChanged: {
                    if (checked) {
                    other.checked = false
                    spam.checked = false
                    }
                }
            }

            TextSwitch {
                id: other
                text: qsTr("Other")
                description: user + " " + qsTr("did something that you would like to report.")
                onCheckedChanged: {
                    if (checked) {
                    inappropriate.checked = false
                    spam.checked = false
                    }
                }
            }

            TextArea {
                id: explanation
                width: parent.width
                label: qsTr("Explanation")
                placeholderText: label
                opacity: other.checked? 1.0: 0.0
                Behavior on opacity {
                    FadeAnimation {}
                }
            }
        }
    }
}

