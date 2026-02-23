#include "androidutils.h"
#include <QJniObject>
#include <QJniEnvironment>
#include <QDebug>
// #include <qnativeinterface.h>
#include "qcoreapplication_platform.h"

bool hasManageExternalStoragePermission() {
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) {
        qWarning() << "❌ Activity недоступен";
        return false;
    }

    QJniObject packageName = activity.callObjectMethod("getPackageName", "()Ljava/lang/String;");
    if (!packageName.isValid()) {
        qWarning() << "❌ Не удалось получить package name";
        return false;
    }

    // QString uriStr = "content://com.android.externalstorage.documents/tree/primary%3ADocuments";
    QString uriStr = "content://com.android.externalstorage.pictures/tree/primary%3APictures";
    QJniObject uri = QJniObject::callStaticObjectMethod(
        "android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;",
        QJniObject::fromString(uriStr).object<jstring>()
        );

    QJniObject intentAction = QJniObject::fromString("android.content.action.DOCUMENTS_PROVIDER");
    QJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", intentAction.object<jstring>());
    intent.callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;", uri.object<jobject>());

    QJniObject manager = activity.callObjectMethod(
        "getSystemService", "(Ljava/lang/String;)Ljava/lang/Object;",
        QJniObject::fromString("storage").object<jstring>()
        );

    if (!manager.isValid()) {
        qWarning() << "❌ StorageManager недоступен";
        return false;
    }

    // Проверяем через StorageManager.hasSystemUidAccess (API 30+)
    // Альтернатива: проверить через canWrite()
    QJniObject file = QJniObject("java/io/File", "(Ljava/lang/String;)V",
                                 QJniObject::fromString("/storage/emulated/0/Pictures").object<jstring>());
    jboolean canWrite = file.callMethod<jboolean>("canWrite");

    qDebug() << "📌 canWrite /Documents:" << canWrite;
    return canWrite;
}


void requestAllFilesAccess() {
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    if (!activity.isValid()) {
        qWarning() << "❌ Activity недоступен";
        return;
    }

    QJniObject intentAction = QJniObject::fromString("android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION");
    QJniObject uri = QJniObject::callStaticObjectMethod(
        "android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;",
        QJniObject::fromString("package:" + activity.callObjectMethod("getPackageName", "()Ljava/lang/String;").toString()).object<jstring>()
        );

    QJniObject intent("android/content/Intent", "(Ljava/lang/String;)V", intentAction.object<jstring>());
    intent.callObjectMethod("setData", "(Landroid/net/Uri;)Landroid/content/Intent;", uri.object<jobject>());

    activity.callMethod<void>("startActivity", "(Landroid/content/Intent;)V", intent.object<jobject>());

    qDebug() << "✅ Перенаправлено в настройки для 'Доступ ко всем файлам'";
}

