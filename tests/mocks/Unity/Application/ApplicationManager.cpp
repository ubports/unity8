/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "ApplicationManager.h"
#include "ApplicationInfo.h"
#include "MirSurface.h"

#include <paths.h>
#include <csignal>

#include <QDir>
#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QTimer>
#include <QDateTime>
#include <QtDBus/QtDBus>

#define APPLICATIONMANAGER_DEBUG 0

#if APPLICATIONMANAGER_DEBUG
#define DEBUG_MSG(params) qDebug().nospace() << "ApplicationManager::" << __func__  << " " << params
#else
#define DEBUG_MSG(params) ((void)0)
#endif

namespace unityapi = unity::shell::application;

ApplicationManager::ApplicationManager(QObject *parent)
    : ApplicationManagerInterface(parent)
{
    DEBUG_MSG("");
    buildListOfAvailableApplications();

    // polling to find out when the toplevel window has been created as there's
    // no signal telling us that
    connect(&m_windowCreatedTimer, &QTimer::timeout,
            this, &ApplicationManager::onWindowCreatedTimerTimeout);
    m_windowCreatedTimer.setSingleShot(false);
    m_windowCreatedTimer.start(200);

    Q_ASSERT(MirFocusController::instance());
    connect(MirFocusController::instance(), &MirFocusController::focusedSurfaceChanged,
        this, &ApplicationManager::updateFocusedApplication, Qt::QueuedConnection);


    // Emit signal to notify Upstart that Mir is ready to receive client connections
    // see http://upstart.ubuntu.com/cookbook/#expect-stop
    // We do this because some autopilot tests actually use this mock Unity.Application module,
    // so we have to mimic what the real ApplicationManager does in that regard.
    if (qgetenv("UNITY_MIR_EMITS_SIGSTOP") == "1") {
        raise(SIGSTOP);
    }
}

ApplicationManager::~ApplicationManager()
{
}

void ApplicationManager::onWindowCreatedTimerTimeout()
{
    if (QGuiApplication::topLevelWindows().count() > 0) {
        m_windowCreatedTimer.stop();
        onWindowCreated();
    }
}

void ApplicationManager::onWindowCreated()
{
    startApplication("unity8-dash");
}

int ApplicationManager::rowCount(const QModelIndex& parent) const {
    return !parent.isValid() ? m_runningApplications.size() : 0;
}

QVariant ApplicationManager::data(const QModelIndex& index, int role) const {
    if (index.row() < 0 || index.row() >= m_runningApplications.size())
        return QVariant();

    auto app = m_runningApplications.at(index.row());
    switch(role) {
    case RoleAppId:
        return app->appId();
    case RoleName:
        return app->name();
    case RoleComment:
        return app->comment();
    case RoleIcon:
        return app->icon();
    case RoleStage:
        return app->stage();
    case RoleState:
        return app->state();
    case RoleFocused:
        return app->focused();
    case RoleIsTouchApp:
        return app->isTouchApp();
    case RoleExemptFromLifecycle:
        return app->exemptFromLifecycle();
    case RoleApplication:
        return QVariant::fromValue(static_cast<unityapi::ApplicationInfoInterface*>(app));
    default:
        return QVariant();
    }
}

ApplicationInfo *ApplicationManager::get(int row) const {
    if (row < 0 || row >= m_runningApplications.size())
        return nullptr;
    return m_runningApplications.at(row);
}

ApplicationInfo *ApplicationManager::findApplication(const QString &appId) const {
    for (ApplicationInfo *app : m_runningApplications) {
        if (app->appId() == appId) {
            return app;
        }
    }
    return nullptr;
}

QModelIndex ApplicationManager::findIndex(ApplicationInfo* application)
{
    for (int i = 0; i < m_runningApplications.size(); ++i) {
        if (m_runningApplications.at(i) == application) {
            return index(i);
        }
    }

    return QModelIndex();
}

