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
import Sailfish.Silica 1.0
import "../components"
import "../js/util.js" as Util

Page {
    property var match

    Component.onCompleted: {
        photoList.photoListModel = match.photos
        bio.text = match.bio
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                // Distance is supported as soon as the API is implemented for full profile
                title: Util.createHeaderMatchProfile(match.name, match.birthDate, match.gender)
            }

            PhotoGridLayout {
                id: photoList
            }

            TextArea {
                id: bio
                width: parent.width
                readOnly: true
                visible: text.length > 0
            }
        }
    }
}
