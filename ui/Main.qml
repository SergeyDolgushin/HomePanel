import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts

import "drawer"
import "clock"
import "viewer"

Window {

    id: root
    property color baseColor: "#3498db"
    readonly property color lighterColor: Qt.lighter(baseColor, 2)  // Коэффициент осветления

    width: 640
    height: 480
    visible: true
    title: qsTr("Home Panel")

    visibility: Window.FullScreen

    Rectangle {
            id: contentRect
            anchors.fill: parent


            gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: root.baseColor }
                        GradientStop { position: 1.0; color: root.lighterColor }
                    }
        }

    CustomDrawer {
        id: rightBar

        Clock {
            id: clockWdg
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            Layout.topMargin: 16
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.topMargin: 10
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            color: "white"
            radius: 8
            border.color: "#cccccc"

            Text {
                anchors.centerIn: parent
                text: "Тестовый элемент"
                color: "#333333"
            }

            // Тестовая Кнопка открытия
            Button {
                text: "🖼 Просмотр фото"
                anchors.centerIn: parent
                onClicked: photoViewer.active = true

            }
        }

    }


    // Photo Viewer (поверх всего)
    PhotoViewer {
        id: photoViewer
        anchors.fill: parent
        z: 100
    }

    Component.onCompleted: {
        console.log(root.width, root.height);
    }


}
