/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import QtPositioning 5.2

Dialog {
    id: dialog

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            DialogHeader { }

            SectionHeader { text: "Sailfinder" }

            ComboBox {
                id: dataUpdateInterval
                width: parent.width
                label: "Data refresh interval: "
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: "every 15 min" }
                    MenuItem { text: "every 30 min" }
                    MenuItem { text: "every 1 hour" }
                    MenuItem { text: "every 2 hours" }
                    MenuItem { text: "every 4 hours" }
                }
            }

            IconTextSwitch {
                id: hints
                icon.source: "image://theme/icon-m-swipe"
                text: "Hints"
                description: "Show some hints to guide you through Sailfinder."
                checked: false
            }

            IconTextSwitch {
                id: bio
                icon.source: "image://theme/icon-m-about"
                text: "Show bio"
                description: "Show the bio of a person in the main screen."
                checked: false
            }

            SectionHeader { text: "Discovery preferences" }

            IconTextSwitch {
                id: discovery
                icon.source: "image://theme/icon-m-share"
                text: "Discovery"
                description: "Choose if other people can see your Tinder profile or not. This has no effect on your matches you already have."
                checked: true
            }

            SectionHeader { text: "Location" }

            Item {
                id: gpsData
                property alias positionSource: positionSource
                PositionSource {
                    id: positionSource
                    updateInterval: gpsUpdateInterval.value * 60 * 1000
                    active: true
                    onPositionChanged:
                    {
                        python.call('tinder.updateLocation',[positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude], function(latitude, longitude) {});
                        console.log('Updating position')
                    }
                }
            }

            Label {
                id: gpsLatitude
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: "Latitude: " + positionSource.position.coordinate.latitude + '°'
            }

            Label {
                id: gpsLongitude
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: "Longitude: " + positionSource.position.coordinate.longitude + '°'
            }

            Slider {
                id: gpsUpdateInterval
                width: parent.width
                value: 30
                minimumValue: 15
                maximumValue: 60
                stepSize: 1
                valueText: value.toFixed(0)  + " min"
                label: "GPS update interval"
            }

            SectionHeader { text: "Who?" }

            ComboBox {
                id: interestedInGender
                width: parent.width
                label: "Interested in: "
                currentIndex: 1
                menu: ContextMenu {
                    MenuItem { text: "Male" }
                    MenuItem { text: "Female" }
                    //MenuItem { text: "Everyone" } NOT AVAILABLE YET IN PYNDER
                }
            }

            Slider {
                id: minimumAge
                width: parent.width
                value: 18
                minimumValue: 18
                maximumValue: 100
                stepSize: 2
                valueText: value.toFixed(0)
                label: "Minimum age"
                onReleased:
                {
                    if(value > maximumAge.value)
                    {
                        value = maximumAge.value
                    }
                }
            }

            Slider {
                id: maximumAge
                width: parent.width
                value: 100
                minimumValue: 18
                maximumValue: 100
                stepSize: 2
                valueText: value.toFixed(0)
                label: "Maximum age"
                onReleased:
                {
                    if(value < minimumAge.value)
                    {
                        value = minimumAge.value
                    }
                }
            }

            Slider {
                id: searchDistance
                width: parent.width
                value: 160
                minimumValue:2
                maximumValue:160
                stepSize: 2
                valueText: value.toFixed(0) + " km"
                label: "Search distance"
            }

            Label {
                anchors
                {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                text: "Pushing the 'Accept' button will reload your people in the area to match with your new settings."
            }

            Python {
                id: python
                Component.onCompleted:
                {
                    // Add the Python path to PyOtherSide and import our module 'tinder'.
                    addImportPath(Qt.resolvedUrl('.'));
                    importModule('tinder', function() {});

                    // When Python is ready, load the settings...
                    python.call('tinder.getSettings',[], function() {});

                    // Get the settings from Python
                    setHandler('getSettings', function(dataUpdateIntervalValue, hintsState, discoveryState, interestedIn, minAge, maxAge, searchDistanceValue, gpsUpdateIntervalValue, showBio)
                    {
                        discovery.checked = discoveryState
                        interestedInGender.currentIndex = interestedIn
                        minimumAge.value = minAge
                        maximumAge.value = maxAge
                        searchDistance.value = searchDistanceValue
                        gpsUpdateInterval.value = gpsUpdateIntervalValue
                        dataUpdateInterval.currentIndex = dataUpdateIntervalValue
                        hints.checked = hintsState;
                        bio.checked = showBio;
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
                /*onReceived:
                {
                    console.log('Python MESSAGE: ' + data);
                }*/
            }
        }
    }

    onDone:
    {
        if (result == DialogResult.Accepted)
        {
            // Send the settings to Python to save them.
            python.call('tinder.updateSettings',[dataUpdateInterval.currentIndex, hints.checked, discovery.checked, interestedInGender.currentIndex, minimumAge.value, maximumAge.value, searchDistance.value, gpsUpdateInterval.value, bio.checked], function(dataUpdateInterval, hintsState, discoverableState, interestedInIndex, minAge, maxAge, searchDistance, gpsUpdateInterval, showBio) {});
        }
    }
}
