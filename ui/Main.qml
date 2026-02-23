import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Effects
import QtQuick.Layouts

import "drawer"
import "clock"
import "viewer"
import "calendar"
import "timer"

Window {

    id: root
    property color baseColor: "#3498db"
    readonly property color lighterColor: Qt.lighter(baseColor, 2)  // Коэффициент осветления

    width: 640
    height: 480
    visible: true
    title: qsTr("Home Panel")

    visibility: Window.FullScreen

    // === УПРАВЛЕНИЕ ТАЙМЕРАМИ ===
    property int nextTimerId: 1
    property var activeTimers: []

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
            Layout.topMargin: 5
            Layout.alignment: Qt.AlignHCenter
        }

        TimerMenuWidget {
            id: timerMenuWdg
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            Layout.topMargin: 16
            Layout.alignment: Qt.AlignHCenter

            onCreateTimerRequested: {
                timerCreateDialog.openDialog()
            }

            onRemoveTimerRequested: {
                removeTimer(timerId)
            }
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

            // Тестовая Кнопка открытия
            Button {
                text: "🖼 Просмотр фото"
                anchors.centerIn: parent
                onClicked: photoViewer.active = true

            }
        }

    }

    // === ДИАЛОГ СОЗДАНИЯ ТАЙМЕРА ===
    TimerCreateDialog {
        id: timerCreateDialog
        anchors.fill: parent

        onTimerStarted: function(minutes, seconds) {
            createTimer(minutes, seconds)
        }

        onDialogClosed: {
            console.log("⏱ Dialog closed")
        }
    }

    // === КОНТЕЙНЕР ДЛЯ ТАЙМЕРОВ ===
    Column {
        id: timersContainer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: rightBar.left
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 15
        z: 150
    }

    // Calendar View (поверх всего)
    CalendarView {
        id: calendarView
        anchors.fill: parent
        z: 100
        active: true  // Для теста - календарь открыт при запуске
    }

    // Photo Viewer (поверх всего)
    PhotoViewer {
        id: photoViewer
        anchors.fill: parent
        z: 150
    }

    // === ФУНКЦИИ УПРАВЛЕНИЯ ТАЙМЕРАМИ ===
    function createTimer(minutes, seconds) {
        if (activeTimers.length >= timerMenuWdg.maxTimers) {
            console.log("⚠️ Maximum timers reached")
            return
        }

        var timerId = nextTimerId++
        var totalSeconds = minutes * 60 + seconds

        // Создаём виджет таймера
        var timerComponent = Qt.createComponent("timer/TimerWidget.qml")

        if (timerComponent.status === Component.Ready) {
            var timerWidget = timerComponent.createObject(timersContainer, {
                "timerId": timerId,
                "totalSeconds": totalSeconds,
                "isRunning": true
            })

            if (timerWidget) {
                // Подключаем сигналы
                timerWidget.timerFinished.connect(handleTimerFinished)
                timerWidget.timerClosed.connect(handleTimerClosed)

                // Добавляем в список
                activeTimers.push({
                    id: timerId,
                    widget: timerWidget
                })

                // Обновляем меню
                timerMenuWdg.addTimer(timerId)

                console.log("✅ Timer created:", timerId, "Duration:", totalSeconds, "sec")
            } else {
                console.log("❌ Failed to create timer widget")
            }
        } else {
            console.log("❌ Component error:", timerComponent.errorString())
        }
    }

    function removeTimer(timerId) {
        for (var i = 0; i < activeTimers.length; i++) {
            if (activeTimers[i].id === timerId) {
                var timerWidget = activeTimers[i].widget
                if (timerWidget) {
                    timerWidget.destroy()
                }
                activeTimers.splice(i, 1)
                timerMenuWdg.removeTimer(timerId)
                console.log("🗑 Timer removed:", timerId)
                break
            }
        }
    }

    function handleTimerFinished(timerId) {
        console.log("⏱ Timer finished:", timerId)
        // Можно добавить звук или уведомление
    }

    function handleTimerClosed(timerId) {
        console.log("⏱ Timer closed:", timerId)
        removeTimer(timerId)
    }

    function getActiveTimersCount() {
        return activeTimers.length
    }

    Component.onCompleted: {
        console.log(root.width, root.height);
    }


}
