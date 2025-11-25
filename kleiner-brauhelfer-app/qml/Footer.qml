import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Pane {

    property var swipeView : null

    signal clickedLeft()
    signal clickedRight()

    z: 1
    Material.elevation: 4
    focusPolicy: Qt.StrongFocus

    RowLayout {
        id: layout
        anchors.fill: parent

        ToolButton {
            Layout.leftMargin: 8
            implicitWidth: 24
            implicitHeight: 24
            onClicked: clickedLeft()
            enabled: swipeView && swipeView.currentIndex > 0
            contentItem: Image {
                anchors.fill: parent
                visible: parent.enabled
                source: "qrc:/images/ic_chevron_left.png"
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: Material.primary
                }
            }
        }

        Item {
            Layout.fillWidth: true
            PageIndicator {
                id: pageIndicator
                anchors.centerIn: parent
                count: swipeView.count
                currentIndex: swipeView.currentIndex
                delegate: Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: width / 2
                    color: Material.primary
                    opacity: index === pageIndicator.currentIndex ? 1 : 0.45
                }
            }
        }

        ToolButton {
            Layout.rightMargin: 8
            implicitWidth: 24
            implicitHeight: 24
            onClicked: clickedRight()
            enabled: swipeView && swipeView.currentIndex < swipeView.count - 1
            contentItem: Image {
                anchors.fill: parent
                visible: parent.enabled
                source: "qrc:/images/ic_chevron_right.png"
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: Material.primary
                }
            }
        }
    }
}
