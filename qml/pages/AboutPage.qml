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

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About")
            }

            SectionHeader { text: "Sailfinder" }

            Label {
                anchors {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: "Sailfinder is an unofficial Tinder client for Sailfish OS. The application is completely opensource and based on PyOtherSide and the Python module 'Pynder'."
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Sailfinder bug tracker"
                onClicked: {
                    Qt.openUrlExternally("https://github.com/modulebaan/Sailfinder/issues")
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Sailfinder on Openrepos.net"
                onClicked: {
                    Qt.openUrlExternally("https://openrepos.net/content/minitreintje/sailfinder")
                }
            }

            SectionHeader { text: "Support Sailfinder!" }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Donate with Paypal"
                onClicked: {
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=XTDV5P8JQTHT4")
                }
            }

            Label {
                anchors {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: "I put in a lot of time to develop Sailfinder so please buy me a coffee :)"
            }

            SectionHeader { text: "Other" }

            Label {
                anchors {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: "Developped by Dylan Van Assche aka minitreintje"
            }

            Label {
                anchors {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: "Thanks to Charlie Wolf for his great Python module Pynder!"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Pynder on Github"
                onClicked:
                {
                    Qt.openUrlExternally("https://github.com/charliewolf/pynder")
                }
            }

            Label {
                anchors
                {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: "Icons by Paomedia"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Paomedia icons on Github"
                onClicked:
                {
                    Qt.openUrlExternally("https://github.com/paomedia/small-n-flat/")
                }
            }

            Label {
                anchors
                {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: "MessagesPage based on 'mitakuuluu-ui-ng' from Thomas Boutroue"
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Mitakuuluu-ui-ng on Gitlab"
                onClicked:
                {
                    Qt.openUrlExternally("http://gitlab.unique-conception.org/thebootroo/mitakuuluu-ui-ng")
                }
            }

            Rectangle {
                height: 20
                width: parent.width
                color: "transparent"
            }
        }
    }
}
