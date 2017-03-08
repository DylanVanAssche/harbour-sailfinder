//import QtQuick 2.2
//import QtWebKit 3.0
//import Sailfish.Silica 1.0
//import io.thp.pyotherside 1.3
//import QtPositioning 5.2

//Page {

//    property string fb_token: ''
//    property string fb_id: ''

//    PageHeader {
//        id: header
//        anchors.top: parent.top
//        title: qsTr("Logging in...")
//        visible: !webView.visible && !app.network_error
//    }

//    NetworkStatus {}

//    Button {
//        id: retry
//        anchors.top: message.bottom
//        anchors.topMargin: Theme.paddingLarge
//        anchors.horizontalCenter: parent.horizontalCenter
//        visible: false
//        text: qsTr("Retry")
//        onClicked: python.call('api.loginTinder',[fb_id, fb_token], function(fb_token) {})
//    }

//    /*Item {
//        id: facebook_login
//        anchors.fill: parent
//        visible: false
//        onVisibleChanged:
//        {
//            if(visible)
//            {
//                header.title = app.name + ' ' + app.version
//            }
//        }

//        Image {
//            id: icon
//            width: Theme.iconSizeExtraLarge
//            height: width
//            anchors.centerIn: parent
//            source: '../images/harbour-sailfinder.png'
//            asynchronous: true
//            smooth: true
//            antialiasing: true
//            opacity: app.network_error? 0.2: 1.0
//            onStatusChanged:
//            {
//                if (status == Image.Loading)
//                {
//                    progressIndicator.running = true
//                }
//                else if (status == Image.Error)
//                {
//                    source = '../images/noImage.png'
//                    progressIndicator.running = false
//                }
//                else
//                {
//                    progressIndicator.running = false
//                }
//            }

//            BusyIndicator {
//                id: progressIndicator
//                anchors.centerIn: parent
//                size: BusyIndicatorSize.Medium
//                running: true
//            }
//        }

//        Button {
//            id: login_button
//            anchors.top: icon.bottom
//            anchors.topMargin: Theme.paddingLarge
//            anchors.horizontalCenter: parent.horizontalCenter
//            text: qsTr("Login with Facebook")
//            opacity: app.network_error? 0.2: 1.0
//            onClicked: {
//                webView.visible = true;
//                message.enabled = false;
//                header.visible = false;
//            }
//        }
//    }*/

//    /*SilicaWebView {
//        id: webView
//        width: parent.width
//        height: parent.height
//        anchors
//        {
//            top: parent.top
//            left: parent.left
//            right: parent.right
//            bottom: parent.bottom
//        }
//        focus: true
//        visible : false
//        url: "https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=fbconnect://success&scope=basic_info%2Cemail%2Cpublic_profile%2Cuser_about_me%2Cuser_activities%2Cuser_birthday%2Cuser_education_history%2Cuser_friends%2Cuser_interests%2Cuser_likes%2Cuser_location%2Cuser_photos%2Cuser_relationship_details&response_type=token&__mref=message"
//        onNavigationRequested:
//        {
//            if(visible)
//            {
//                // When the URL has been changed, send it to Python to check if it contains an ACCESS TOKEN.
//                console.log('Request URL from FACEBOOK: ' + request.url)
//                python.call('api.loginFacebook',[request.url.toString()], function(url) {});
//            }
//        }
//    }*/

//    SilicaFlickable {

//    Column { /*Replaces the old webview*/
//        id: webView
//        anchors.fill: parent

//    Label {
//        text: qsTr("Facebook credentials")
//        anchors.horizontalCenter: parent.horizontalCenter
//        font.pixelSize: Theme.fontSizeLarge
//    }

//    TextField {
//        id: usernameFB2
//        focus: true
//        placeholderText: qsTr("Facebook email")
//        EnterKey.onClicked: passwordFB.focus = true
//    }

//    TextField {
//        id: emailFB
//        placeholderText: qsTr("Facebook e-mail")
//    }

//    PasswordField {
//        id: passwordFB
//        placeholderText: qsTr("Facebook password")
//    }

//    Button {
//        id: loginbutton
//        text: qsTr("Login")
//        onClicked: python.call('api.get_access_token',[emailFB.text, passwordFB.text], function(email, pass) {});
//    }
//    }
//    }


//    ViewPlaceholder {
//        id: message
//        anchors.centerIn: parent
//        enabled: !webView.visible
//        text: qsTr('Logging into Tinder')
//        hintText: qsTr("Validating credentials...")
//    }

//    Python {
//        id: python
//        Component.onCompleted:
//        {
//            addImportPath(Qt.resolvedUrl('../pages/'));
//            importModule('api', function() {});

//            addImportPath(Qt.resolvedUrl('../pages/lib/'));
//            importModule('network', function() {});

