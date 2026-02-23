// PathProvider.cpp
#include "PathProvider.h"
#include <QStandardPaths>
#include <QDir>
#include <QJniObject>
#include <QJniEnvironment>

QString PathProvider::documents() const {
#ifdef Q_OS_ANDROID
    QJniObject activity = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;");
    if (activity.isValid()) {
        QJniObject context = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
        if (context.isValid()) {
            QJniObject env = QJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStoragePublicDirectory",
                                                                "(Ljava/lang/String;)Ljava/io/File;",
                                                                QJniObject::fromString("Documents").object<jstring>());
            if (env.isValid()) {
                QString path = env.toString();
                qDebug() << "Path" << path;
                return path + "/maps";  // сразу добавляем подпуть
            }
        }
    }
#endif
    // Fallback для других ОС
    return QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/maps/offline";
}

QString PathProvider::pictures() const
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;");
    if (activity.isValid()) {
        QJniObject context = activity.callObjectMethod("getApplicationContext", "()Landroid/content/Context;");
        if (context.isValid()) {
            QJniObject env = QJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStoragePublicDirectory",
                                                                "(Ljava/lang/String;)Ljava/io/File;",
                                                                QJniObject::fromString("Pictures").object<jstring>());
            if (env.isValid()) {
                QString path = env.toString();
                qDebug() << "Path Pictures" << path;
                return path;  // сразу добавляем подпуть
            }
        }
    }
#endif
    // Fallback для других ОС
    return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/Pictures";
}





QString PathProvider::appData() const {
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

bool PathProvider::dirExists(const QString &path) const {
    return QDir(path).exists();
}

bool PathProvider::createDir(const QString &path) const
{
    return QDir().mkpath(path);  // mkpath создаёт все промежуточные папки
}