bool ApplicationManager::add(ApplicationInfo *application) {
    if (!application || m_runningApplications.contains(application)) {
        return false;
    }
    DEBUG_MSG(application->appId());

    application->setState(ApplicationInfo::Starting);

    beginInsertRows(QModelIndex(), m_runningApplications.size(), m_runningApplications.size());
    m_runningApplications.append(application);

    connect(application, &ApplicationInfo::focusedChanged, this, [application, this]() {
        QModelIndex appIndex = findIndex(application);
        if (!appIndex.isValid()) return;
        Q_EMIT dataChanged(appIndex, appIndex, QVector<int>() << ApplicationManager::RoleFocused);
    });
    connect(application, &ApplicationInfo::stateChanged, this, [application, this]() {
        QModelIndex appIndex = findIndex(application);
        if (!appIndex.isValid()) return;
        Q_EMIT dataChanged(appIndex, appIndex, QVector<int>() << ApplicationManager::RoleState);
    });
    connect(application, &ApplicationInfo::stageChanged, this, [application, this]() {
        QModelIndex appIndex = findIndex(application);
        if (!appIndex.isValid()) return;
        Q_EMIT dataChanged(appIndex, appIndex, QVector<int>() << ApplicationManager::RoleStage);
    });

    connect(application, &ApplicationInfo::closed, this, [application, this]() {
        this->remove(application);
    });
    connect(application, &ApplicationInfo::focusRequested, this, [application, this]() {
        Q_EMIT this->focusRequested(application->appId());
    });

    endInsertRows();
    Q_EMIT countChanged();
    if (count() == 1) Q_EMIT emptyChanged(isEmpty()); // was empty but not anymore

    return true;
}

void ApplicationManager::remove(ApplicationInfo *application) {
    int i = m_runningApplications.indexOf(application);
    if (i != -1) {
        DEBUG_MSG(application->appId());
        beginRemoveRows(QModelIndex(), i, i);
        m_runningApplications.removeAt(i);
        endRemoveRows();
        Q_EMIT countChanged();
        if (isEmpty()) Q_EMIT emptyChanged(isEmpty());
    }
    application->disconnect(this);
}

void ApplicationManager::move(int from, int to) {
    if (from == to) return;

    if (from >= 0 && from < m_runningApplications.size() && to >= 0 && to < m_runningApplications.size()) {
        QModelIndex parent;
        /* When moving an item down, the destination index needs to be incremented
         * by one, as explained in the documentation:
         * http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */
        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
        m_runningApplications.move(from, to);
        endMoveRows();
    }
}

ApplicationInfo* ApplicationManager::startApplication(const QString &appId,
                                              const QStringList &arguments)
{
    DEBUG_MSG(appId);
    Q_UNUSED(arguments)

    ApplicationInfo *application = findApplication(appId);
    if (application) {
        // the requested app is already running
        return application;
    } else {
        application = add(appId);
    }

    // most likely not among the available ones
    if (!application)
        return nullptr;

    Q_EMIT application->focusRequested(); // we assume that an application that's starting up wants focus

    return application;
}

ApplicationInfo* ApplicationManager::add(QString appId)
{
    ApplicationInfo *application = nullptr;

    for (ApplicationInfo *availableApp : m_availableApplications) {
        if (availableApp->appId() == appId) {
            application = availableApp;
            break;
        }
    }

    if (application) {
        if (!add(application)) {
            application = nullptr;
        }
    }

    return application;
}

bool ApplicationManager::stopApplication(const QString &appId)
{
    DEBUG_MSG(appId);
    ApplicationInfo *application = findApplication(appId);
    if (application == nullptr)
        return false;

    application->close();
    return true;
}

QString ApplicationManager::focusedApplicationId() const {
    for (ApplicationInfo *app : m_runningApplications) {
        if (app->focused()) {
            return app->appId();
        }
    }
    return QString();
}

bool ApplicationManager::requestFocusApplication(const QString &appId)
{
    ApplicationInfo *application = findApplication(appId);
    if (application == nullptr)
        return false;

    application->requestFocus();

    return true;
}

