import QtQuick 2.2
import Sailfish.Silica 1.0
import "js/matches.js" as Matches

Dialog {
    property string user
    property string matchId
    property int reason

    canAccept: spam.checked || inappropriateMessages.checked || inappropriatePictures.checked || offline.checked || (other.checked && explanation.text)
    onAccepted: Matches.report(matchId, reason, explanation.text)

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: reportColumn.height

        VerticalScrollDecorator {}

        Column {
            id: reportColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader { title: qsTr("Report") + " " + user; acceptText: qsTr("Report") }

            TextSwitch {
                id: spam
                text: qsTr("SPAM")
                description: user + " " + qsTr("sends you SPAM or other content that you don't want.")
                onCheckedChanged: {
                    if (checked) {
                        other.checked = false
                        offline.checked = false
                        inappropriatePictures.checked = false
                        inappropriateMessages.checked = false
                        reason = 1
                    }
                }
            }

            TextSwitch {
                id: inappropriateMessages
                text: qsTr("Inappropriate messages")
                description: user + " " + qsTr("is inappropriate or offensive against you while you're messaging with him/her.")
                onCheckedChanged: {
                    if (checked) {
                        other.checked = false
                        spam.checked = false
                        inappropriatePictures.checked = false
                        offline.checked = false
                        reason = 2
                    }
                }
            }

            TextSwitch {
                id: inappropriatePictures
                text: qsTr("Inappropriate pictures")
                description: user + " " + qsTr("shows you inappropriate pictures.")
                onCheckedChanged: {
                    if (checked) {
                        other.checked = false
                        spam.checked = false
                        offline.checked = false
                        inappropriateMessages.checked = false
                        reason = 4
                    }
                }
            }

            TextSwitch {
                id: offline
                text: qsTr("Bad offline behavior")
                description: user + " " + qsTr("behaved badly while you met him/her in real life.")
                onCheckedChanged: {
                    if (checked) {
                        other.checked = false
                        spam.checked = false
                        inappropriatePictures.checked = false
                        inappropriateMessages.checked = false
                        reason = 5
                    }
                }
            }

            TextSwitch {
                id: other
                text: qsTr("Other")
                description: user + " " + qsTr("did something else that you would like to report. You can add an explanation when selecting this option.")
                onCheckedChanged: {
                    if (checked) {
                        offline.checked = false
                        spam.checked = false
                        inappropriatePictures.checked = false
                        inappropriateMessages.checked = false
                        reason = 0
                    }
                }
            }

            TextArea {
                id: explanation
                width: parent.width
                label: qsTr("Explanation")
                placeholderText: label
                opacity: other.checked? 1.0: 0.0
                color: text.length > 0? Theme.primaryColor: "red"
                Behavior on opacity {
                    FadeAnimation {}
                }
            }
        }
    }
}
