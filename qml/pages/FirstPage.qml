import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/auth.js" as Auth

Page {
    id: login
    property bool authenticating
    property bool tokenExpired

    Component.onCompleted: {
        returnToLogin? tokenExpired=true: undefined //Enforce login with credentials
        returnToLogin = false //Reset to previous state
    }
    onAuthenticatingChanged: {
        if(authenticating) {
            Auth.auth(email.text, password.text); //Ask user for credentials
            settings.saveEmail = remember.checked
            remember.checked? parameters.facebookEmail = email.text: undefined
        }
    }

    Connections {   // Workaround: modules aren't fully imported yet so we need a signal to make our first Python call
        target: app
        onPythonReadyChanged: pythonReady? Auth.auth("", ""): undefined //Load from cache
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }
            spacing: Theme.paddingMedium

            PageHeader { title: qsTr("Login") }

            //Account header with logo and app name
            AccountHeader {}

            //Spacer
            Item {
                width: parent.width
                height: Theme.itemSizeExtraSmall
            }

            TextField {
                id: email
                anchors { left: parent.left; right: parent.right }
                opacity: (authenticating || !tokenExpired)? 0.0: 1.0
                visible: opacity==0? false: true
                label: qsTr("Facebook e-mail"); placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
                inputMethodHints: Qt.ImhEmailCharactersOnly
                text: settings.saveEmail? parameters.facebookEmail: ""

                Behavior on opacity { FadeAnimation {} }
            }

            PasswordField {
                id: password
                anchors { left: parent.left; right: parent.right }
                opacity: (authenticating || !tokenExpired)? 0.0: 1.0
                visible: opacity==0? false: true
                label: qsTr("Facebook password"); placeholderText: label
                EnterKey.enabled: (text || inputMethodComposing) && email.text
                EnterKey.text: qsTr("Login")
                EnterKey.onClicked: {
                    focus = false
                    authenticating = true
                }

                Behavior on opacity { FadeAnimation {} }
            }

            TextSwitch {
                id: remember
                opacity: (authenticating || !tokenExpired)? 0.0: 1.0
                visible: opacity==0? false: true
                text: qsTr("Remember e-mail")
                checked: settings.saveEmail
                description: qsTr("Your Facebook email will be stored unencrypted on your device.")

                Behavior on opacity { FadeAnimation {} }
            }

            Button {
                text: qsTr("Login")
                enabled: email.text && password.text
                anchors { horizontalCenter: parent.horizontalCenter }
                opacity: (authenticating || !tokenExpired)? 0.0: 1.0
                visible: opacity==0? false: true
                onClicked: authenticating = true

                Behavior on opacity { FadeAnimation {} }
            }

            Label {
                anchors { horizontalCenter: parent.horizontalCenter }
                opacity: (authenticating || !tokenExpired)? 1.0: 0.0
                visible: opacity==0? false: true
                text: qsTr("Authenticating") + "..."
                font.pixelSize: Theme.fontSizeLarge

                Behavior on opacity { FadeAnimation {} }
            }

            ProgressBar {
                width: parent.width
                minimumValue: 0
                maximumValue: 100
                opacity: (authenticating || !tokenExpired)? 1.0: 0.0
                visible: opacity==0? false: true
                value: authenticatingProgress
                label: authenticatingText

                Behavior on opacity { FadeAnimation {} }
            }
        }
    }
}
