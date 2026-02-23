// TimerMenuWidget.qml
import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Item {
    id: timerMenu

    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight
    Layout.leftMargin: 10
    Layout.rightMargin: 10

    property int padding: 16
    property int shadowOffset: 5

    // === СВОЙСТВА ТАЙМЕРОВ ===
    property int maxTimers: 10
    property int activeTimersCount: 0
    property var timersList: []

    // Сигналы
    signal createTimerRequested()
    signal removeTimerRequested(var timerId)

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
            visible: true
            z: -1
        }

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: 8
            width: parent.width - padding * 2

            // Заголовок
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: "⏱ Таймеры"
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
                style: Text.Outline
                styleColor: "#0066aa"
                horizontalAlignment: Text.AlignHCenter
            }

            // Кнопка создания таймера
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                enabled: timersList.length < maxTimers

                background: Rectangle {
                    radius: 8
                    color: parent.enabled ? "#ffffff" : "#80cccccc"
                    border.color: parent.enabled ? "#0066aa" : "#999999"
                    border.width: 2

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: parent.radius - 2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: parent.enabled ? "#e0f0ff" : "#cccccc" }
                            GradientStop { position: 1.0; color: parent.enabled ? "#00A4FF" : "#999999" }
                        }
                    }
                }

                contentItem: RowLayout {
                    spacing: 8
                    anchors.centerIn: parent

                    Text {
                        text: "➕"
                        font.pixelSize: 20
                        color: parent.parent.parent.enabled ? "#0066aa" : "#666666"
                    }

                    Text {
                        text: timersList.length >= maxTimers ? "Предел количества таймеров" : "Добавить таймер"
                        font.pixelSize: 14
                        font.bold: true
                        color: parent.parent.parent.enabled ? "#0066aa" : "#666666"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                }

                onClicked: {
                    if (timersList.length < maxTimers) {
                        createTimerRequested()
                    }
                }
            }

            // Статус активных таймеров
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: activeTimersCount > 0 ?
                      "⏵ Активных таймеров: " + activeTimersCount :
                      "⏸ Нет активных таймеров"
                font.pixelSize: 13
                color: activeTimersCount > 0 ? "#ffffff" : "#e0e0e0"
                style: Text.Outline
                styleColor: "#0066aa"
                horizontalAlignment: Text.AlignHCenter
            }

            // Счётчик созданных таймеров
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                text: "Создано: " + timersList.length + " / " + maxTimers
                font.pixelSize: 11
                color: "#e0e0e0"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // === ФУНКЦИИ УПРАВЛЕНИЯ ===
    function addTimer(timerId) {
        timersList.push(timerId)
        updateActiveCount()
        console.log("⏱ Timer added:", timerId, "Total:", timersList.length)
    }

    function removeTimer(timerId) {
        var index = timersList.indexOf(timerId)
        if (index !== -1) {
            timersList.splice(index, 1)
            updateActiveCount()
            console.log("⏱ Timer removed:", timerId, "Remaining:", timersList.length)
        }
    }

    function updateActiveCount() {
        activeTimersCount = timersList.length
    }

    function getTimerCount() {
        return timersList.length
    }
}
