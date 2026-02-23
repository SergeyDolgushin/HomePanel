// PathProvider.h
#pragma once
#include <QObject>

class PathProvider : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString documents READ documents CONSTANT)
    Q_PROPERTY(QString pictures READ pictures CONSTANT)
    Q_PROPERTY(QString appData READ appData CONSTANT)

public:
    QString documents() const;
    QString pictures() const;
    QString appData() const;

    Q_INVOKABLE bool dirExists(const QString &path) const;
    Q_INVOKABLE bool createDir(const QString &path) const;
};
