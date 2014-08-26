#ifndef DESKTOPFILEHANDLER_H
#define DESKTOPFILEHANDLER_H

#include <QObject>

class DesktopFileHandler: public QObject
{
    Q_OBJECT
public:
    DesktopFileHandler(QObject *parent = nullptr);

    QString findDesktopFile(const QString &appId) const;

    QString displayName(const QString &appId) const;
    QString icon(const QString &appId) const;
};

#endif
