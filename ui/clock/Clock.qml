import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts 1.15

Item {
    id: clock

    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight
    Layout.leftMargin: 10  // Добавляем отступ слева для тени
    Layout.rightMargin: 10 // Добавляем отступ справа для тени

    property int padding: 16
    property int shadowOffset: 5  // Размер тени

    // Учитываем тень в implicitHeight
    implicitHeight: container.implicitHeight + padding * 2 + shadowOffset

    Item {
        id: container
        anchors {
            fill: parent
            leftMargin: shadowOffset
            rightMargin: shadowOffset
        }

        implicitHeight: content.implicitHeight

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            radius: 12
            color: "#00A4FF"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00A4FF" }
                // GradientStop { position: 1.0; color: "#96D7FF" }
                GradientStop { position: 1.0; color: Qt.lighter("#00A4FF", 1.5) }

            }
            border.color: "#ffffff"
            border.width: 1
        }

        RectangularShadow {
            anchors.fill: backgroundRect
            anchors.margins: -6
            offset.x: -shadowOffset
            offset.y: shadowOffset
            radius: backgroundRect.radius
            blur: 20
            spread: 1
            color: Qt.darker(backgroundRect.color, 1.5)
            // Ограничиваем тень, чтобы не выходила за пределы
            visible: true
            z:-1
        }

        Column {
            id: content
            anchors.centerIn: parent
            spacing: 4

            Label {
                id: timeLabel
                text: "12:34"
                font.pixelSize: 36
                font.bold: true
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: secondsLabel
                text: "56"
                font.pixelSize: 16
                color: Qt.rgba(1, 1, 1, 0.8)
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: dateLabel
                text: "Понедельник, 15 марта"
                font.pixelSize: 14
                color: Qt.rgba(1, 1, 1, 0.9)
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: true
        onTriggered: updateClock()
    }

    function updateClock() {
        var now = new Date()
        var h = now.getHours().toString().padStart(2, '0')
        var m = now.getMinutes().toString().padStart(2, '0')
        var s = now.getSeconds().toString().padStart(2, '0')

        timeLabel.text = h + ":" + m
        secondsLabel.text = s

        // var locale = Qt.locale("ru_RU")
        var day = Qt.formatDateTime(now, "dddd")      // → "понедельник"
        var date = Qt.formatDateTime(now, "d MMMM")   // → "15 марта"

        dateLabel.text = capitalize(day) + ", " + date
    }

    function capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1)
    }


    Component.onCompleted: {
        // console.log("Clock: width=", width, "height=", height)
        updateClock()
    }
}
