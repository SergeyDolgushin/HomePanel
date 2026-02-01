#include "commandprocessor.h"
#include "mainpanel.h"
#include <QDebug>

CommandProcessor::CommandProcessor(MainPanel *mainPanel, QObject *parent)
    : QObject(parent), m_mainPanel(mainPanel)
{
}

void CommandProcessor::processCommand(const QString &text)
{
    QString lower = text.toLower().trimmed();
    qDebug() << "Processing command:" << lower;

    if (lower.contains("покажи") && lower.contains("часы")) {
        m_mainPanel->showClock(true);
        qDebug() << "Команда: показать часы";
    }
    else if (lower.contains("убери") && lower.contains("часы")) {
        m_mainPanel->showClock(false);
        qDebug() << "Команда: убрать часы";
    }
    // Можно добавить другие команды
}
