#include "mainpanel.h"
#include <QApplication>
#include <QLocale>
#include <QTranslator>
#include <QDebug>

#ifdef Q_OS_ANDROID
#include "androidHelpers/androidpermissions.h"
#include "audio/speechrecognizer.h"
#endif

#include "audio/audiohandler.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "HomePanel_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            a.installTranslator(&translator);
            break;
        }
    }
    MainPanel w;
    w.show();

#ifdef Q_OS_ANDROID
    auto perm = AndroidPermissions::instance();
    QObject::connect(perm, &AndroidPermissions::microphonePermissionResult, [](bool granted){
        qDebug() << "microphonePermissionResult:" << granted;
        if (granted) {

            // инициализируем SpeechRecognizer и подключаем сигналы к MainPanel
            SpeechRecognizer::instance()->init();
            SpeechRecognizer::instance()->startListening();

            // подключаем UI: ищем существующий MainPanel в приложении
            QObject *top = qApp->topLevelWidgets().isEmpty() ? nullptr : qApp->topLevelWidgets().first();
            MainPanel *mp = qobject_cast<MainPanel*>(top);
            if (mp) {
                QObject::connect(SpeechRecognizer::instance(), &SpeechRecognizer::partialResult,
                                 mp, [mp](const QString &t){ mp->onSpeechPartial(t); });
                QObject::connect(SpeechRecognizer::instance(), &SpeechRecognizer::finalResult,
                                 mp, [mp](const QString &t){ mp->onSpeechFinal(t); });
            }


            // Демонстрация: записываем 5 секунд и затем воспроизводим
            // AudioHandler::instance()->startRecording();
            // QTimer::singleShot(5000, [](){
            //     AudioHandler::instance()->stopAndPlay();
            // });
        } else {
            qDebug() << "No microphone permission, cannot record";
        }
    });

    // Запрос разрешения (если ещё не получено)
    perm->requestMicrophonePermission();
#else
    // На десктопе просто демонстрационно запишем/воспроизведём (если доступно)
    AudioHandler::instance()->startRecording();
    QTimer::singleShot(5000, [](){
        AudioHandler::instance()->stopAndPlay();
    });
#endif

    return a.exec();
}
