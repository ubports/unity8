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
#define XDEBUG_MSG(params) qDebug().nospace() << "ApplicationManager::" << params
#else
#define DEBUG_MSG(params) ((void)0)
#define XDEBUG_MSG(params) ((void)0)
#endif

namespace unityapi = unity::shell::application;


ApplicationManager::ApplicationManager(QObject *parent)
    : ApplicationManagerInterface(parent)
{
    DEBUG_MSG("");

    ApplicationManagerNotifier::instance()->setApplicationManager(this);

    buildListOfAvailableApplications();

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
    ApplicationManagerNotifier::instance()->setApplicationManager(nullptr);
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

unityapi::ApplicationInfoInterface *ApplicationManager::findApplicationWithSurface(unityapi::MirSurfaceInterface* surface) const
{
    for (ApplicationInfo *app : m_runningApplications) {
        auto surfaceList = static_cast<MirSurfaceListModel*>(app->surfaceList());
        if (surfaceList->contains(static_cast<MirSurface*>(surface))) {
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
        XDEBUG_MSG("focusedApplicationId = " << focusedApplicationId());
        Q_EMIT focusedApplicationIdChanged();
        if (application->focused()) {
            raiseApp(application->appId());
        }
    });
    connect(application, &ApplicationInfo::stateChanged, this, [application, this]() {
        QModelIndex appIndex = findIndex(application);
        if (!appIndex.isValid()) return;
        Q_EMIT dataChanged(appIndex, appIndex, QVector<int>() << ApplicationManager::RoleState);
    });

    connect(application, &ApplicationInfo::closed, this, [application, this]() {
        this->remove(application);
    });
    connect(application, &ApplicationInfo::focusRequested, this, [application, this]() {
        Q_EMIT this->focusRequested(application->appId());
    });

    endInsertRows();
    Q_EMIT countChanged();

    return true;
}

void ApplicationManager::remove(ApplicationInfo *application) {
    int i = m_runningApplications.indexOf(application);
    application->disconnect(this);
    if (i != -1) {
        DEBUG_MSG(application->appId());
        Q_ASSERT(!m_modelBusy);
        m_modelBusy = true;
        beginRemoveRows(QModelIndex(), i, i);
        m_runningApplications.removeAt(i);
        endRemoveRows();
        m_modelBusy = false;
        Q_EMIT countChanged();
        DEBUG_MSG(application->appId() << " after: " << qPrintable(toString()));
    }
}

void ApplicationManager::raiseApp(const QString &appId)
{

    int index = -1;
    for (int i = 0; i < m_runningApplications.count() && index == -1; ++i) {
        if (m_runningApplications[i]->appId() == appId) {
            index = i;
        }
    }

    if (index >= 0) {
        if (m_modelBusy) {
            DEBUG_MSG(appId << " - model busy. Try again later.");
            QMetaObject::invokeMethod(this, "raiseApp", Qt::QueuedConnection, Q_ARG(QString, appId));
        } else {
            DEBUG_MSG(appId);
            move(index, 0);
        }
    }
}

void ApplicationManager::move(int from, int to) {
    if (from == to) return;

    if (from >= 0 && from < m_runningApplications.size() && to >= 0 && to < m_runningApplications.size()) {
        QModelIndex parent;
        Q_ASSERT(!m_modelBusy);
        m_modelBusy = true;
        /* When moving an item down, the destination index needs to be incremented
         * by one, as explained in the documentation:
         * http://qt-project.org/doc/qt-5.0/qtcore/qabstractitemmodel.html#beginMoveRows */
        beginMoveRows(parent, from, from, parent, to + (to > from ? 1 : 0));
        m_runningApplications.move(from, to);
        endMoveRows();
        m_modelBusy = false;
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
    application->setIconId("dash");
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
    application->setShellChrome(Mir::LowChrome);
    application->setSupportedOrientations(Qt::PortraitOrientation
                                        | Qt::LandscapeOrientation
                                        | Qt::InvertedPortraitOrientation
                                        | Qt::InvertedLandscapeOrientation);
    application->setRotatesWindowContents(true);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("camera-app2");
    application->setName("Camera2");
    application->setScreenshotId("camera");
    application->setIconId("camera");
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
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("facebook-webapp");
    application->setName("Facebook");
    application->setScreenshotId("facebook");
    application->setIconId("facebook");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("morph-browser");
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
//    application->setStage(ApplicationInfoInterface::SideStage);
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

    application = new ApplicationInfo(this);
    application->setAppId("ubuntu-terminal-app");
    application->setName("Terminal");
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("primary-oriented-app");
    application->setName("Primary Oriented");
    application->setSupportedOrientations(Qt::PrimaryOrientation);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("kate");
    application->setName("Kate");
    application->setIconId("libreoffice");
    application->setScreenshotId("libreoffice");
    application->setQmlFilename("Kate.qml");
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

QString ApplicationManager::toString()
{
    QString str;
    for (int i = 0; i < m_runningApplications.count(); ++i) {
        auto *application = m_runningApplications.at(i);

        QString itemStr = QString("(index=%1,appId=%2)")
            .arg(i)
            .arg(application->appId());

        if (i > 0) {
            str.append(",");
        }
        str.append(itemStr);
    }
    return str;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ApplicationManagerNotifier

ApplicationManagerNotifier *ApplicationManagerNotifier::m_instance = nullptr;

ApplicationManagerNotifier *ApplicationManagerNotifier::instance()
{
    if (!m_instance) {
        m_instance = new ApplicationManagerNotifier;
    }
    return m_instance;
}

void ApplicationManagerNotifier::setApplicationManager(ApplicationManager *appMan)
{
    if (appMan != m_applicationManager) {
        m_applicationManager = appMan;
        Q_EMIT applicationManagerChanged(m_applicationManager);
    }
}
