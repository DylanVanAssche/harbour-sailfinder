import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Item {
        width: parent.width
        height: icon.height + label.height
        visible: cover_data.image_enabled
        anchors.centerIn: parent

        Label {
            id: label
            anchors.bottom: icon.top
            anchors.bottomMargin: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            visible: cover_data.text_enabled
            text: cover_data.text
        }

        Image {
            id: icon
            width: parent.width - Theme.horizontalPageMargin
            height: width
            anchors.centerIn: parent
            asynchronous: true
            smooth: true
            visible: cover_data.image_enabled
            source: !app.network_error? cover_data.image: '../images/noImage.png'
            onStatusChanged:
            {
                if (status == Image.Loading)
                {
                    progressIndicator.running = true
                }
                else if (status == Image.Error)
                {
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
        }
    }

    CoverPlaceholder {
        id: placeholder
        visible: !cover_data.image_enabled && cover_data.text_enabled
        text: cover_data.text
    }

    CoverActionList {
        id: actions
        enabled: cover_data.actions_enabled

        CoverAction {
            iconSource: "../images/dislike_small.png"
            onTriggered:
            {
                if(!app.network_error) // Disable buttons when network error
                {
                    cover_action('dislike')
                }
            }
        }

        CoverAction {
            iconSource: "../images/like_small.png"
            onTriggered:
            {
                if(!app.network_error)
                {
                    cover_action('like')
                }
            }
        }
    }
}


