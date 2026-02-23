import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // === Настраиваемые свойства ===
    property int dayNumber: 1               // Число от 1 до 31
    property color baseColor: "#3498db"     // Базовый цвет фона
    property color textColor: "#ffffff"     // Цвет текста
    property bool isCircle: false           // Форма: false = квадрат, true = круг
    property bool borderVisible: false      // Видимость окантовки
    property int widgetSize: 100            // Размер виджета (ширина и высота)

    // === Внутренние константы ===
    readonly property real fontSize: widgetSize * 0.66        // 2/3 от высоты
    readonly property real borderRadius: isCircle ? widgetSize / 2 : 8
    readonly property color lighterColor: Qt.lighter(baseColor, 1.4)  // Коэффициент осветления
    readonly property color borderColor: "#8b0000"            // Темно-красный
    readonly property real borderWidth: 10

    width: widgetSize + (borderVisible ? borderWidth * 2 : 0)
    height: widgetSize + (borderVisible ? borderWidth * 2 : 0)

    // === Окантовка (внешний слой) ===
    Rectangle {
        visible: borderVisible
        anchors.fill: parent
        radius: isCircle ? width / 2 : borderRadius + borderWidth
        color: "transparent"
        border.color: borderColor
        border.width: borderWidth

        // Сглаживание краев для круга
        layer.enabled: isCircle
        layer.smooth: true
    }

    // === Основной виджет (фон + текст) ===
    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: widgetSize
        height: widgetSize
        radius: borderRadius

        // Градиентный фон
        gradient: Gradient {
            orientation: Gradient.Diagonal
            GradientStop { position: 0.0; color: root.lighterColor }
            GradientStop { position: 1.0; color: root.baseColor }
        }

        // Объемный эффект (тень + блик)
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 16
            color: "#40000000"
        }

        // Блик для объема
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.4
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#60ffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
            clip: true
            visible: !isCircle || radius > 0
        }

        // Текст
        Text {
            id: dayText
            anchors.centerIn: parent
            text: root.dayNumber
            color: root.textColor
            font.bold: true
            font.pixelSize: fontSize
            font.family: "Arial"
            style: Text.Raised
            styleColor: Qt.darker(root.textColor, 1.2)

            // Адаптация размера, если текст не влезает
            Behavior on font.pixelSize {
                NumberAnimation { duration: 150 }
            }

            // Проверка переполнения (для двузначных чисел)
            Component.onCompleted: {
                if (dayNumber >= 10 && fontSize > widgetSize * 0.55) {
                    font.pixelSize = widgetSize * 0.55
                }
            }
        }
    }

    // === Анимация при наведении (опционально) ===
    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.scale = 1.05
        onExited: root.scale = 1.0
    }
}
