#include <QtQml>
#include <QtQml/QQmlContext>
#include "backend.h"
#include "download_tracker.h"


void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Ubuntu.DownloadDaemonListener"));

    qmlRegisterType<DownloadTracker>(uri, 0, 1, "DownloadTracker");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}
