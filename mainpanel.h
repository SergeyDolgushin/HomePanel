#ifndef MAINPANEL_H
#define MAINPANEL_H

#include <QWidget>
#include <QLabel>
#include <QTimer>

QT_BEGIN_NAMESPACE
namespace Ui {
class MainPanel;
}
QT_END_NAMESPACE

class MainPanel : public QWidget
{
    Q_OBJECT

public:
    MainPanel(QWidget *parent = nullptr);
    ~MainPanel();

    void showClock(bool show);

public slots:
    void onSpeechPartial(const QString &text);
    void onSpeechFinal(const QString &text);

private slots:
    void updateClock();

private:
    Ui::MainPanel *ui;

    QTimer *m_clockTimer;
    QLabel *m_clockLabel;
    QLabel *m_scrollClockLabel;
};
#endif // MAINPANEL_H
