#include "mainpanel.h"
// #include "androidHelpers/androidutils.h"
#include "qdatetime.h"
#include "ui_mainpanel.h"
#include <QScreen>

MainPanel::MainPanel(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::MainPanel)
{
    ui->setupUi(this);


    // QSize phys = AndroidUtils::physicalScreenSize();
    // qreal density = AndroidUtils::physicalDensity();

    // qDebug() << "Физическое разрешение:" << phys;     // → 1920x1080
    // qDebug() << "Плотность (density):" << density;    // → 2.0, 3.0 и т.д.
    qDebug() << "Phisical DPI:" << this->screen()->physicalDotsPerInch(); // → 749x468
    qDebug() << "Logical DPI:" << this->screen()->logicalDotsPerInch(); // → 749x468

    m_clockLabel = ui->clockLabel;           // из mainpanel.ui
    m_scrollClockLabel = ui->scrollClockLabel;

    // Скрываем часы по умолчанию
    // m_clockLabel->hide();
    ui->mainContentArea->setStyleSheet("background: red;");
    m_clockLabel->setStyleSheet(
        "font-size: 48px;"
        "color: white;"
        "background-color: rgba(0, 0, 0, 150);"
        "border-radius: 15px;"
        "padding: 20px;"
        "qproperty-alignment: AlignCenter;"
        );
    // m_clockLabel->setText("ТЕСТ");
    m_clockLabel->setVisible(false);
    // m_clockLabel->raise();
    // m_clockLabel->repaint();

    // qDebug() << "clockLabel parent:" << m_clockLabel->parentWidget();
    // qDebug() << "mainContentArea children:" << ui->mainContentArea->findChildren<QWidget*>().size();


    // Таймер обновления времени
    m_clockTimer = new QTimer(this);
    connect(m_clockTimer, &QTimer::timeout, this, &MainPanel::updateClock);
    m_clockTimer->start(1000);

    updateClock(); // первый раз
}

MainPanel::~MainPanel()
{
    delete ui;
}

void MainPanel::showClock(bool show)
{
    if (m_clockLabel) {
        m_clockLabel->setVisible(show);
        if (show) {
            // Принудительное обновление
            // m_clockLabel->raise();
            // m_clockLabel->adjustSize(); // попробовать вычислить размер
            // ui->mainContentArea->layout()->update();
            // ui->mainContentArea->updateGeometry();
            // m_clockLabel->repaint();
        }
    }
}

void MainPanel::onSpeechPartial(const QString &text)
{
    qDebug() << "UI partial:" << text;
}

void MainPanel::onSpeechFinal(const QString &text)
{
    qDebug() << "UI final:" << text;
}

void MainPanel::updateClock()
{
    QString timeStr = QTime::currentTime().toString("hh:mm:ss");
    if (m_scrollClockLabel) {
        m_scrollClockLabel->setText(timeStr);
        // m_clockLabel->setText(timeStr);
    }


    if (m_clockLabel && m_clockLabel->isVisible()) {
        qDebug() << "Команда: показать часы" << m_clockLabel->isVisible();
        // qDebug() << "clockLabel size:" << m_clockLabel->size();
        // qDebug() << "clockLabel geometry:" << m_clockLabel->geometry();
        // qDebug() << "mainContentArea layout size:" << ui->mainContentArea->layout()->sizeHint();

        m_clockLabel->setText(timeStr);
    }

}
