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

import QtQuick 2.6
import Sailfish.Silica 1.0
import QtFeedback 5.0

Item {
    property string placeHolderText

    id: messagingBar
    width: parent.width
    height: Theme.itemSizeLarge

    // Harbour incompatible, needs a workaround for their to restrictive rules
    ThemeEffect {
        id: buttonBuzz
        effect: ThemeEffect.PressStrong
    }

    TextArea {
        id: input
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: sendButton.left
            rightMargin: Theme.paddingMediun
        }

        placeholderText: messagingBar.placeHolderText
    }

    IconButton {
        id: sendButton
        icon.source: "qrc:///images/icon-send.png" + (pressed
                                                      ? Theme.highlightColor
                                                      : Theme.primaryColor)
        icon.scale: Theme.iconSizeSmall/icon.width
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        onPressed: buttonBuzz.play()
    }
}
