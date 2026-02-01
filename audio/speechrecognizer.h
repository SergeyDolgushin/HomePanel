#ifndef SPEECHRECOGNIZER_H
#define SPEECHRECOGNIZER_H

#include <QObject>
#include <QString>

class SpeechRecognizer : public QObject
{
    Q_OBJECT
public:
    static SpeechRecognizer *instance(QObject *parent = nullptr);

    // инициализация (передавать activity через QNativeInterface)
    void init();

    void startListening();
    void stopListening();

signals:
    // промежуточный результат (isFinal==false)
    void partialResult(const QString &text);
    // финальный результат (isFinal==true)
    void finalResult(const QString &text);

public slots:
    // слот, вызываемый из JNI callback
    void handleNativeResult(const QString &text, bool isFinal);

private:
    explicit SpeechRecognizer(QObject *parent = nullptr);
};

#endif // SPEECHRECOGNIZER_H
