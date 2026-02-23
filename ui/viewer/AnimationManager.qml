// AnimationManager.qml
import QtQuick 6.10

Item {
    id: animationManager

    // === СВОЙСТВА ===
    property var effects: ["Fade", "SlideLeft", "SlideRight", "Zoom", "Rotate"]
    property string currentEffect: "Fade"
    property bool animationRunning: false
    property int animationDuration: 2000

    // === СИГНАЛЫ ===
    signal animationStarted()
    signal animationCompleted()

    // Хранение текущих анимаций для очистки
    property var currentAnimations: []

    // === ФУНКЦИИ ===
    function getNextEffect() {
        var effect = effects[Math.floor(Math.random() * effects.length)]
        currentEffect = effect
        console.log("🎭 Selected effect:", effect)
        return effect
    }

    function playAnimation(currentImage, nextImage, parentWidth, parentHeight) {
        if (animationRunning) {
            console.log("⚠️ Animation already running")
            return false
        }

        // Очищаем предыдущие анимации
        cleanupAnimations()

        animationRunning = true
        animationStarted()

        var effect = getNextEffect()

        // Сбрасываем трансформации перед анимацией
        currentImage.x = 0
        currentImage.scale = 1
        currentImage.rotation = 0
        currentImage.opacity = 1

        nextImage.x = 0
        nextImage.scale = 1
        nextImage.rotation = 0
        nextImage.opacity = 0
        nextImage.visible = true

        var parallelAnim = null

        switch (effect) {
            case "SlideLeft":
                parallelAnim = createSlideLeft(currentImage, nextImage, parentWidth)
                break
            case "SlideRight":
                parallelAnim = createSlideRight(currentImage, nextImage, parentWidth)
                break
            case "Zoom":
                parallelAnim = createZoom(currentImage, nextImage)
                break
            case "Rotate":
                parallelAnim = createRotate(currentImage, nextImage)
                break
            default:
                parallelAnim = createFade(currentImage, nextImage)
                break
        }

        if (parallelAnim) {
            // Подключаемся к сигналу завершения
            parallelAnim.finished.connect(function() {
                console.log("✅ Animation completed")
                animationRunning = false
                animationCompleted()
                cleanupAnimations()
            })

            // Запускаем анимацию
            parallelAnim.start()
            return true
        } else {
            console.log("❌ Failed to create animations")
            animationRunning = false
            return false
        }
    }

    function cleanupAnimations() {
        for (var i = 0; i < currentAnimations.length; i++) {
            if (currentAnimations[i]) {
                currentAnimations[i].stop()
                currentAnimations[i].destroy()
            }
        }
        currentAnimations = []
    }

    function createFade(currentImage, nextImage) {
        var anim = Qt.createQmlObject(`
            import QtQuick 6.10
            ParallelAnimation {
                NumberAnimation {
                    target: currentImage
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: ${animationDuration}
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: nextImage
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: ${animationDuration}
                    easing.type: Easing.InOutQuad
                }
            }
        `, animationManager, "fadeAnimation")

        currentAnimations.push(anim)
        return anim
    }

    function createSlideLeft(currentImage, nextImage, parentWidth) {
        var anim = Qt.createQmlObject(`
            import QtQuick 6.10
            ParallelAnimation {
                NumberAnimation {
                    target: currentImage
                    property: "x"
                    from: 0
                    to: -${parentWidth}
                    duration: ${animationDuration}
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: nextImage
                    property: "x"
                    from: ${parentWidth}
                    to: 0
                    duration: ${animationDuration}
                    easing.type: Easing.InOutQuad
                }
            }
        `, animationManager, "slideLeftAnimation")

        currentAnimations.push(anim)
        return anim
    }

    function createSlideRight(currentImage, nextImage, parentWidth) {
        var anim = Qt.createQmlObject(`
            import QtQuick 6.10
            ParallelAnimation {
                NumberAnimation {
                    target: currentImage
                    property: "x"
                    from: 0
                    to: ${parentWidth}
                    duration: ${animationDuration}
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: nextImage
                    property: "x"
                    from: -${parentWidth}
                    to: 0
                    duration: ${animationDuration}
                    easing.type: Easing.InOutQuad
                }
            }
        `, animationManager, "slideRightAnimation")

        currentAnimations.push(anim)
        return anim
    }

    function createZoom(currentImage, nextImage) {
        var anim = Qt.createQmlObject(`
            import QtQuick 6.10
            ParallelAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        target: currentImage
                        property: "scale"
                        from: 1
                        to: 0.3
                        duration: ${animationDuration}
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: currentImage
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: ${animationDuration}
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: nextImage
                        property: "scale"
                        from: 0.3
                        to: 1
                        duration: ${animationDuration}
                        easing.type: Easing.OutBack
                    }
                    NumberAnimation {
                        target: nextImage
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: ${animationDuration}
                    }
                }
            }
        `, animationManager, "zoomAnimation")

        currentAnimations.push(anim)
        return anim
    }

    function createRotate(currentImage, nextImage) {
        var anim = Qt.createQmlObject(`
            import QtQuick 6.10
            ParallelAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        target: currentImage
                        property: "rotation"
                        from: 0
                        to: 90
                        duration: ${animationDuration + 200}
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: currentImage
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: ${animationDuration + 200}
                    }
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: nextImage
                        property: "rotation"
                        from: -90
                        to: 0
                        duration: ${animationDuration + 200}
                        easing.type: Easing.OutElastic
                    }
                    NumberAnimation {
                        target: nextImage
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: ${animationDuration + 200}
                    }
                }
            }
        `, animationManager, "rotateAnimation")

        currentAnimations.push(anim)
        return anim
    }

    function resetImages(currentImage, nextImage) {
        currentImage.x = 0
        currentImage.scale = 1
        currentImage.rotation = 0
        currentImage.opacity = 1

        nextImage.x = 0
        nextImage.scale = 1
        nextImage.rotation = 0
        nextImage.opacity = 0
        nextImage.visible = false
    }
}
