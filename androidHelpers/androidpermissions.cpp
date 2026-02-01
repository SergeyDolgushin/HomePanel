#include "androidpermissions.h"
#include "qcoreapplication_platform.h"
#include <QDebug>
#include <QJniObject>
#include <QJniEnvironment>
#include <QTimer>
#include <QJniEnvironment>


#ifdef Q_OS_ANDROID
#include <qnativeinterface.h>
#include <jni.h>
#endif

static QJniObject getActivity()
{
    static QJniObject activity;
    static bool initialized = false;

    if (!initialized && QJniEnvironment().isValid()) {
        activity = QJniObject::callStaticObjectMethod(
            "org/qtproject/qt/android/QtNative",
            "activity",
            "()Landroid/app/Activity;"
            );
        if (activity.isValid()) {
            qDebug() << "✅ Activity получена";
        } else {
            qWarning() << "❌ Activity пока недоступна";
        }
        initialized = true;
    }

    return activity;
}

AndroidPermissions *AndroidPermissions::instance()
{
    static AndroidPermissions *inst = new AndroidPermissions();
    return inst;
}

AndroidPermissions::AndroidPermissions(QObject *parent)
    : QObject(parent)
{
    connect(&m_pollTimer, &QTimer::timeout, this, &AndroidPermissions::pollPermission);
    m_pollTimer.setInterval(500); // опрашиваем каждые 500 ms
}

bool AndroidPermissions::hasMicrophonePermission()
{
#ifdef Q_OS_ANDROID
    // Получаем Context как QJniObject (в Qt 6 QNativeInterface возвращает QtJniTypes::Context,
    // который можно присвоить QJniObject)
    QJniObject ctx = QNativeInterface::QAndroidApplication::context();
    if (!ctx.isValid()) {
        qWarning() << "Android context is null";
        return false;
    }

    // Вызов PermissionsHelper.hasRecordAudioPermission(Context):boolean
    jboolean granted = QJniObject::callStaticMethod<jboolean>(
        "org/dsa/homepanel/PermissionsHelper",
        "hasRecordAudioPermission",
        "(Landroid/content/Context;)Z",
        ctx.object<jobject>());

    return granted == JNI_TRUE;
#else
    Q_UNUSED(this);
    return false;
#endif
}

void AndroidPermissions::requestMicrophonePermission()
{
#ifdef Q_OS_ANDROID
    if (hasMicrophonePermission()) {
        qDebug() << "Microphone permission already granted";
        emit microphonePermissionResult(true);
        return;
    }

    // Получаем Activity как QJniObject
    QJniObject activity = getActivity();
    if (!activity.isValid()) {
        qWarning() << "Android activity is null";
        emit microphonePermissionResult(false);
        return;
    }

    const int REQUEST_CODE = 12345; // произвольный код запроса

    // Вызов PermissionsHelper.requestRecordAudioPermission(Activity, int)
    QJniObject::callStaticMethod<void>(
        "org/dsa/homepanel/PermissionsHelper",
        "requestRecordAudioPermission",
        "(Landroid/app/Activity;I)V",
        activity.object<jobject>(),
        REQUEST_CODE);

    // Начинаем опрашивать статус
    m_pollAttempts = 0;
    m_pollTimer.start();
    qDebug() << "Requested microphone permission (dialog shown)";
#else
    Q_UNUSED(this);
    emit microphonePermissionResult(false);
#endif
}

void AndroidPermissions::pollPermission()
{
    m_pollAttempts++;
    bool granted = hasMicrophonePermission();
    if (granted) {
        qDebug() << "Microphone permission granted (detected by poll)";
        m_pollTimer.stop();
        emit microphonePermissionResult(true);
        return;
    }

    if (m_pollAttempts >= m_maxPollAttempts) {
        qDebug() << "Microphone permission NOT granted after polling";
        m_pollTimer.stop();
        emit microphonePermissionResult(false);
    }
}
