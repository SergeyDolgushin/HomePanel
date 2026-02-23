// TimerWidget.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: timerWidget

    // === СВОЙСТВА ===
    property int timerId: 0
    property int totalSeconds: 60
    property bool isRunning: true

    // === СИГНАЛЫ ===
    signal timerFinished(var timerId)
    signal timerClosed(var timerId)

    // === ВНУТРЕННИЕ ПЕРЕМЕННЫЕ ===
    property int remainingSeconds: totalSeconds
    property int minutes: Math.floor(remainingSeconds / 60)
    property int seconds: remainingSeconds % 60

    width: 280
    height: 140
    radius: 12
    color: "#1a1a2e"
    border.color: remainingSeconds <= 10 ? "#e74c3c" : "#00A4FF"
    border.width: 2

    // Тень
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 4
        radius: 12
        samples: 16
        color: "#40000000"
    }

    // === ТАЙМЕР ===
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: timerWidget.isRunning && remainingSeconds > 0

        onTriggered: {
            if (remainingSeconds > 0) {
                remainingSeconds--
            }
            if (remainingSeconds === 0) {
                countdownTimer.stop()
                timerWidget.isRunning = false
                timerFinished(timerWidget.timerId)
                console.log("⏱ Timer finished:", timerWidget.timerId)
            }
        }
    }

    // === КОНТЕНТ ===
    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Время
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#0f3460"
            border.color: remainingSeconds <= 10 ? "#e74c3c" : "#00A4FF"
            border.width: 1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: formatTime(minutes, seconds)
                    font.pixelSize: 36
                    font.bold: true
                    color: remainingSeconds <= 10 ? "#e74c3c" : "#00A4FF"
                    font.family: "monospace"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: remainingSeconds <= 10 ? "⚠️ Заканчивается!" :
                          isRunning ? "⏵ Идёт отсчёт" : "⏸ Завершён"
                    font.pixelSize: 12
                    color: remainingSeconds <= 10 ? "#e74c3c" : "#a0a0a0"
                }
            }
        }

        // Кнопка закрытия
        Button {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50

            background: Rectangle {
                radius: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#e74c3c" }
                    GradientStop { position: 1.0; color: "#c0392b" }
                }
                border.color: "#ffffff"
                border.width: 2
            }

            contentItem: Text {
                text: "✕"
                font.pixelSize: 24
                font.bold: true
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                countdownTimer.stop()
                timerClosed(timerWidget.timerId)
            }
        }
    }

    // === АНИМАЦИЯ ПРИ ЗАВЕРШЕНИИ ===
    SequentialAnimation on color {
        id: finishAnimation
        running: false

        PropertyAnimation { to: "#e74c3c"; duration: 300 }
        PropertyAnimation { to: "#1a1a2e"; duration: 300 }
        PropertyAnimation { to: "#e74c3c"; duration: 300 }
        PropertyAnimation { to: "#1a1a2e"; duration: 300 }
    }

    onIsRunningChanged: {
        if (!isRunning && remainingSeconds === 0) {
            finishAnimation.start()
        }
    }

    // === ФУНКЦИИ ===
    function formatTime(mins, secs) {
        var m = mins < 10 ? "0" + mins : mins
        var s = secs < 10 ? "0" + secs : secs
        return m + ":" + s
    }

    function resetTimer(newMinutes, newSeconds) {
        remainingSeconds = newMinutes * 60 + newSeconds
        totalSeconds = remainingSeconds
        isRunning = true
        countdownTimer.start()
    }

    function stopTimer() {
        countdownTimer.stop()
        isRunning = false
    }

    Component.onCompleted: {
        console.log("⏱ Timer widget created:", timerId, "Duration:", totalSeconds, "sec")
    }

    Component.onDestruction: {
        countdownTimer.stop()
        console.log("⏱ Timer widget destroyed:", timerId)
    }
}
