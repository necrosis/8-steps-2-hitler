import QtQuick 2.0

Rectangle {
    id: backPanel
    color: "#ffffff"

    Rectangle {
        id: topLine
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: parent.height * 0.33
        color: "red"
    }

    Rectangle {
        id: bottomLine
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: parent.height * 0.33
        color: "red"
    }

    Rectangle {
        id: rightCircle

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        width: height
        radius: width / 2

        Image {
            anchors.fill: parent
            anchors.margins: 3
            fillMode: Image.PreserveAspectFit
            source: "img/chaplin.png"
        }
    }
}
