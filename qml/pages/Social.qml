import QtQuick 2.0
import Sailfish.Silica 1.0

SilicaListView {
    width: parent.width; height: parent.height
    model: ListModel {
        ListElement { fruit: "jackfruit" }
        ListElement { fruit: "orange" }
        ListElement { fruit: "lemon" }
        ListElement { fruit: "lychee" }
        ListElement { fruit: "apricots" }
    }
    delegate: Item {
        width: ListView.view.width
        height: Theme.itemSizeSmall
        
        Label { text: fruit }
    }
}