void ApplicationManager::buildListOfAvailableApplications()
{
    /*
        ATTENTION!
        Be careful when changing application properties here as some qmltests
        rely on them being the way it's specified here (e.g. that camera-app
        is fullscreen, that twitter-webapp can rotate in all directions, etc)
     */

    ApplicationInfo *application;

    application = new ApplicationInfo(this);
    application->setAppId("unity8-dash");
    application->setName("Unity 8 Mock Dash");
    application->setScreenshotId("unity8-dash");
    application->setSupportedOrientations(Qt::PrimaryOrientation);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("dialer-app");
    application->setName("Dialer");
    application->setScreenshotId("dialer");
    application->setIconId("dialer-app");
    application->setSupportedOrientations(Qt::PortraitOrientation
                                        | Qt::InvertedPortraitOrientation);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("camera-app");
    application->setName("Camera");
    application->setScreenshotId("camera");
    application->setIconId("camera");
    application->setFullscreen(true);
    application->setSupportedOrientations(Qt::PortraitOrientation
                                        | Qt::LandscapeOrientation
                                        | Qt::InvertedPortraitOrientation
                                        | Qt::InvertedLandscapeOrientation);
    application->setRotatesWindowContents(true);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("gallery-app");
    application->setName("Gallery");
    application->setScreenshotId("gallery");
    application->setIconId("gallery");
    application->setShellChrome(Mir::LowChrome);
    application->setStage(ApplicationInfo::MainStage);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("facebook-webapp");
    application->setName("Facebook");
    application->setScreenshotId("facebook");
    application->setIconId("facebook");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("webbrowser-app");
    application->setShellChrome(Mir::LowChrome);
    application->setName("Browser");
    application->setScreenshotId("browser");
    application->setIconId("browser");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("twitter-webapp");
    application->setName("Twitter");
    application->setScreenshotId("twitter");
    application->setIconId("twitter");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("map");
    application->setName("Map");
    application->setIconId("map");
    application->setScreenshotId("map");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("gmail-webapp");
    application->setName("GMail");
    application->setIconId("gmail");
    application->setScreenshotId("gmail-webapp.svg");
    application->setStage(ApplicationInfo::MainStage);
    application->setSupportedOrientations(Qt::PortraitOrientation
                                        | Qt::LandscapeOrientation
                                        | Qt::InvertedPortraitOrientation
                                        | Qt::InvertedLandscapeOrientation);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("music-app");
    application->setName("Music");
    application->setIconId("soundcloud");
    application->setScreenshotId("music");
    application->setStage(ApplicationInfo::MainStage);
    application->setSupportedOrientations(Qt::PortraitOrientation
                                        | Qt::LandscapeOrientation
                                        | Qt::InvertedPortraitOrientation
                                        | Qt::InvertedLandscapeOrientation);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("ubuntu-weather-app");
    application->setName("Weather");
    application->setIconId("weather");
    application->setScreenshotId("ubuntu-weather-app.svg");
    application->setSupportedOrientations(Qt::LandscapeOrientation
                                        | Qt::InvertedLandscapeOrientation);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("notes-app");
    application->setName("Notepad");
    application->setIconId("notepad");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("calendar-app");
    application->setName("Calendar");
    application->setIconId("calendar");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("evernote");
    application->setName("Evernote");
    application->setIconId("evernote");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("pinterest");
    application->setName("Pinterest");
    application->setIconId("pinterest");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("soundcloud");
    application->setName("SoundCloud");
    application->setIconId("soundcloud");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("wikipedia");
    application->setName("Wikipedia");
    application->setIconId("wikipedia");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("youtube");
    application->setName("YouTube");
    application->setIconId("youtube");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("libreoffice");
    application->setName("LibreOffice");
    application->setIconId("libreoffice");
    application->setScreenshotId("libreoffice");
    application->setIsTouchApp(false);
    m_availableApplications.append(application);
}


QStringList ApplicationManager::availableApplications()
{
    QStringList appIds;
    Q_FOREACH(ApplicationInfo *app, m_availableApplications) {
        appIds << app->appId();
    }
    return appIds;
}

bool ApplicationManager::isEmpty() const
{
    return m_runningApplications.isEmpty();
}

void ApplicationManager::updateFocusedApplication()
{
    ApplicationInfo *focusedApplication = nullptr;
    ApplicationInfo *previouslyFocusedApplication = nullptr;

    auto controller = MirFocusController::instance();
    if (!controller) {
        return;
    }

    MirSurface *surface = static_cast<MirSurface*>(controller->focusedSurface());
    if (surface) {
        focusedApplication = findApplication(surface);
    }

    surface = static_cast<MirSurface*>(controller->previouslyFocusedSurface());
    if (surface) {
        previouslyFocusedApplication = findApplication(surface);
    }

    if (focusedApplication != previouslyFocusedApplication) {
        if (focusedApplication) {
            DEBUG_MSG("focused " << focusedApplication->appId());
            Q_EMIT focusedApplication->focusedChanged(true);
            this->move(this->m_runningApplications.indexOf(focusedApplication), 0);
        }
        if (previouslyFocusedApplication) {
            DEBUG_MSG("unfocused " << previouslyFocusedApplication->appId());
            Q_EMIT previouslyFocusedApplication->focusedChanged(false);
        }
        Q_EMIT focusedApplicationIdChanged();
    }
}

ApplicationInfo *ApplicationManager::findApplication(MirSurface* surface)
{
    for (ApplicationInfo *app : m_runningApplications) {
        auto surfaceList = static_cast<MirSurfaceListModel*>(app->surfaceList());
        if (surfaceList->contains(surface)) {
            return app;
        }
    }
    return nullptr;
}
