#include "audiohandler.h"
#include <QDebug>

#if QT_VERSION >= QT_VERSION_CHECK(6,0,0)

AudioHandler *AudioHandler::instance(QObject *parent)
{
    static AudioHandler *inst = new AudioHandler(parent);
    return inst;
}

AudioHandler::AudioHandler(QObject *parent)
    : QObject(parent)
    , m_source(nullptr)
    , m_sourceDevice(nullptr)
    , m_sink(nullptr)
    , m_playBuffer(nullptr)
{
}

void AudioHandler::startRecording()
{
    if (m_isRecording) {
        qDebug() << "Already recording";
        return;
    }

    // Очистка
    m_data.clear();
    if (m_playBuffer) {
        m_playBuffer->close();
        delete m_playBuffer;
        m_playBuffer = nullptr;
    }

    // Берём рекомендуемый формат входного устройства
    QAudioDevice inputDevice = QMediaDevices::defaultAudioInput();
    QAudioFormat format = inputDevice.preferredFormat();

    // Создаём источник
    if (m_source) {
        m_source->stop();
        delete m_source;
        m_source = nullptr;
    }
    m_source = new QAudioSource(inputDevice, format, this);
    connect(m_source, &QAudioSource::stateChanged, this, &AudioHandler::onSourceStateChanged);

    // Старт: получаем QIODevice для чтения
    m_sourceDevice = m_source->start();
    if (!m_sourceDevice) {
        qWarning() << "Failed to start audio source";
        delete m_source;
        m_source = nullptr;
        return;
    }
    connect(m_sourceDevice, &QIODevice::readyRead, this, &AudioHandler::onSourceReadyRead);

    m_isRecording = true;
    qDebug() << "Recording started (format)" << format.sampleRate()
             << "Hz channels=" << format.channelCount()
             << "sampleFormat=" << int(format.sampleFormat());
    emit recordingStarted();
}

void AudioHandler::onSourceReadyRead()
{
    if (!m_sourceDevice) return;
    QByteArray chunk = m_sourceDevice->readAll();
    if (!chunk.isEmpty()) {
        m_data.append(chunk);
    }
}

void AudioHandler::stopAndPlay()
{
    if (!m_isRecording) {
        qDebug() << "Not recording";
        return;
    }

    // Остановим источник
    if (m_source) {
        m_source->stop();
        if (m_sourceDevice) {
            m_sourceDevice->disconnect(this);
            m_sourceDevice = nullptr;
        }
        m_source->disconnect(this);
        m_source->deleteLater();
        m_source = nullptr;
    }
    m_isRecording = false;
    emit recordingStopped();
    qDebug() << "Recording stopped, bytes:" << m_data.size();

    if (m_data.isEmpty()) {
        qWarning() << "No audio data to play";
        return;
    }

    // Подготовим буфер для проигрывания
    if (m_playBuffer) {
        m_playBuffer->close();
        delete m_playBuffer;
        m_playBuffer = nullptr;
    }
    m_playBuffer = new QBuffer(&m_data, this);
    m_playBuffer->open(QIODevice::ReadOnly);
    m_playBuffer->seek(0);

    // Настроим sink с тем же форматом, что использовался на входе
    QAudioDevice outputDevice = QMediaDevices::defaultAudioOutput();
    // В идеале используем формат, совместимый с sink; берем предпочтительный формат вывода
    QAudioFormat outFormat = outputDevice.preferredFormat();

    // Если форматы сильно отличаются, можно попытаться привести: тут для простоты используем preferredFormat()
    if (m_sink) {
        m_sink->stop();
        delete m_sink;
        m_sink = nullptr;
    }
    m_sink = new QAudioSink(outputDevice, outFormat, this);
    connect(m_sink, &QAudioSink::stateChanged, this, &AudioHandler::onSinkStateChanged);

    // Запускаем воспроизведение из buffer
    m_sink->start(m_playBuffer);
    m_isPlaying = true;
    qDebug() << "Playback started (format)" << outFormat.sampleRate()
             << "Hz channels=" << outFormat.channelCount()
             << "sampleFormat=" << int(outFormat.sampleFormat());
}

void AudioHandler::stopPlayback()
{
    if (!m_isPlaying) return;

    if (m_sink) {
        m_sink->stop();
        m_sink->disconnect(this);
        delete m_sink;
        m_sink = nullptr;
    }
    if (m_playBuffer) {
        m_playBuffer->close();
        delete m_playBuffer;
        m_playBuffer = nullptr;
    }
    m_data.clear();
    m_isPlaying = false;
    emit playbackFinished();
    qDebug() << "Playback stopped and buffer cleared";
}

void AudioHandler::onSourceStateChanged(QAudio::State state)
{
    if (state == QAudio::StoppedState) {
        if (m_source && m_source->error() != QAudio::NoError) {
            qWarning() << "AudioSource error:" << m_source->error();
        }
    }
}

void AudioHandler::onSinkStateChanged(QAudio::State state)
{
    if (state == QAudio::IdleState) {
        // Воспроизведение окончилось
        qDebug() << "Playback finished (IdleState)";
        if (m_sink) {
            m_sink->stop();
            m_sink->disconnect(this);
            delete m_sink;
            m_sink = nullptr;
        }
        if (m_playBuffer) {
            m_playBuffer->close();
            delete m_playBuffer;
            m_playBuffer = nullptr;
        }
        m_data.clear();
        m_isPlaying = false;
        emit playbackFinished();
    } else if (state == QAudio::StoppedState) {
        if (m_sink && m_sink->error() != QAudio::NoError) {
            qWarning() << "AudioSink error:" << m_sink->error();
        }
    }
}

#else
// Заглушки/реализация для Qt5 можно добавить при необходимости
AudioHandler *AudioHandler::instance(QObject *parent) { Q_UNUSED(parent); return nullptr; }
AudioHandler::AudioHandler(QObject *parent) : QObject(parent) {}
void AudioHandler::startRecording() { Q_UNUSED(this); }
void AudioHandler::stopAndPlay() { Q_UNUSED(this); }
void AudioHandler::stopPlayback() { Q_UNUSED(this); }
void AudioHandler::onSourceStateChanged(QAudio::State) {}
void AudioHandler::onSinkStateChanged(QAudio::State) {}
void AudioHandler::onSourceReadyRead() {}
#endif
