import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: aboutColumn.height

        VerticalScrollDecorator {}

        Column {
            id: aboutColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: qsTr("About") }

            SectionHeader { text: qsTr("What's") + " Sailfinder?" }
            TextLabel { labelText: "Sailfinder " + qsTr("is an unofficial Tinder client for Sailfish OS. You can use almost all the features of the official client on your Sailfish OS smartphone!") }

            SectionHeader { text: qsTr("Privacy & licensing") }
            TextLabel { labelText: "Sailfinder " + qsTr("will never collect any personal information about the user, but this can't be guaranteed from any third-party company used in Sailfinder.") }
            TextLabel { labelText: qsTr("This application is released under GPLv3. The source code and the license is available in the Github repo of") +  " Sailfinder." }

            SectionHeader { text: qsTr("Developer & source code") }
            GlassButton { link: "https://github.com/modulebaan"; iconSource: "../resources/images/icon-github.png"; iconText: "Dylan Van Assche"; itemScale: 0.75 }
            GlassButton { link: "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=XTDV5P8JQTHT4"; iconSource: "../resources/images/icon-paypal.png"; iconText: qsTr("Donate with Paypal"); itemScale: 0.75 }
            GlassButton { link: "https://github.com/modulebaan/harbour-sailfinder"; iconSource: "../resources/images/icon-code.png"; iconText: qsTr("Source code"); itemScale: 0.75 }

            SectionHeader { text: qsTr("Powered by") }
            GlassButton { link: "http://fontawesome.io/"; iconSource: "../resources/images/icon-fontawesome.png"; iconText: "FontAwesome icons"; itemScale: 0.75 }
            GlassButton { link: "https://be.linkedin.com/in/sam-goedgezelschap-06a516106"; iconSource: "../resources/images/icon-linkedin.png"; iconText: "Sam Goedgezelschap"; itemScale: 0.75 }
            GlassButton { link: "https://github.com/paomedia/small-n-flat/"; iconSource: "../resources/images/icon-github.png"; iconText: "Paomedia icons"; itemScale: 0.75 }
            GlassButton { link: "http://gitlab.unique-conception.org/thebootroo/mitakuuluu-ui-ng"; iconSource: "../resources/images/icon-gitlab.png"; iconText: "mitakuuluu-ui-ng"; itemScale: 0.75 }
        }
    }
}