//            console.log('[INFO] App: ' + app.name + ' ' + app.version)
//            cover_data.text = qsTr("Logging in...")
//            cover_data.text_enabled = true
//            cover_data.image_enabled = false

//            python.call('network.connection',[], function() {});

//            // When Python is ready prepare our configuration files.
//            python.call('api.init_files',[], function() {});

//            // Check if we have already authenticated with Tinder then we can reuse the Tinder token.
//            python.call('api.read_tinder_token',[], function() {});

//            // When Python has succesfully extracted the login data we can login into Tinder.
//            setHandler('loginFacebook', function(id, token)
//            {
//                if(token)
//                {
//                    fb_token = token;
//                    fb_id = id;
//                    //console.log("Facebook ID: " + JSON.stringify(fb_id))
//                    console.log('[LOGIN] Facebook login OK, Facebook UserID: ' + id + ' & Facebook Graph token: ' + token)
//                    webView.visible = false;
//                    facebook_login.visible = false;
//                    message.text = qsTr('Logging into Tinder')
//                    message.hintText = qsTr("Validating credentials...")
//                    message.enabled = true;
//                    header.visible = true;
//                    python.call('api.loginTinder',[fb_id, fb_token], function(fb_id, fb_token) {});
//                    // call python login tinder
//                }
//                else
//                {
//                    // When Python couldn't receive the USER-ID from the Facebook Graph API then we should try to login in again.
//                    console.log('[LOGIN] Facebook login FAILED')
//                }
//            });

//            setHandler('loginTinder', function(token)
//            {
//                if(token)
//                {
//                    console.log('[LOGIN] Tinder login OK, X-Auth-token: ' + token)
//                    pageStack.completeAnimation()
//                    pageStack.replace(Qt.resolvedUrl('MainPage.qml'));
//                }
//                else
//                {
//                    // When Python couldn't login into Tinder, show the user a message and a button to try again.
//                    console.log('[LOGIN] Tinder login FAILED')
//                    message.text = qsTr('Failed to login :-(')
//                    message.hintText = qsTr("Tinder login token expired!")
//                    webView.visible = true
//                }
//            });
//        }

//        onError:
//        {
//            console.log('Python ERROR: ' + traceback);
//            Clipboard.text = traceback
//            pageStack.completeAnimation();
//            pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
//        }

//        //DEBUG
//        onReceived:
//        {
//            console.log('Python MESSAGE: ' + JSON.stringify(data));
//        }
//    }
//}

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Login")
            }

            TextField {
                id: email
                anchors { left: parent.left; right: parent.right }
                focus: true; label: "Email address"; placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: password.focus = true
            }

            PasswordField {
                id: password
                anchors { left: parent.left; right: parent.right }
                echoMode: TextInput.Password
                label: "Password"; placeholderText: label
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Label {
                id: message
                text: "Enter your credentials for your Facebook account you use for Tinder."
                width: parent.width
                wrapMode: Text.WordWrap
                x: Theme.horizontalPageMargin
            }

            Button {
                text: "LOGIN"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: python.call('api.get_access_token',[email.text, password.text], function(email, pass) {});
            }
        }
    }

    Python {
        id: python
        Component.onCompleted:
        {
            addImportPath(Qt.resolvedUrl('.'));
            importModule('api', function() {});

            console.log('[INFO] App: ' + app.name + ' ' + app.version)
            cover_data.text = qsTr("Logging in...")
            cover_data.text_enabled = true
            cover_data.image_enabled = false

            // When Python is ready prepare our configuration files.
            python.call('api.init_files',[], function() {});

            // Check if we have already authenticated with Tinder then we can reuse the Tinder token.
            python.call('api.read_tinder_token',[], function() {});

            setHandler('login', function(token_tinder, token_fb)
            {
                console.log('[LOGIN] Tinder login, X-Auth-token: ' + token_tinder)
                console.log('[LOGIN] Facebook login, token: ' + token_fb)
                if(token_tinder && token_fb)
                {
                    console.log('[LOGIN] Valid tokens :-)')
                    pageStack.completeAnimation()
                    pageStack.replace(Qt.resolvedUrl('MainPage.qml'));
                }
                else
                {
                    // When Python couldn't login into Tinder, show the user a message and a button to try again.
                    console.log('[LOGIN] Login FAILED!')
                    message.text = qsTr("Login failed :-(, check your e-mail & password.")
                }
            });
        }

        onError:
        {
            console.log('Python ERROR: ' + traceback);
            Clipboard.text = traceback
            pageStack.completeAnimation();
            pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
        }

        //DEBUG
        onReceived:
        {
            console.log('Python MESSAGE: ' + JSON.stringify(data));
        }
    }
}

