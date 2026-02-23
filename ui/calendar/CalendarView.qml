// CalendarView.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: calendarView

    // === СВОЙСТВА ===
    property bool active: false
    property date currentDate: new Date()
    property date selectedDate: new Date()
    property int currentYear: currentDate.getFullYear()
    property int currentMonth: currentDate.getMonth()

    // === КОНСТАНТЫ ===
    readonly property var dayNames: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    readonly property var monthNames: [
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
    ]

    // === РАСЧЁТ РАЗМЕРА ПЛИТОК ===
    property real availableHeight: parent.height * 0.72
    property real availableWidth: parent.width * 0.96
    property real tileWidth: availableWidth / 7
    property real tileHeight: availableHeight / 6
    property real tileSize: Math.min(tileWidth, tileHeight)

    // === ВЫЧИСЛЯЕМ ДНИ ===
    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function getFirstDayOfMonth(year, month) {
        var day = new Date(year, month, 1).getDay()
        // Преобразуем: 0 (Воскресенье) -> 6, 1 (Понедельник) -> 0
        return day === 0 ? 6 : day - 1
    }

    function getDaysInPreviousMonth(year, month) {
        if (month === 0) {
            return getDaysInMonth(year - 1, 11)
        }
        return getDaysInMonth(year, month - 1)
    }

    // === ГЕНЕРАЦИЯ ДНЕЙ ===
    function generateCalendarDays() {
        var days = []
        var daysInCurrent = getDaysInMonth(currentYear, currentMonth)
        var daysInPrevious = getDaysInPreviousMonth(currentYear, currentMonth)
        var firstDay = getFirstDayOfMonth(currentYear, currentMonth)

        console.log("📅 Generate days for:", monthNames[currentMonth], currentYear)
        console.log("   Days in current:", daysInCurrent)
        console.log("   Days in previous:", daysInPrevious)
        console.log("   First day index:", firstDay)

        // Дни предыдущего месяца (заполняем первую неделю)
        for (var i = firstDay - 1; i >= 0; i--) {
            var prevDay = daysInPrevious - i
            days.push({
                day: prevDay,
                month: currentMonth - 1 < 0 ? 11 : currentMonth - 1,
                year: currentMonth === 0 ? currentYear - 1 : currentYear,
                isCurrentMonth: false,
                isPreviousMonth: true
            })
        }

        // Дни текущего месяца
        for (var d = 1; d <= daysInCurrent; d++) {
            days.push({
                day: d,
                month: currentMonth,
                year: currentYear,
                isCurrentMonth: true,
                isPreviousMonth: false
            })
        }

        // Дни следующего месяца (заполняем до 42 ячеек)
        var totalCells = 42
        var nextMonthDays = totalCells - days.length
        var nextMonth = currentMonth + 1 > 11 ? 0 : currentMonth + 1
        var nextYear = currentMonth === 11 ? currentYear + 1 : currentYear

        console.log("   Next month days to fill:", nextMonthDays)

        for (var n = 1; n <= nextMonthDays; n++) {
            days.push({
                day: n,
                month: nextMonth,
                year: nextYear,
                isCurrentMonth: false,
                isPreviousMonth: false
            })
        }

        console.log("   Total cells:", days.length)
        return days
    }

    // === НАВИГАЦИЯ ===
    function previousMonth() {
        if (currentMonth === 0) {
            currentMonth = 11
            currentYear--
        } else {
            currentMonth--
        }
        currentDate = new Date(currentYear, currentMonth, 1)
        console.log("📅 Previous month:", monthNames[currentMonth], currentYear)
    }

    function nextMonth() {
        if (currentMonth === 11) {
            currentMonth = 0
            currentYear++
        } else {
            currentMonth++
        }
        currentDate = new Date(currentYear, currentMonth, 1)
        console.log("📅 Next month:", monthNames[currentMonth], currentYear)
    }

    function goToToday() {
        var today = new Date()
        currentYear = today.getFullYear()
        currentMonth = today.getMonth()
        currentDate = today
        selectedDate = today
        console.log("📅 Go to today:", monthNames[currentMonth], currentYear)
    }

    function isToday(year, month, day) {
        var today = new Date()
        return year === today.getFullYear() &&
               month === today.getMonth() &&
               day === today.getDate()
    }

    function isSelected(year, month, day) {
        return year === selectedDate.getFullYear() &&
               month === selectedDate.getMonth() &&
               day === selectedDate.getDate()
    }

    // === ФУНКЦИЯ ОБНОВЛЕНИЯ РАЗМЕРА ПЛИТОК ===
    function updateTileSize() {
        var newAvailableHeight = parent.height * 0.72
        var newAvailableWidth = parent.width * 0.96

        var newTileWidth = newAvailableWidth / 7
        var newTileHeight = newAvailableHeight / 6

        tileSize = Math.min(newTileWidth, newTileHeight)
    }

    // === UI ===
    anchors.fill: parent
    visible: active
    z: 50

    // === ПОЛУПРОЗРАЧНЫЙ ФОН ===
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
        opacity: 0.85
    }

    // === ЗАГОЛОВОК ===
    Rectangle {
        id: headerRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: tileSize * 0.8

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#16213e" }
            GradientStop { position: 0.5; color: "#1a1a2e" }
            GradientStop { position: 1.0; color: "#16213e" }
        }
        opacity: 0.9

        Button {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10
            width: tileSize * 0.6
            height: tileSize * 0.6
            text: "◀"
            font.pixelSize: tileSize * 0.3

            background: Rectangle {
                color: parent.pressed ? "#0f3460" : "#16213e"
                radius: tileSize * 0.3
                border.color: "#e94560"
                border.width: 2
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: "#e94560"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: calendarView.previousMonth()
        }

        Text {
            anchors.centerIn: parent
            text: monthNames[currentMonth] + " " + currentYear
            font.pixelSize: tileSize * 0.45
            font.bold: true
            color: "#e94560"
            style: Text.Outline
            styleColor: "#1a1a2e"
        }

        Button {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10
            width: tileSize * 0.6
            height: tileSize * 0.6
            text: "▶"
            font.pixelSize: tileSize * 0.3

            background: Rectangle {
                color: parent.pressed ? "#0f3460" : "#16213e"
                radius: tileSize * 0.3
                border.color: "#e94560"
                border.width: 2
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: "#e94560"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: calendarView.nextMonth()
        }

        Button {
            anchors.top: headerRect.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 2
            width: tileSize * 1.2
            height: tileSize * 0.4
            text: "Сегодня"
            font.pixelSize: tileSize * 0.2

            background: Rectangle {
                color: parent.pressed ? "#e94560" : "#0f3460"
                radius: tileSize * 0.2
                border.color: "#e94560"
                border.width: 1
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: calendarView.goToToday()
        }
    }

    // === ДНИ НЕДЕЛИ ===
    Rectangle {
        id: dayNamesRect
        anchors.top: headerRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: tileSize * 0.6
        color: "#0f3460"
        opacity: 0.9

        Row {
            anchors.centerIn: parent  // Исправлено: центрируем вместо fill
            spacing: 0

            Repeater {
                model: dayNames
                delegate: Rectangle {
                    width: tileSize  // Ширина равна tileSize для выравнивания
                    height: dayNamesRect.height
                    color: index < 5 ? "#0f3460" : "#e94560"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: tileSize * 0.35
                        font.bold: true
                        color: index < 5 ? "#a0a0a0" : "#ffffff"
                    }
                }
            }
        }
    }

    // === СЕТКА КАЛЕНДАРЯ ===
    Rectangle {
        id: calendarGrid
        anchors.top: dayNamesRect.bottom
        anchors.bottom: footerRect.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "transparent"

        onWidthChanged: calendarView.updateTileSize()
        onHeightChanged: calendarView.updateTileSize()

        Grid {
            anchors.centerIn: parent
            columns: 7
            rows: 6
            spacing: 2

            Repeater {
                model: generateCalendarDays()
                delegate: CalendarTile {
                    widgetSize: tileSize * 0.9
                    dayNumber: modelData.day
                    baseColor: {
                        if (modelData.isCurrentMonth) {
                            if (isSelected(modelData.year, modelData.month, modelData.day)) {
                                return "#e94560"
                            }
                            if (isToday(modelData.year, modelData.month, modelData.day)) {
                                return "#0f3460"
                            }
                            return "#3498db"
                        } else {
                            return "#2a2a3e"
                        }
                    }
                    textColor: modelData.isCurrentMonth ? "#ffffff" : "#606060"
                    borderVisible: isSelected(modelData.year, modelData.month, modelData.day)
                    isCircle: false

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selectedDate = new Date(modelData.year, modelData.month, modelData.day)
                            console.log("📅 Selected:", modelData.day, monthNames[modelData.month], modelData.year)
                        }
                    }
                }
            }
        }
    }

    // === ПОДВАЛ ===
    Rectangle {
        id: footerRect
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: tileSize * 0.8
        opacity: 0.9

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#16213e" }
            GradientStop { position: 0.5; color: "#1a1a2e" }
            GradientStop { position: 1.0; color: "#16213e" }
        }

        Text {
            anchors.centerIn: parent
            text: "Выбрано: " + selectedDate.getDate() + " " +
                  monthNames[selectedDate.getMonth()] + " " +
                  selectedDate.getFullYear()
            font.pixelSize: tileSize * 0.3
            color: "#a0a0a0"
        }

        Button {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10
            width: tileSize * 0.6
            height: tileSize * 0.6
            text: "✕"
            font.pixelSize: tileSize * 0.3

            background: Rectangle {
                color: parent.pressed ? "#c0392b" : "#e74c3c"
                radius: tileSize * 0.3
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: calendarView.active = false
        }
    }

    // === УПРАВЛЕНИЕ С КЛАВИАТУРЫ ===
    Keys.onPressed: {
        if (!active) return

        switch (event.key) {
            case Qt.Key_Left:
                event.accepted = true
                previousMonth()
                break
            case Qt.Key_Right:
                event.accepted = true
                nextMonth()
                break
            case Qt.Key_T:
            case Qt.Key_Space:
                event.accepted = true
                goToToday()
                break
            case Qt.Key_Escape:
                event.accepted = true
                active = false
                break
        }
    }

    focus: active

    onActiveChanged: {
        if (active) {
            forceActiveFocus()
            updateTileSize()
        }
    }

    Component.onCompleted: {
        updateTileSize()
    }
}
