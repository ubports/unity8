#include <QDebug>

#include "ualwrapper.h"

#include <ubuntu-app-launch/registry.h>
using namespace ubuntu::app_launch;

UalWrapper::UalWrapper(QObject *parent):
    QObject(parent)
{

}

QStringList UalWrapper::installedApps()
{
    QStringList appIds;
    Registry::installedApps();
    for (std::shared_ptr<Application> app : Registry::installedApps()) {
        appIds << QString::fromStdString(app->appId().package) + "_" + QString::fromStdString(app->appId().appname);
    }
    return appIds;
}

UalWrapper::AppInfo UalWrapper::getApplicationInfo(const QString &appId)
{
    AppInfo info;

    AppID ualAppId = AppID::find(Registry::getDefault(), appId.toStdString());
    if (ualAppId.empty()) {
        return info;
    }

    std::shared_ptr<Application> ualApp;
    try
    {
        ualApp = Application::create(ualAppId, Registry::getDefault());
    }
    catch (std::runtime_error &e)
    {
        qWarning() << "Couldn't find application info for" << appId << "-" << e.what();
        return info;
    }

    info.valid = true;
    info.name = QString::fromStdString(ualApp->info()->name());
    info.icon = QString::fromStdString(ualApp->info()->iconPath());
    return info;
}
