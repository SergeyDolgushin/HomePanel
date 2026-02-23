#include "backend/androidutils.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QJniObject>
#include <QJniEnvironment>

#include <backend/PathProvider.h>
#include <backend/SystemInfo.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterSingletonType<SystemInfo>("SystemInfo", 1, 0, "SystemInfo",
                                         [](QQmlEngine*, QJSEngine*) -> QObject* {
                                             SystemInfo* info = new SystemInfo();
                                             return info;
                                         });


    QQmlApplicationEngine engine;

    PathProvider pathProvider;
    qDebug() << "🔧 Registering pathProvider";
    engine.rootContext()->setContextProperty("pathProvider", &pathProvider);


// #ifdef Q_OS_ANDROID
//     // if (!hasManageExternalStoragePermission()) {
//     qDebug() << "🔒 Нет разрешения MANAGE_EXTERNAL_STORAGE — запрашиваем...";
    // requestAllFilesAccess();
//     // } else {
//         // qDebug() << "✅ Разрешение MANAGE_EXTERNAL_STORAGE уже получено";
//     // }
// #else
//     Q_UNUSED(pathProvider);
// #endif


    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("HomePanel", "Main");

    return app.exec();
}
