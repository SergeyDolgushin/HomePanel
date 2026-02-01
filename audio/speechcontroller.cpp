#include "speechcontroller.h"
#include "audio/speechrecognizer.h"
#include <QDebug>

SpeechController::SpeechController(QObject *parent)
    : QObject(parent)
    , m_restartTimer(new QTimer(this))
{
    m_restartTimer->setInterval(3000); // ждём 3 секунды после остановки
    m_restartTimer->setSingleShot(true);
    connect(m_restartTimer, &QTimer::timeout, this, &SpeechController::startRecognition);

    // Подключаемся к сигналам о завершении
    connect(SpeechRecognizer::instance(), &SpeechRecognizer::finalResult,
            this, &SpeechController::onRecognitionFinished);
    connect(SpeechRecognizer::instance(), &SpeechRecognizer::partialResult,
            this, &SpeechController::onRecognitionFinished);
    // Можно также слушать ошибки, если есть сигнал error

    SpeechRecognizer::instance()->startListening();
}

void SpeechController::onRecognitionFinished()
{
    qDebug() << "Speech finished, restarting in 3 sec...";
    m_restartTimer->start();
}

void SpeechController::startRecognition()
{
    qDebug() << "Starting speech recognition...";
    SpeechRecognizer::instance()->startListening();
}
