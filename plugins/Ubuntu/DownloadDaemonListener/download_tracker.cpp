#include "download_tracker.h"
#include <QDebug>

DownloadTracker::DownloadTracker(QObject *parent) :
    QObject(parent)
{
}

bool DownloadTracker::isServiceReady()
{
    bool ready = false;
    if(this->adaptor != nullptr) {
        ready = this->adaptor->isValid();
    }

    return ready;
}

void DownloadTracker::setDbusPath(QString& path)
{
    if(path != ""){
        this->m_dbusPath = path;
        this->adaptor = new DownloadTrackerAdaptor("com.canonical.applications.Downloader", this->m_dbusPath, QDBusConnection::sessionBus(), 0);

        this->connect(this->adaptor, SIGNAL(canceled(bool)), this, SIGNAL(canceled(bool)));
        this->connect(this->adaptor, SIGNAL(error(const QString &)), this, SIGNAL(error(const QString &)));
        this->connect(this->adaptor, SIGNAL(finished(const QString &)), this, SIGNAL(finished(const QString &)));
        this->connect(this->adaptor, SIGNAL(paused(bool)), this, SIGNAL(paused(bool)));
        this->connect(this->adaptor, SIGNAL(progress(qulonglong, qulonglong)), this, SIGNAL(progress(qulonglong, qulonglong)));
        this->connect(this->adaptor, SIGNAL(resumed(bool)), this, SIGNAL(resumed(bool)));
        this->connect(this->adaptor, SIGNAL(started(bool)), this, SIGNAL(started(bool)));
    }
}
