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

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Image {
        width: parent.width
        height: parent.height
        opacity: 0.5
        fillMode: Image.PreserveAspectCrop
        source: app.coverBackground
        asynchronous: true
    }

    Rectangle {
        width: parent.width
        height: Theme.itemSizeSmall
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right }
        color: Theme.highlightBackgroundColor
        opacity: 0.75

        Row {
            anchors { fill: parent }

            Image {
                id: icon
                anchors { verticalCenter: parent.verticalCenter }
                scale: Theme.iconSizeSmallPlus/width
                source: "../resources/images/cover-logo.png"
                asynchronous: true
            }

            Label {
                width: parent.width - icon.width
                anchors { verticalCenter: parent.verticalCenter }
                font.bold: true
                wrapMode: Text.WrapAnywhere
                truncationMode: TruncationMode.Fade
                text: app.coverText
            }
        }
    }
}

