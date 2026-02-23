// CalendarTile.qml
import QtQuick
import QtQuick.Controls

Item {
    id: root

    // === Настраиваемые свойства ===
    property int dayNumber: 1
    property color baseColor: "#3498db"
    property color textColor: "#ffffff"
    property bool isCircle: false
    property bool borderVisible: false
    property int widgetSize: 100

    // === Внутренние константы ===
    readonly property real fontSize: widgetSize * 0.5
    readonly property real borderRadius: isCircle ? widgetSize / 2 : 8
    readonly property color lighterColor: Qt.lighter(baseColor, 1.4)
    readonly property color borderColor: "#e94560"
    readonly property real borderWidth: 3

    width: widgetSize
    height: widgetSize

    // === Основной виджет ===
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: widgetSize * 0.9
        height: widgetSize * 0.9
        radius: borderRadius

        // Исправленный градиент
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.lighterColor }
            GradientStop { position: 1.0; color: root.baseColor }
        }

        border.color: root.borderVisible ? root.borderColor : "transparent"
        border.width: root.borderVisible ? root.borderWidth : 0

        // Блик для объема
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.4
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#60ffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
            clip: true
        }

        // Текст
        Text {
            id: dayText
            anchors.centerIn: parent
            text: root.dayNumber
            color: root.textColor
            font.bold: true
            font.pixelSize: fontSize
            style: Text.Raised
            styleColor: Qt.darker(root.textColor, 1.2)
        }
    }

    // === Анимация при наведении ===
    Behavior on scale {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.scale = 1.1
        onExited: root.scale = 1.0
    }
}
