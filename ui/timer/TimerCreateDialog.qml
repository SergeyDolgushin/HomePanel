// TimerCreateDialog.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: createDialog

    anchors.fill: parent
    color: "#00000000"
    visible: false
    z: 200

    // === СВОЙСТВА ===
    property int selectedMinutes: 1
    property int selectedSeconds: 0

    // === СИГНАЛЫ ===
    signal timerStarted(int minutes, int seconds)
    signal dialogClosed()

    // === ЗАТЕМНЕНИЕ ФОНА ===
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6

        MouseArea {
            anchors.fill: parent
            onClicked: closeDialog()
        }
    }

    // === МОДАЛЬНОЕ ОКНО ===
    Rectangle {
        id: dialogWindow
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 400)
        height: 320
        radius: 16
        color: "#1a1a2e"
        border.color: "#00A4FF"
        border.width: 2

        // Тень
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 8
            radius: 20
            samples: 20
            color: "#80000000"
        }

        // Заголовок
        Rectangle {
            id: dialogHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 60
            radius: 16
            clip: true

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00A4FF" }
                GradientStop { position: 1.0; color: "#0066aa" }
            }

            Text {
                anchors.centerIn: parent
                text: "⏱ Создание таймера"
                font.pixelSize: 22
                font.bold: true
                color: "#ffffff"
                style: Text.Outline
                styleColor: "#004488"
            }
        }

        // Контент
        ColumnLayout {
            anchors.top: dialogHeader.bottom
            anchors.bottom: dialogFooter.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            spacing: 15

            // Выбор минут
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Минуты"
                    font.pixelSize: 16
                    color: "#ffffff"
                }

                SpinBox {
                    id: minutesBox
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 120
                    from: 0
                    to: 99
                    value: 1
                    stepSize: 1

                    background: Rectangle {
                        color: "#0f3460"
                        radius: 8
                        border.color: "#00A4FF"
                        border.width: 2
                    }

                    contentItem: TextInput {
                        text: minutesBox.textFromValue(minutesBox.value, minutesBox.locale)
                        font.pixelSize: 20
                        color: "#ffffff"
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        readOnly: !minutesBox.editable
                        validator: minutesBox.validator
                    }
                }
            }

            // Выбор секунд
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Секунды"
                    font.pixelSize: 16
                    color: "#ffffff"
                }

                SpinBox {
                    id: secondsBox
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 120
                    from: 0
                    to: 59
                    value: 0
                    stepSize: 5

                    background: Rectangle {
                        color: "#0f3460"
                        radius: 8
                        border.color: "#00A4FF"
                        border.width: 2
                    }

                    contentItem: TextInput {
                        text: secondsBox.textFromValue(secondsBox.value, secondsBox.locale)
                        font.pixelSize: 20
                        color: "#ffffff"
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        readOnly: !secondsBox.editable
                        validator: secondsBox.validator
                    }
                }
            }

            // Предпросмотр времени
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 8
                color: "#0f3460"
                border.color: "#00A4FF"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: formatTime(minutesBox.value, secondsBox.value)
                    font.pixelSize: 28
                    font.bold: true
                    color: "#00A4FF"
                    font.family: "monospace"
                }
            }
        }

        // Подвал с кнопками
        Rectangle {
            id: dialogFooter
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 70
            radius: 16
            clip: true

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#16213e" }
                GradientStop { position: 1.0; color: "#1a1a2e" }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                // Кнопка Отмена
                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 45

                    background: Rectangle {
                        radius: 8
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#e74c3c" }
                            GradientStop { position: 1.0; color: "#c0392b" }
                        }
                        border.color: "#ffffff"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: "✕ Отмена"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: closeDialog()
                }

                // Кнопка Старт
                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 45

                    background: Rectangle {
                        radius: 8
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#2ecc71" }
                            GradientStop { position: 1.0; color: "#27ae60" }
                        }
                        border.color: "#ffffff"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: "▶ Старт"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: startTimer()
                }
            }
        }
    }

    // === ФУНКЦИИ ===
    function formatTime(minutes, seconds) {
        var m = minutes < 10 ? "0" + minutes : minutes
        var s = seconds < 10 ? "0" + seconds : seconds
        return m + ":" + s
    }

    function openDialog() {
        minutesBox.value = 1
        secondsBox.value = 0
        visible = true
        console.log("⏱ Dialog opened")
    }

    function closeDialog() {
        visible = false
        dialogClosed()
        console.log("⏱ Dialog closed")
    }

    function startTimer() {
        var minutes = minutesBox.value
        var seconds = secondsBox.value

        if (minutes === 0 && seconds === 0) {
            console.log("⚠️ Cannot create timer with 0 time")
            return
        }

        console.log("⏱ Starting timer:", minutes, "min", seconds, "sec")
        timerStarted(minutes, seconds)
        closeDialog()
    }

    // Закрытие по Escape
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape && visible) {
            event.accepted = true
            closeDialog()
        }
    }
}
