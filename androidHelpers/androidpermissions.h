#ifndef ANDROIDPERMISSIONS_H
#define ANDROIDPERMISSIONS_H

#include "qjniobject.h"
#include <QObject>
#include <QTimer>

class AndroidPermissions : public QObject
{
    Q_OBJECT
public:
    static AndroidPermissions *instance();

    // Проверить, есть ли разрешение на микрофон
    bool hasMicrophonePermission();

    // Запросить разрешение (покажет диалог пользователю)
    void requestMicrophonePermission();
    static QJniObject getActivity();

signals:
    // Сигнал выдаёт текущее состояние после опроса: granted == true, иначе false
    void microphonePermissionResult(bool granted);

private slots:
    void pollPermission();

private:
    explicit AndroidPermissions(QObject *parent = nullptr);
    QTimer m_pollTimer;
    int m_pollAttempts = 0;
    const int m_maxPollAttempts = 20; // опросим ~20 раз (~10 секунд при 500ms интервале)
};

#endif // ANDROIDPERMISSIONS_H
