#ifndef MYTYPE_H
#define MYTYPE_H

#include <QObject>
#include <QList>
#include <QDBusObjectPath>
#include <interface/downloadtrackeradaptor.h>

class DownloadTracker : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DownloadTracker)
    Q_PROPERTY(QString dbusPath WRITE setDbusPath)
    Q_PROPERTY(bool serviceReady READ isServiceReady)

public:
    explicit DownloadTracker(QObject *parent = 0);

    void setDbusPath(QString& path);
    bool isServiceReady();

Q_SIGNALS:
    void canceled(bool success);
    void error(const QString &error);
    void finished(const QString &path);
    void paused(bool success);
    void progress(qulonglong received, qulonglong total);
    void resumed(bool success);
    void started(bool success);

private:
    QString m_dbusPath;
    DownloadTrackerAdaptor* adaptor;
};

#endif // MYTYPE_H
