#include <QObject>
#include <QStandardPaths>

class SystemInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString picturesPath READ picturesPath CONSTANT)

public:
    QString picturesPath() const {
        return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    }
};
