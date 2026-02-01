#ifndef COMMANDPROCESSOR_H
#define COMMANDPROCESSOR_H

#include <QObject>
#include <QString>

class MainPanel;

class CommandProcessor : public QObject
{
    Q_OBJECT

public:
    explicit CommandProcessor(MainPanel *mainPanel, QObject *parent = nullptr);

public slots:
    void processCommand(const QString &text);

private:
    MainPanel *m_mainPanel;
};

#endif // COMMANDPROCESSOR_H
