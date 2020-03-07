import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtWebView 1.14

Window {
    visible: true
    width: Screen.width
    height: Screen.height
    title: qsTr("8 Steps 2 Hitler")

    ListModel {
        id: urlPath
    }

    PanelBackground {
        id: panel
        property int stepsLeft: 0
        property int gameStatus: 0

        readonly property string randomPage: qsTr("https://en.wikipedia.org//wiki/Special:Random")
        readonly property string targetPage: qsTr("https://en.wikipedia.org/wiki/Adolf_Hitler")
        readonly property var wikiPageRe: new RegExp("^https://\\w{2}\\.wikipedia\\.org/wiki")
        readonly property int maxStepAvailable: 8

        color: "#ffffff"

        width: parent.width
        height: Math.min(parent.height * 0.1, 100)

        Row {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 5

            Text {
                height: parent.height
                width: 140
                text: qsTr("Amount of steps: ")

                visible: panel.state == "PLAYING"

                font.pointSize: 14
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: stepsAmount
                height: parent.height
                width: 50
                color: panel.stepsLeft < 3 ? "red" : "black"
                visible: panel.state == "PLAYING"

                text: panel.stepsLeft
                font.pointSize: 20
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            ComboBox {
                id: languageSelectBox
                height: parent.height * 0.6
                width: 80
                anchors.verticalCenter: parent.verticalCenter

                visible: panel.state !== "PLAYING"


                model: translatorsModel
                textRole: "code"

                onCurrentTextChanged: {
                    translatorsModel.selectedLanguage = languageSelectBox.currentText;
                }

                background: Rectangle {
                    width: languageSelectBox.width
                    height: languageSelectBox.height
                    border.color: "#000000"
                    border.width: 2
                    color: "white"
                }
            }

            Button {
                id: startButton
                height: parent.height * 0.6
                width: 100
                anchors.verticalCenter: parent.verticalCenter

                text: panel.state == "PLAYING" ? qsTr("Restart") : qsTr("Start")

                onClicked: {
                    if (panel.state != "PLAYING")
                        panel.state = "PLAYING";
                    else {
                        panel.state = "NOT_PLAYING";
                        panel.state = "PLAYING";
                    }
                }

                contentItem: Text {
                    text: startButton.text
                    font {
                        family: startButton.font.family
                        pointSize: startButton.down ? 10 : 12
                    }

                    color: "#000000"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                background: Rectangle {
                    width: startButton.width
                    height: startButton.height
                    border.color: "#000000"
                    border.width: 2
                    color: startButton.down ? "red" : "white"
                }
            }

            ListView {
                id: visualUrlPath

                anchors.verticalCenter: parent.verticalCenter
                height: parent.height * 0.6
                width: parent.width

                interactive: false

                orientation: ListView.Horizontal

                model: urlPath
                delegate: Text {
                    height: visualUrlPath.height
                    text: title
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }

                onCountChanged: {
                    currentIndex = count;
                }
            }
        }

        states: [
            State {
                name: "NOT_PLAYING"
                PropertyChanges {
                    target: infoScreen
                    color: "white"
                }
                PropertyChanges {
                    target: infoText
                    text: qsTr("Select langauge and press Start!\nTry to find a page about Hitler from a random one!")
                }
                StateChangeScript {
                    script: {
                        urlPath.clear();
                    }
                }
            },
            State {
                name: "PLAYING"
                PropertyChanges {
                    target: panel
                    stepsLeft: panel.maxStepAvailable
                }
                PropertyChanges {
                    target: webView
                    url: panel.randomPage
                    previousPage: ""
                }
                StateChangeScript {
                    script: {
                        urlPath.clear();
                    }
                }
            },
            State {
                name: "WIN"
                PropertyChanges {
                    target: infoScreen
                    color: "green"
                }
                PropertyChanges {
                    target: infoText
                    text: qsTr("Congratulation! You Won!")
                }
            },
            State {
                name: "LOSE"
                PropertyChanges {
                    target: infoScreen
                    color: "red"
                }
                PropertyChanges {
                    target: infoText
                    text: qsTr("You Lost! Try again!")
                }
            },
            State {
                name: "TECHNICAL_LOSE"
                PropertyChanges {
                    target: infoScreen
                    color: "yellow"
                }
                PropertyChanges {
                    target: infoText
                    text: qsTr("Don't leave wiki site! Try again!")
                }
            }

        ]
        state: "NOT_PLAYING"
    }

    WebView {
        id: webView
        property string previousPage: ""

        function getPageTitle(url) {
            const parts = url.toString().split("/");
            const last_part = parts[parts.length - 1]
            return last_part.replace(/_/g, " ");
        }

        z: 1

        anchors {
            left: parent.left
            right: parent.right
            top: panel.bottom
            bottom: parent.bottom
        }

        onUrlChanged: {
            const baseUrl = url.toString().split('#')[0];

            if (url == panel.targetPage)
            {
                panel.state = "WIN";
                urlPath.append({title: getPageTitle(baseUrl)});
                return;
            }

            // Check for inner-page link
            if (!panel.wikiPageRe.test(baseUrl))
            {
                panel.state = "TECHNICAL_LOSE";
                return;
            }

            // Don't sub one step, if it was inner-page link
            if (previousPage !== baseUrl) {
                if (previousPage)
                    panel.stepsLeft -= 1;
                urlPath.append({title: getPageTitle(baseUrl) + "->"});
            }

            previousPage = baseUrl;

            if (!panel.stepsLeft) {
                panel.state = "LOSE";
                urlPath.append({title: getPageTitle(baseUrl)});
            }
        }

        Rectangle {
            id: infoScreen
            anchors.fill: parent
            z: 2

            visible: panel.state != "PLAYING"

            Text {
                id: infoText
                font.family: "Source Code Pro Black"
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 22
                anchors.fill: parent
            }

            Text {
                id: phrase
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }

                width: parent.width
                height: 100

                font {
                    pointSize: 14
                    italic: true
                    family: "Source Code Pro Black"
                }

                wrapMode: Text.WordWrap

                text: qsTr("Everything could be related to a Hitler, if you're convincing enough...")
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
