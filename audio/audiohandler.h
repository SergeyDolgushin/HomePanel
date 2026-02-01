#ifndef AUDIOHANDLER_H
#define AUDIOHANDLER_H

#include <QObject>
#include <QByteArray>
#include <QBuffer>

#if QT_VERSION >= QT_VERSION_CHECK(6,0,0)
#include <QAudioSource>
#include <QAudioSink>
#include <QAudioDevice>
#include <QMediaDevices>
#else
// Для старых версий оставьте реализацию под Qt5, если потребуется
#endif

class AudioHandler : public QObject
{
    Q_OBJECT
public:
    static AudioHandler *instance(QObject *parent = nullptr);

    Q_INVOKABLE void startRecording();
    Q_INVOKABLE void stopAndPlay();
    Q_INVOKABLE void stopPlayback();

signals:
    void recordingStarted();
    void recordingStopped();
    void playbackFinished();

private slots:
    void onSourceStateChanged(QAudio::State state);
    void onSinkStateChanged(QAudio::State state);
    void onSourceReadyRead();

private:
    explicit AudioHandler(QObject *parent = nullptr);

    // Qt6 members
    QAudioSource *m_source = nullptr;
    QIODevice *m_sourceDevice = nullptr;

    QAudioSink *m_sink = nullptr;
    QBuffer *m_playBuffer = nullptr;

    QByteArray m_data;
    bool m_isRecording = false;
    bool m_isPlaying = false;
};

#endif // AUDIOHANDLER_H
