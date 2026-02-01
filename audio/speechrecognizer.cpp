#include "speechrecognizer.h"
#include "androidHelpers/androidpermissions.h"
#include <QDebug>
#include <QJniObject>
#include <QJniEnvironment>


#ifdef Q_OS_ANDROID
#include <qnativeinterface.h>
#include <jni.h>
#endif

SpeechRecognizer *SpeechRecognizer::instance(QObject *parent)
{
    static SpeechRecognizer *inst = new SpeechRecognizer(parent);
    return inst;
}

SpeechRecognizer::SpeechRecognizer(QObject *parent)
    : QObject(parent)
{
}

void SpeechRecognizer::init()
{
#ifdef Q_OS_ANDROID
    // Передаём Activity в Java helper
    QJniObject activity = AndroidPermissions::getActivity();
    if (!activity.isValid()) {
        qWarning() << "SpeechRecognizer::init: Activity invalid";
        return;
    }

    QJniObject::callStaticMethod<void>(
        "org/dsa/homepanel/SpeechRecognizerHelper",
        "init",
        "(Landroid/app/Activity;)V",
        activity.object<jobject>()
        );

    qDebug() << "SpeechRecognizer initialized";
#else
    Q_UNUSED(this);
#endif
}

void SpeechRecognizer::startListening()
{
#ifdef Q_OS_ANDROID
    QJniObject::callStaticMethod<void>(
        "org/dsa/homepanel/SpeechRecognizerHelper",
        "startListening",
        "()V"
        );
    qDebug() << "SpeechRecognizer startListening called";
#else
    Q_UNUSED(this);
#endif
}

void SpeechRecognizer::stopListening()
{
#ifdef Q_OS_ANDROID
    QJniObject::callStaticMethod<void>(
        "org/dsa/homepanel/SpeechRecognizerHelper",
        "stopListening",
        "()V"
        );
    qDebug() << "SpeechRecognizer stopListening called";
#else
    Q_UNUSED(this);
#endif
}

void SpeechRecognizer::handleNativeResult(const QString &text, bool isFinal)
{
    if (isFinal) {
        qDebug() << "Speech final:" << text;
        emit finalResult(text);
    } else {
        qDebug() << "Speech partial:" << text;
        emit partialResult(text);
    }
}

// JNI callback - вызывается из Java
extern "C" JNIEXPORT void JNICALL
Java_org_dsa_homepanel_SpeechRecognizerHelper_nativeOnSpeechResult(JNIEnv *env, jclass /*cls*/, jstring jtext, jboolean jisFinal)
{
    if (!jtext) return;
    const char *utf = env->GetStringUTFChars(jtext, nullptr);
    QString text = QString::fromUtf8(utf);
    env->ReleaseStringUTFChars(jtext, utf);

    // Передаём в объект SpeechRecognizer в Qt-поток безопасно
    QMetaObject::invokeMethod(SpeechRecognizer::instance(),
                              "handleNativeResult",
                              Qt::QueuedConnection,
                              Q_ARG(QString, text),
                              Q_ARG(bool, (jisFinal == JNI_TRUE)));
}
