import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import QtPositioning 5.2

Dialog {
    id: page

    onStatusChanged:
    {
        if(status == PageStatus.Active)
        {
            cover_data.text = qsTr("Settings")
            cover_data.image = '../images/settings.png'
            cover_data.text_enabled = true
            cover_data.image_enabled = true
            cover_data.actions_enabled = false
        }
    }

    property string mapquest_key: '7jwW2xkWwiapD8K4rLkiKlSxOPqSKiLG'
    property var latitude: ''
    property var longitude: ''

    NetworkStatus {}

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Settings")
            }

            RemorsePopup {
                id: remorse
            }

            SectionHeader { text: "Recommendations" }

            IconTextSwitch {
                id: bio
                icon.source: {
                    if (Screen.width < app.widthScreenLimit)
                    {
                        "../images/bio_small.png"
                    }
                    else
                    {
                        "../images/bio_large.png"
                    }
                }
                text: qsTr("Show bio")
                checked: false
            }

            IconTextSwitch {
                id: school
                icon.source: {
                    if (Screen.width < app.widthScreenLimit)
                    {
                        "../images/school_small.png"
                    }
                    else
                    {
                        "../images/school_large.png"
                    }
                }
                text: qsTr("Show school")
                checked: false
            }

            IconTextSwitch {
                id: job
                icon.source: {
                    if (Screen.width < app.widthScreenLimit)
                    {
                        "../images/job_small.png"
                    }
                    else
                    {
                        "../images/job_large.png"
                    }
                }
                text: qsTr("Show job")
                checked: false
            }

            IconTextSwitch {
                id: instagram
                icon.source: {
                    if (Screen.width < app.widthScreenLimit)
                    {
                        "../images/instagram_small.png"
                    }
                    else
                    {
                        "../images/instagram_large.png"
                    }
                }
                text: qsTr("Show Instagram account")
                checked: false
            }

            SectionHeader { text: qsTr("Location") }

            Label {
                id: gps_lat
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: qsTr("Latitude: ") + latitude + '°'
                visible: location.position.latitudeValid && location.position.longitudeValid
            }

            Label {
                id: gps_lon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: qsTr("Longitude: ") + longitude + '°'
                visible: location.position.latitudeValid && location.position.longitudeValid
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                text: qsTr("Waiting for GPS signal...")
                visible: !location.position.latitudeValid || !location.position.longitudeValid
            }

            Image {
                id: map
                width: parent.width
                height: width
                anchors
                {
                    left: parent.left
                    right: parent.right
                }
                asynchronous: true
                smooth: true
                antialiasing: true
                visible: location.position.latitudeValid && location.position.longitudeValid
                enabled: visible
                source: "https://open.mapquestapi.com/staticmap/v4/getmap?key=" + mapquest_key + "&center=" + location.position.coordinate.latitude + "," + location.position.coordinate.longitude + "&zoom=" + zoom_map.value +"&size=" + parent.width + "," + parent.width + "&type=map&imagetype=jpeg&pois=red_1-GPS," + location.position.coordinate.latitude + "," + location.position.coordinate.longitude
                onStatusChanged:
                {
                    if (status == Image.Loading)
                    {
                        progressIndicator.running = true
                    }
                    else if (status == Image.Error)
                    {
                        source = '../images/noImage.png'
                        progressIndicator.running = false
                    }
                    else
                    {
                        progressIndicator.running = false
                    }
                }

                BusyIndicator {
                    id: progressIndicator
                    anchors.centerIn: parent
                    size: BusyIndicatorSize.Medium
                    running: true
                }

                Rectangle {
                    z: 1
                    width: parent.width
                    height: parent.height
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Theme.secondaryHighlightColor
                    border.width: Theme.paddingLarge
                }
            }

            Slider {
                id: zoom_map
                width: parent.width
                value: 14
                minimumValue: 1
                maximumValue: 18
                stepSize: 1
                valueText: ((value/18)*100).toFixed(0)  + " %"
                visible: location.position.latitudeValid && location.position.longitudeValid
                label: qsTr("🔎 Zoom map")
            }

            SectionHeader { text: "Network status" }

            Label {
                id: network_state
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                text: qsTr("Offline")
                color: text==qsTr("Offline")? "red": Theme.primaryColor
                font.bold: true
            }

            DetailItem {
                id: network_name
                label: qsTr("Name")
                value: qsTr("N/A")
                visible: network_state.text==qsTr("Offline")? false: true
            }

            DetailItem {
                id: network_type
                label: qsTr("Type")
                value: qsTr("N/A")
                visible: network_state.text==qsTr("Offline")? false: true
            }

            DetailItem {
                id: network_signal_strength
                label: qsTr("Signal strength")
                value: qsTr("N/A")
                visible: network_state.text==qsTr("Offline")? false: true
            }

            SectionHeader { text: qsTr("Logout") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Logout Tinder")
                color: 'red'
                onClicked:
                {
                    remorse.execute("Logging out", function()
                    {
                        python.call('api.remove_tinder_token',[], function() {});
                        Qt.quit()
                    })
                }
            }

            SectionHeader { text: qsTr("About this app") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl('SailfinderPage.qml'));
            }

            // Spacer
            Item {
                height: Theme.paddingLarge
                width: parent.width
            }
        }
    }

    Timer {
        running: location.position.latitudeValid && location.position.longitudeValid
        repeat: true
        interval: 30*1000
        triggeredOnStart: true
        onTriggered:
        {
            latitude = location.position.coordinate.latitude
            longitude = location.position.coordinate.longitude
        }
    }

    Item {
        id: gps_data
        property alias positionSource: location
        PositionSource {
            id: location
            updateInterval: 5000
            active: true
            onPositionChanged:
            {
                console.log("[INFO] Position changed")
            }
        }
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // When Python is ready, ask for our settings
            python.call('api.get_settings',[], function() {});
            python.call('network.connection',[], function() {});

            setHandler('settings', function(settings)
            {
                //console.log(JSON.stringify(settings))
                bio.checked = parseInt(settings['bio']);
                school.checked = parseInt(settings['school']);
                job.checked = parseInt(settings['job']);
                instagram.checked = parseInt(settings['instagram']);
            });

            setHandler('network', function(status, type, name, signal_strength)
            {
                console.log(JSON.stringify(type));
                console.log(JSON.stringify(name));
                console.log(JSON.stringify(signal_strength));
                if(status[0] == "connected")
                {
                    network_state.text = qsTr("Online")
                    network_type.value = type[0]
                    network_name.value = name[0]
                    network_signal_strength.value = signal_strength[0] + '%'
                }

            });
        }

        onError:
        {
            console.log('Python ERROR: ' + traceback);
            Clipboard.text = traceback
            pageStack.completeAnimation();
            pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
            pageStack.completeAnimation();
        }

        //DEBUG
        onReceived:
        {
            console.log('Python MESSAGE: ' + JSON.stringify(data));
        }
    }

    onAccepted:
    {
        python.call('api.save_settings',[(bio.checked * bio.checked), (school.checked * school.checked), (job.checked * job.checked), (instagram.checked * instagram.checked)], function(bio, school, job, instagram) {});
    }
}

