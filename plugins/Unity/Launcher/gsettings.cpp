#include "gsettings.h"

#include <QGSettings>
#include <QVariant>
#include <QDebug>

GSettings::GSettings(QObject *parent):
    QObject(parent)
{

}

QStringList GSettings::storedApplications() const
{
    QStringList storedApps;

    QGSettings gSettings("com.canonical.Unity.Launcher", "/com/canonical/unity/launcher/");

    QString settingsKey = "items";

    // If "items" doesn't contain anything yet, import unity7's "favorites"
    if (gSettings.get(settingsKey).toStringList().isEmpty()) {
        settingsKey = "favorites";
    }

    Q_FOREACH(const QString &entry, gSettings.get(settingsKey).toStringList()) {
        qDebug() << "got entry" << entry;
        if (entry.startsWith("application://")) {
            // convert legacy entries to new world appids
            QString appId = entry;
            // Transform "application://foobar.desktop" to "foobar"
            appId.remove(QRegExp("^application://"));
            appId.remove(QRegExp(".desktop$"));
            storedApps << appId;
        }
        if (entry.startsWith("appid://")) {
            QString appId = entry;
            appId.remove("appid://");
            if (appId.split('/').count() == 3) {
                // Strip current-user-version in case its there
                appId = appId.split('/').first() +  "_" + appId.split('/').at(1);
            }
            storedApps << appId;
        }
    }
    return storedApps;
}

void GSettings::setStoredApplications(const QStringList &storedApplications)
{
    QGSettings gSettings("com.canonical.Unity.Launcher", "/com/canonical/unity/launcher/");
    QStringList gSettingsList;
    Q_FOREACH(const QString &entry, storedApplications) {
        gSettingsList << QString("appid://%1").arg(entry);
    }
    gSettings.set("items", gSettingsList);
}
