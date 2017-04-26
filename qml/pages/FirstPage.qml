import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/auth.js" as Auth

Page {
    id: login
    property bool authenticating
    property bool tokenExpired
    property bool verifying
    property int phoneVerification

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

            TextLabel { labelText: qsTr("Verify your account by entering your phone number in international format below") + ":"; visible: phoneVerification==1  && !verifying }
            TextLabel { labelText: qsTr("Enter your received SMS code below") + ":"; visible: phoneVerification==2 && !verifying }

            TextField {
                id: phoneNumber
                anchors { left: parent.left; right: parent.right }
                visible: phoneVerification==1 && !verifying
                label: qsTr("Phonenumber"); placeholderText: qsTr("+[country][number]")
                validator: RegExpValidator { regExp: /^[0-9\+\-\#\*\ ]{6,}$/ }
                color: errorHighlight? "red" : Theme.primaryColor
                EnterKey.enabled: !errorHighlight && !verifying
                EnterKey.text: qsTr("OK")
                EnterKey.onClicked: Auth.requestSMS(text)
                focus: visible
                inputMethodHints: Qt.ImhDialableCharactersOnly
            }

            TextField {
                id: code
                anchors { left: parent.left; right: parent.right }
                visible: phoneVerification==2 && !verifying
                label: qsTr("SMS code"); placeholderText: label
                validator: RegExpValidator { regExp: /^\d+$/  }///^[0-9]+$/
                color: errorHighlight || text.length!=6? "red" : Theme.primaryColor
                EnterKey.enabled: !errorHighlight && text.length == 6 && !verifying
                EnterKey.text: qsTr("OK")
                EnterKey.onClicked: Auth.verify(text)
                focus: visible
                inputMethodHints: Qt.ImhDigitsOnly
            }

            BusyIndicator {
                anchors { centerIn: parent }
                size: BusyIndicatorSize.Large
                running: verifying && Qt.application.active
                visible: running
            }

            Button { // Confirm SMS verification
                text: qsTr("OK")
                enabled: phoneVerification==1? !phoneNumber.errorHighlight: !code.errorHighlight && code.text.length == 6 && !verifying
                anchors { horizontalCenter: parent.horizontalCenter }
                opacity: (phoneVerification==1 || phoneVerification==2) && !verifying? 1.0: 0.0
                visible: opacity==0? false: true
                onClicked: {
                    switch(phoneVerification) {
                    case 1:
                        Auth.requestSMS(phoneNumber.text);
                        break;

                    case 2:
                        Auth.verify(code.text);
                        break;
                    }
                }

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
                opacity: (authenticating || !tokenExpired) && !phoneVerification? 1.0: 0.0
                visible: opacity==0? false: true
                text: qsTr("Authenticating") + "..."
                font.pixelSize: Theme.fontSizeLarge

                Behavior on opacity { FadeAnimation {} }
            }

            ProgressBar {
                width: parent.width
                minimumValue: 0
                maximumValue: 100
                opacity: (authenticating || !tokenExpired) && !phoneVerification? 1.0: 0.0
                visible: opacity==0? false: true
                value: authenticatingProgress
                label: authenticatingText

                Behavior on opacity { FadeAnimation {} }
            }
        }
    }
}
