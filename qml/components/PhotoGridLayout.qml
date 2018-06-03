/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0
import Harbour.Sailfinder.Models 1.0

Item {
    property var photoListModel
    property bool editable
    property bool _showRemoveButton
    signal removed(string photoId)

    width: parent.width
    height: parent.width

    function closeFullScreen() {
        fullScreen.visible = false
    }

    GridLayout {
        id: layout
        anchors.fill: parent // IMPORTANT: Using GridLayout without this will fail!
        columns: 3
        columnSpacing: 0
        rowSpacing: 0

        Repeater {
            id: repeater
            model: photoListModel

            function forceFirstItem() {
                // The 1st picture is always 2x bigger
                itemAt(0).Layout.columnSpan = 2
                itemAt(0).Layout.rowSpan = 2
            }

            Item {
                width: Layout.columnSpan*parent.width/parent.columns
                height: Layout.rowSpan*parent.width/parent.columns
                Layout.minimumWidth: width
                Layout.minimumHeight: height
                Layout.preferredWidth: width
                Layout.preferredHeight: height
                Layout.maximumWidth: parent.width
                Layout.maximumHeight: parent.height
                Layout.fillHeight: true
                Layout.fillWidth: true

                Image {
                    id: image
                    width: parent.width
                    height: parent.height
                    sourceSize.width: width
                    sourceSize.height: height
                    source: {
                        switch(api.getBearerType())
                        {
                            case Sailfinder.Ethernet: // Ethernet
                                return model.urlFull
                            case Sailfinder.WLAN: // WLAN
                                return model.urlLarge
                            case Sailfinder.LTE: // 4G
                                return model.urlMedium
                            case Sailfinder.UTMS: // 3G
                                return model.urlSmall
                            case Sailfinder.GPRS: // 2G
                                return model.urlAvatar
                            default: // Unknown
                                return model.urlMedium
                        }
                    }
                    asynchronous: true
                    opacity: progress
                    visible: index < 6 // Max 6 photos
                    Behavior on opacity { FadeAnimator {} }
                    onStatusChanged: {
                        if(status == Image.Error) {
                            console.warn("Can't load image")
                            errorText.visible = true
                            loadIndicator.running = false
                            _showRemoveButton = false
                        }
                        else if(status == Image.Ready) {
                            errorText.visible = false
                            loadIndicator.running = false
                        }
                        else {
                            errorText.visible = false
                            loadIndicator.running = Qt.application.active
                            _showRemoveButton = false
                        }
                    }

                    MouseArea {
                        id: touch
                        anchors.fill: parent
                        enabled: image.status == Image.Ready && repeater.count > 1
                        onClicked: {
                            fullScreen.source = image.source
                            fullScreen.visible = true
                            _showRemoveButton = false
                        }
                        onPressAndHold: {
                            if(editable) {
                                fullScreen.source = image.source
                                fullScreen.visible = true
                                deleteOverlay.photoId = model.id
                                _showRemoveButton = true
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.highlightColor
                        opacity: 0.33
                        visible: touch.pressed
                    }
                }

                Label {
                    id: errorText
                    anchors.centerIn: parent
                    visible: false
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                    //% "Oops!"
                    text: qsTrId("sailfinder-oops")
                }

                BusyIndicator {
                    id: loadIndicator
                    size: BusyIndicatorSize.Large
                    anchors.centerIn: parent
                }
            }

            onModelChanged: forceFirstItem()
        }
    }

    Image {
        id: fullScreen
        width: parent.width
        height: parent.width
        anchors.centerIn: parent
        visible: false
        asynchronous: true
        z: 1

        MouseArea {
            id: touchFull
            anchors.fill: parent
            enabled: repeater.count > 1
            onClicked: fullScreen.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.highlightColor
            opacity: 0.33
            visible: touchFull.pressed
        }

        Rectangle {
            property string photoId

            id: deleteOverlay
            anchors.fill: parent
            visible: editable? _showRemoveButton: false
            color: Theme.highlightDimmerColor
            opacity: 0.77

            IconButton {
                anchors.centerIn: parent
                icon.source: "qrc:///images/remove.png" + (pressed
                                                           ? Theme.highlightColor
                                                           : Theme.primaryColor)
                onClicked: {
                    _showRemoveButton = false
                    fullScreen.visible = false
                    removed(deleteOverlay.photoId)
                }
            }
        }
    }
}
