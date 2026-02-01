#ifndef MAINPANEL_H
#define MAINPANEL_H

#include <QWidget>

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

private:
    Ui::MainPanel *ui;
};
#endif // MAINPANEL_H
