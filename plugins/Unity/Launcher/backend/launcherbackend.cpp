#include "launcherbackend.h"

#include <QHash>

LauncherBackend::LauncherBackend(QObject *parent):
    QObject(parent)
{

    // TODO: load default pinned ones from default config, instead of hardcoding here...

    m_storedApps <<
        QLatin1String("phone-app.desktop") <<
        QLatin1String("camera-app.desktop") <<
        QLatin1String("gallery-app.desktop") <<
        QLatin1String("facebook-webapp.desktop") <<
        QLatin1String("webbrowser-app.desktop") <<
        QLatin1String("twitter-webapp.desktop") <<
        QLatin1String("gmail-webapp.desktop") <<
        QLatin1String("ubuntu-weather-app.desktop") <<
        QLatin1String("notes-app.desktop") <<
        QLatin1String("ubuntu-calendar-app.desktop");
}

LauncherBackend::~LauncherBackend()
{

}

QStringList LauncherBackend::storedApplications() const
{
    return m_storedApps;
}

void LauncherBackend::setStoredApplications(const QStringList &appIds)
{
    m_storedApps = appIds;
    // TODO: Cleanup pinned state from settings for apps not in list any more.
}

QString LauncherBackend::displayName(const QString &appId) const
{
    // TODO: get stuff from desktop files instead this hardcoded map
    QHash<QString, QString> map;
    map.insert("phone-app.desktop", "Phone");
    map.insert("camera-app.desktop", "Camera");
    map.insert("gallery-app.desktop", "Gallery");
    map.insert("facebook-webapp.desktop", "Facebook");
    map.insert("webbrowser-app.desktop", "Browser");
    map.insert("twitter-webapp.desktop", "Twitter");
    map.insert("gmail-webapp.desktop", "GMail");
    map.insert("ubuntu-weather-app.desktop", "Weather");
    map.insert("notes-app.desktop", "Notes");
    map.insert("ubuntu-calendar-app.desktop", "Calendar");
    return map.value(appId);
}

QString LauncherBackend::icon(const QString &appId) const
{
    // TODO: get stuff from desktop files instead this hardcoded map
    QHash<QString, QString> map;
    map.insert("phone-app.desktop", "phone-app");
    map.insert("camera-app.desktop", "camera");
    map.insert("gallery-app.desktop", "gallery");
    map.insert("facebook-webapp.desktop", "facebook");
    map.insert("webbrowser-app.desktop", "browser");
    map.insert("twitter-webapp.desktop", "twitter");
    map.insert("gmail-webapp.desktop", "gmail");
    map.insert("ubuntu-weather-app.desktop", "weather");
    map.insert("notes-app.desktop", "notepad");
    map.insert("ubuntu-calendar-app.desktop", "calendar");
    return map.value(appId);
}

bool LauncherBackend::isPinned(const QString &appId) const
{
    // TODO: return app's pinned state from settings
    return true;
}

void LauncherBackend::setPinned(const QString &appId, bool pinned)
{
    // TODO: Store pinned state in settings.
}

QuickListModelInterface* LauncherBackend::quickList(const QString &appId) const
{
    // TODO: No clue where to get the quicklist from, but this is the place to return it.
    return 0;
}

int LauncherBackend::progress(const QString &appId) const
{
    // TODO: Return value for progress emblem.
    // TODO: emit progressChanged() when this value changes.
    return -1;
}

int LauncherBackend::count(const QString &appId) const
{
    // TODO: Return value for count emblem.
    // TODO: emit countChanged() when this value changes.
    return 0;
}
