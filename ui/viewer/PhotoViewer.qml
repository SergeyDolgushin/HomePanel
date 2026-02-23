// PhotoViewer.qml
import QtQuick 6.10
import QtQuick.Controls 6.10
import Qt.labs.folderlistmodel 6.10
import QtQuick.Window 6.10
import SystemInfo 1.0

Item {
    id: photoViewer

    // === СВОЙСТВА ===
    property bool active: false
    property int currentIndex: 0
    property var effects: ["Fade", "SlideLeft", "SlideRight", "Zoom", "Rotate"]
    property string currentEffect: "Fade"
    property bool animationRunning: false

    readonly property string picturesPath: pathProvider.pictures

    // Слайд-шоу
    property bool slideShowActive: false
    property int slideShowInterval: 5000

    // === ТАЙМЕР СЛАЙД-ШОУ ===
    Timer {
        id: slideShowTimer
        interval: photoViewer.slideShowInterval
        repeat: true
        running: photoViewer.active && photoViewer.slideShowActive && filteredImages.count > 1
        onTriggered: {
            if (!photoViewer.animationRunning) {
                imageContainer.showNext()
            }
        }
    }

    Component.onCompleted: {
        console.log("=== PhotoViewer Debug Info ===")
        console.log("picturesPath:", picturesPath)
        console.log("==============================")
    }

    function getNextEffect() {
        var effect = effects[Math.floor(Math.random() * effects.length)]
        currentEffect = effect
        console.log("🎭 Selected effect:", effect)
        return effect
    }

    function createFileUrl(fileName) {
        if (!fileName) return ""
        var cleanPath = picturesPath
        if (cleanPath.startsWith("file://")) {
            cleanPath = cleanPath.substring(7)
        }
        var fullPath = cleanPath + "/" + fileName
        return "file://" + fullPath
    }

    // === МОДЕЛЬ ФАЙЛОВ ===
    FolderListModel {
        id: imageModel
        folder: active ? "file://" + picturesPath : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif",
                      "*.JPG", "*.JPEG", "*.PNG", "*.WEBP", "*.GIF"]
        showDirs: false
        showFiles: true
        showDotAndDotDot: false

        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                console.log("📁 Model ready. Count:", count)
                updateImageList()
            }
        }
    }

    ListModel {
        id: filteredImages
    }

    function updateImageList() {
        filteredImages.clear()

        if (imageModel.count === 0) {
            console.log("⚠️ No files found in model")
            return
        }

        for (let i = 0; i < imageModel.count; ++i) {
            var fileName = imageModel.get(i, "fileName")
            if (fileName && fileName.match(/\.(jpg|jpeg|png|webp|gif)$/i)) {
                var fileUrl = createFileUrl(fileName)
                filteredImages.append({
                    url: fileUrl,
                    name: fileName
                })
                console.log("➕ Added image", i + ":", fileName)
            }
        }

        console.log("📸 PhotoViewer: found", filteredImages.count, "images")

        if (filteredImages.count > 0) {
            currentIndex = 0
        }
    }

    // === КОНТЕЙНЕР ИЗОБРАЖЕНИЙ ===
    Item {
        id: imageContainer
        anchors.fill: parent
        visible: photoViewer.active && filteredImages.count > 0

        property bool waitingForLoad: false
        property int pendingIndex: -1

        // Фон
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.95
        }

        // ⚠️ ВАЖНО: Обёртки для изображений вместо anchors.centerIn
        // Это позволяет анимировать позицию через x

        // Контейнер текущего изображения
        Item {
            id: currentImageContainer
            width: parent.width
            height: parent.height
            x: 0
            y: 0

            Image {
                id: currentImage
                source: filteredImages.count > 0 ? filteredImages.get(currentIndex).url : ""
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent  // Внутри контейнера можно использовать anchors
                antialiasing: true
                smooth: true
                asynchronous: true
                cache: true

                onStatusChanged: {
                    if (status === Image.Ready) {
                        console.log("✅ Current image loaded:", sourceSize.width, "x", sourceSize.height)
                    } else if (status === Image.Error) {
                        console.log("❌ Current image load error:", source)
                    }
                }
            }
        }

        // Контейнер следующего изображения
        Item {
            id: nextImageContainer
            width: parent.width
            height: parent.height
            x: 0
            y: 0
            visible: false

            Image {
                id: nextImage
                source: ""
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                antialiasing: true
                smooth: true
                asynchronous: true
                cache: true

                onStatusChanged: {
                    if (status === Image.Ready) {
                        console.log("✅ Next image ready:", source)
                        if (imageContainer.waitingForLoad) {
                            imageContainer.waitingForLoad = false
                            imageContainer.startAnimation(imageContainer.pendingIndex)
                        }
                    } else if (status === Image.Error) {
                        console.log("❌ Next image load error:", source)
                        photoViewer.animationRunning = false
                        imageContainer.waitingForLoad = false
                    }
                }
            }
        }

        // === СМЕНА ФОТО ===
        function showNext() {
            if (filteredImages.count <= 1) return
            if (photoViewer.animationRunning) return

            var nextIndex = (currentIndex + 1) % filteredImages.count
            console.log("➡️ Switching to next image:", nextIndex)
            changeTo(nextIndex)
        }

        function showPrev() {
            if (filteredImages.count <= 1) return
            if (photoViewer.animationRunning) return

            var prevIndex = (currentIndex - 1 + filteredImages.count) % filteredImages.count
            console.log("⬅️ Switching to previous image:", prevIndex)
            changeTo(prevIndex)
        }

        function changeTo(index) {
            console.log("🔄 changeTo:", index)
            photoViewer.animationRunning = true
            waitingForLoad = false
            pendingIndex = index

            // Сброс позиций контейнеров
            currentImageContainer.x = 0
            currentImageContainer.scale = 1
            currentImageContainer.rotation = 0
            currentImageContainer.opacity = 1

            nextImageContainer.x = 0
            nextImageContainer.scale = 1
            nextImageContainer.rotation = 0
            nextImageContainer.opacity = 0
            nextImageContainer.visible = true

            // Загружаем следующее изображение
            nextImage.source = filteredImages.get(index).url

            if (nextImage.status === Image.Ready) {
                startAnimation(index)
            } else {
                console.log("⏳ Waiting for image to load...")
                waitingForLoad = true
            }
        }

        function cleanupAnimations() {
            if (currentAnimation) {
                currentAnimation.stop()
                currentAnimation.destroy()
                currentAnimation = null
            }
            if (nextAnimation) {
                nextAnimation.stop()
                nextAnimation.destroy()
                nextAnimation = null
            }
        }

        function finalizeAnimation(newIndex) {
            console.log("✅ Animation completed for index:", newIndex)

            // Меняем источник
            currentImage.source = nextImage.source
            currentIndex = newIndex

            // Сброс контейнеров
            currentImageContainer.x = 0
            currentImageContainer.scale = 1
            currentImageContainer.rotation = 0
            currentImageContainer.opacity = 1

            nextImage.source = ""
            nextImageContainer.opacity = 0
            nextImageContainer.x = 0
            nextImageContainer.scale = 1
            nextImageContainer.rotation = 0
            nextImageContainer.visible = false

            cleanupAnimations()

            photoViewer.animationRunning = false
            waitingForLoad = false
            pendingIndex = -1

            console.log("🖼️ Current image now:", currentImage.source, "Index:", currentIndex)
        }

        property var currentAnimation: null
        property var nextAnimation: null

        function startAnimation(newIndex) {
            console.log("🎬 Starting animation for index:", newIndex)

            cleanupAnimations()

            var effect = photoViewer.getNextEffect()
            var parentWidth = imageContainer.width

            console.log("📏 Parent width:", parentWidth)

            switch (effect) {
                case "SlideLeft":
                    createSlideLeft(parentWidth)
                    break
                case "SlideRight":
                    createSlideRight(parentWidth)
                    break
                case "Zoom":
                    createZoom()
                    break
                case "Rotate":
                    createRotate()
                    break
                default:
                    createFade()
                    break
            }

            if (currentAnimation && nextAnimation) {
                console.log("▶️ Starting animations...")
                console.log("   currentAnimation duration:", currentAnimation.duration)
                console.log("   nextAnimation duration:", nextAnimation.duration)

                currentAnimation.start()
                nextAnimation.start()

                // Проверка завершения
                var checkTimer = Qt.createQmlObject(
                    'import QtQuick 6.10; Timer { interval: 100; repeat: true }',
                    imageContainer, "completionCheckTimer"
                )

                checkTimer.triggered.connect(function() {
                    if (!currentAnimation.running && !nextAnimation.running) {
                        console.log("✅ Both animations completed")
                        checkTimer.stop()
                        checkTimer.destroy()
                        finalizeAnimation(newIndex)
                    }
                })

                checkTimer.start()
            } else {
                console.log("❌ Failed to create animations")
                photoViewer.animationRunning = false
                waitingForLoad = false
            }
        }

        function createFade() {
            console.log("Creating Fade animation")

            currentAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                NumberAnimation {
                    target: currentImageContainer
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            `, imageContainer, "currentFade")

            nextAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                NumberAnimation {
                    target: nextImageContainer
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            `, imageContainer, "nextFade")
        }

        function createSlideLeft(parentWidth) {
            console.log("Creating SlideLeft animation")
            console.log("   Width:", parentWidth)

            // Текущее уходит влево
            currentAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                NumberAnimation {
                    target: currentImageContainer
                    property: "x"
                    from: 0
                    to: -${parentWidth}
                    duration: 1500
                    easing.type: Easing.InOutQuad
                }
            `, imageContainer, "currentSlideLeft")

            // Новое приходит справа - ВАЖНО: установить позицию ДО создания анимации
            nextImageContainer.x = parentWidth

            nextAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                NumberAnimation {
                    target: nextImageContainer
                    property: "x"
                    from: ${parentWidth}
                    to: 0
                    duration: 1500
                    easing.type: Easing.InOutQuad
                }
            `, imageContainer, "nextSlideLeft")

            console.log("   currentImageContainer: 0 →", -parentWidth)
            console.log("   nextImageContainer:", parentWidth, "→ 0")
        }

        function createSlideRight(parentWidth) {
            console.log("Creating SlideRight animation")
            console.log("   Width:", parentWidth)

            // Текущее уходит вправо
            currentAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                NumberAnimation {
                    target: currentImageContainer
                    property: "x"
                    from: 0
                    to: ${parentWidth}
                    duration: 1500
                    easing.type: Easing.InOutQuad
                }
            `, imageContainer, "currentSlideRight")

            // Новое приходит слева
            nextImageContainer.x = -parentWidth

            nextAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                NumberAnimation {
                    target: nextImageContainer
                    property: "x"
                    from: -${parentWidth}
                    to: 0
                    duration: 1500
                    easing.type: Easing.InOutQuad
                }
            `, imageContainer, "nextSlideRight")

            console.log("   currentImageContainer: 0 →", parentWidth)
            console.log("   nextImageContainer:", -parentWidth, "→ 0")
        }

        function createZoom() {
            console.log("Creating Zoom animation")

            currentAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                ParallelAnimation {
                    NumberAnimation {
                        target: currentImageContainer
                        property: "scale"
                        from: 1
                        to: 0.3
                        duration: 1000
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: currentImageContainer
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 1000
                    }
                }
            `, imageContainer, "currentZoom")

            nextImageContainer.scale = 0.3

            nextAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                ParallelAnimation {
                    NumberAnimation {
                        target: nextImageContainer
                        property: "scale"
                        from: 0.3
                        to: 1
                        duration: 1000
                        easing.type: Easing.OutBack
                    }
                    NumberAnimation {
                        target: nextImageContainer
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 1000
                    }
                }
            `, imageContainer, "nextZoom")
        }

        function createRotate() {
            console.log("Creating Rotate animation")

            currentAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                ParallelAnimation {
                    NumberAnimation {
                        target: currentImageContainer
                        property: "rotation"
                        from: 0
                        to: 90
                        duration: 1200
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: currentImageContainer
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 1200
                    }
                }
            `, imageContainer, "currentRotate")

            nextImageContainer.rotation = -90

            nextAnimation = Qt.createQmlObject(`
                import QtQuick 6.10
                ParallelAnimation {
                    NumberAnimation {
                        target: nextImageContainer
                        property: "rotation"
                        from: -90
                        to: 0
                        duration: 1200
                        easing.type: Easing.OutElastic
                    }
                    NumberAnimation {
                        target: nextImageContainer
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 1200
                    }
                }
            `, imageContainer, "nextRotate")
        }
    }

    // === КНОПКИ УПРАВЛЕНИЯ ===
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 30
        spacing: 30
        visible: active && filteredImages.count > 0
        z: 101

        Button {
            text: "◀"
            font.pixelSize: 32
            width: 80
            height: 80
            onClicked: imageContainer.showPrev()
            enabled: !photoViewer.animationRunning && filteredImages.count > 1

            background: Rectangle {
                color: parent.enabled ? "#80FFFFFF" : "#40808080"
                radius: 40
                border.color: "white"
                border.width: 2
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Button {
            text: "▶"
            font.pixelSize: 32
            width: 80
            height: 80
            onClicked: imageContainer.showNext()
            enabled: !photoViewer.animationRunning && filteredImages.count > 1

            background: Rectangle {
                color: parent.enabled ? "#80FFFFFF" : "#40808080"
                radius: 40
                border.color: "white"
                border.width: 2
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Button {
            text: slideShowActive ? "⏸" : "▶▶"
            font.pixelSize: 32
            width: 80
            height: 80
            onClicked: slideShowActive = !slideShowActive
            enabled: !photoViewer.animationRunning && filteredImages.count > 1

            background: Rectangle {
                color: slideShowActive ? "#80FFFF00" : "#80FFFFFF"
                radius: 40
                border.color: "white"
                border.width: 2
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: slideShowActive ? "black" : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Button {
            text: "✕"
            font.pixelSize: 32
            width: 80
            height: 80
            onClicked: {
                slideShowActive = false
                active = false
            }

            background: Rectangle {
                color: "#80FF0000"
                radius: 40
                border.color: "white"
                border.width: 2
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: parent.font.pixelSize
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // === ИНДИКАТОРЫ ===
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        height: 40
        width: 120
        radius: 20
        color: "#80000000"
        visible: active && filteredImages.count > 0
        z: 101

        Text {
            anchors.centerIn: parent
            color: "white"
            text: (currentIndex + 1) + " / " + filteredImages.count
            font.pixelSize: 18
            font.bold: true
        }
    }

    Text {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        color: "yellow"
        text: currentEffect
        font.pixelSize: 16
        style: Text.Outline
        styleColor: "black"
        visible: active && filteredImages.count > 0
        z: 101
    }

    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20
        color: slideShowActive ? "lime" : "gray"
        text: slideShowActive ? "⏵ Слайд-шоу: " + (slideShowInterval / 1000) + "с" : "⏸ Слайд-шоу выкл"
        font.pixelSize: 16
        style: Text.Outline
        styleColor: "black"
        visible: active && filteredImages.count > 0
        z: 101

        MouseArea {
            anchors.fill: parent
            onClicked: slideShowActive = !slideShowActive
        }
    }

    // === ОБРАБОТКА СОБЫТИЙ ===
    MouseArea {
        anchors.fill: parent
        enabled: active
        onClicked: function(mouse) {
            if (mouse.y < parent.height - 100) {
                slideShowActive = false
                active = false
            }
        }
    }

    Keys.onPressed: {
        if (!active) return

        switch (event.key) {
            case Qt.Key_Right:
                event.accepted = true
                imageContainer.showNext()
                break
            case Qt.Key_Left:
                event.accepted = true
                imageContainer.showPrev()
                break
            case Qt.Key_Escape:
                event.accepted = true
                slideShowActive = false
                active = false
                break
            case Qt.Key_Space:
                event.accepted = true
                getNextEffect()
                break
            case Qt.Key_S:
                event.accepted = true
                slideShowActive = !slideShowActive
                break
            case Qt.Key_Plus:
            case Qt.Key_Equal:
                event.accepted = true
                slideShowInterval = Math.max(2000, slideShowInterval - 1000)
                break
            case Qt.Key_Minus:
                event.accepted = true
                slideShowInterval = Math.min(10000, slideShowInterval + 1000)
                break
        }
    }

    focus: active

    onActiveChanged: {
        if (active) {
            forceActiveFocus()
            imageModel.folder = "file://" + picturesPath
            console.log("🔓 Activated")
        } else {
            slideShowActive = false
            console.log("🔒 Deactivated")
        }
    }
}
