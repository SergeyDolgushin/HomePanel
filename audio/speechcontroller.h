#ifndef SPEECHCONTROLLER_H
#define SPEECHCONTROLLER_H

#include <QObject>
#include <QTimer>

class SpeechController : public QObject
{
    Q_OBJECT

public:
    explicit SpeechController(QObject *parent = nullptr);

private slots:
    void onRecognitionFinished();
    void startRecognition();

private:
    QTimer *m_restartTimer;
};

#endif // SPEECHCONTROLLER_H
