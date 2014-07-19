/*
 * Copyright (C) 2013 Canonical, Ltd.
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
#include "ApplicationDBusAdaptor.h"
#include "ApplicationInfo.h"
#include "MirSurfaceItem.h"

#include <paths.h>

#include <QDir>
#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>
#include <QTimer>
#include <QDateTime>
#include <QtDBus/QtDBus>

ApplicationManager *ApplicationManager::the_application_manager = nullptr;

ApplicationManager *ApplicationManager::singleton()
{
    if (!the_application_manager) {
        the_application_manager = new ApplicationManager();
        new ApplicationDBusAdaptor(the_application_manager);

        QDBusConnection connection = QDBusConnection::sessionBus();
        connection.registerService("com.canonical.Unity8");
        connection.registerObject("/com/canonical/Unity8/Mocks", the_application_manager);
    }
    return the_application_manager;
}

ApplicationManager::ApplicationManager(QObject *parent)
    : ApplicationManagerInterface(parent)
    , m_suspended(false)
    , m_mainStageComponent(0)
    , m_mainStage(0)
    , m_sideStageComponent(0)
    , m_sideStage(0)
    , m_rightMargin(0)
{
    m_roleNames.insert(RoleSurface, "surface");
    m_roleNames.insert(RoleFullscreen, "fullscreen");

    buildListOfAvailableApplications();
}

ApplicationManager::~ApplicationManager()
{
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
    case RoleScreenshot:
        return app->screenshot();
    case RoleSurface:
        return QVariant::fromValue(app->surface());
    case RoleFullscreen:
        return app->fullscreen();
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

void ApplicationManager::add(ApplicationInfo *application) {
    if (!application) {
        return;
    }

    beginInsertRows(QModelIndex(), m_runningApplications.size(), m_runningApplications.size());
    m_runningApplications.append(application);
    endInsertRows();
    Q_EMIT applicationAdded(application->appId());
    Q_EMIT countChanged();
    Q_EMIT focusRequested(application->appId());

    connect(application, &ApplicationInfo::surfaceChanged, this, [application, this]() {
        QModelIndex appIndex = findIndex(application);
        if (!appIndex.isValid()) return;
        Q_EMIT dataChanged(appIndex, appIndex, QVector<int>() << ApplicationManager::RoleSurface);
    });
}

void ApplicationManager::remove(ApplicationInfo *application) {
    int i = m_runningApplications.indexOf(application);
    if (i != -1) {
        beginRemoveRows(QModelIndex(), i, i);
        m_runningApplications.removeAt(i);
        endRemoveRows();
        Q_EMIT applicationRemoved(application->appId());
        Q_EMIT countChanged();
    }
    disconnect(application, &ApplicationInfo::surfaceChanged, this, 0);
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

int ApplicationManager::keyboardHeight() const
{
    return 0;
}

bool ApplicationManager::keyboardVisible() const
{
    return false;
}

int ApplicationManager::sideStageWidth() const
{
    return 0;
}

ApplicationManager::StageHint ApplicationManager::stageHint() const
{
    return MainStage;
}

ApplicationManager::FormFactorHint ApplicationManager::formFactorHint() const
{
    return PhoneFormFactor;
}

ApplicationInfo* ApplicationManager::startApplication(const QString &appId,
                                              const QStringList &arguments)
{
    return startApplication(appId, NoFlag, arguments);
}

ApplicationInfo* ApplicationManager::startApplication(const QString &appId,
                                              ExecFlags flags,
                                              const QStringList &arguments)
{
    Q_UNUSED(arguments)
    ApplicationInfo *application = 0;

    for (ApplicationInfo *availableApp : m_availableApplications) {
        if (availableApp->appId() == appId) {
            application = availableApp;
            break;
        }
    }

    if (!application)
        return 0;

    if (flags.testFlag(ApplicationManager::ForceMainStage)
            && application->stage() == ApplicationInfo::SideStage) {
        application->setStage(ApplicationInfo::MainStage);
    }
    add(application);
    application->setState(ApplicationInfo::Running);

    return application;
}

bool ApplicationManager::stopApplication(const QString &appId)
{
    ApplicationInfo *application = findApplication(appId);
    if (application == nullptr)
        return false;

    if (application->appId() == focusedApplicationId()) {
        unfocusCurrentApplication();
    }
    application->setState(ApplicationInfo::Stopped);
    remove(application);
    return true;
}

bool ApplicationManager::updateScreenshot(const QString &appId)
{
    int idx = -1;
    ApplicationInfo *application = nullptr;
    for (int i = 0; i < m_availableApplications.count(); ++i) {
        application = m_availableApplications.at(i);
        if (application->appId() == appId) {
            idx = i;
            break;
        }
    }

    if (idx == -1) {
        return false;
    }

    QModelIndex appIndex = index(idx);
    Q_EMIT dataChanged(appIndex, appIndex, QVector<int>() << RoleScreenshot);
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

bool ApplicationManager::suspended() const
{
    return m_suspended;
}

void ApplicationManager::setSuspended(bool suspended)
{
    ApplicationInfo *focusedApp = findApplication(focusedApplicationId());
    if (focusedApp) {
        if (suspended) {
            focusedApp->setState(ApplicationInfo::Suspended);
        } else {
            focusedApp->setState(ApplicationInfo::Running);
        }
    }
    m_suspended = suspended;
    Q_EMIT suspendedChanged();
}

bool ApplicationManager::focusApplication(const QString &appId)
{
    ApplicationInfo *application = findApplication(appId);
    if (application == nullptr)
        return false;

    if (application->stage() == ApplicationInfo::MainStage) {
        // unfocus currently focused mainstage app
        for (ApplicationInfo *app : m_runningApplications) {
            if (app->focused() && app->stage() == ApplicationInfo::MainStage) {
                app->setFocused(false);
                app->hideWindow();
            }
        }

        // focus this app
        application->setFocused(true);
        if (!m_mainStage)
            createMainStage();
        application->showWindow(m_mainStage);
        m_mainStage->setZ(-1000);
        if (m_sideStage)
            m_sideStage->setZ(-2000);
    } else if (application->stage() == ApplicationInfo::SideStage) {
        // unfocus currently focused sidestage app
        for (ApplicationInfo *app : m_runningApplications) {
            if (app->focused() && app->stage() == ApplicationInfo::SideStage) {
                app->setFocused(false);
                app->hideWindow();
            }
        }

        // focus this app
        application->setFocused(true);
        if (!m_sideStage)
            createSideStage();
        application->showWindow(m_sideStage);
        m_sideStage->setZ(-1000);
        if (m_mainStage)
            m_mainStage->setZ(-2000);
    }

    // move app to top of stack
    move(m_runningApplications.indexOf(application), 0);
    Q_EMIT focusedApplicationIdChanged();
    return true;
}

bool ApplicationManager::requestFocusApplication(const QString &appId)
{
    if (appId != focusedApplicationId()) {
        QMetaObject::invokeMethod(this, "focusRequested", Qt::QueuedConnection, Q_ARG(QString, appId));
        return true;
    }
    return false;
}

void ApplicationManager::unfocusCurrentApplication()
{
    for (ApplicationInfo *app : m_runningApplications) {
        if (app->focused()) {
            app->hideWindow();
            app->setFocused(false);
        }
    }
    Q_EMIT focusedApplicationIdChanged();
}

void ApplicationManager::generateQmlStrings(ApplicationInfo *application)
{
    // TODO: Is there a better way of solving this fullscreen vs. regular
    //       application height?
    QString topMargin;
    if (application->fullscreen()) {
        topMargin.append("0");
    } else {
        // Taken from Panel.panelHeight
        topMargin.append("units.gu(3) + units.dp(2)");
    }

    QString windowQml = QString(
        "import QtQuick 2.0\n"
        "Image {\n"
        "   anchors.fill: parent\n"
        "   anchors.topMargin: %1\n"
        "   anchors.rightMargin: %2\n"
        "   source: \"file://%3/Dash/graphics/phone/screenshots/%4.png\"\n"
        "   smooth: true\n"
        "   fillMode: Image.PreserveAspectCrop\n"
        "}").arg(topMargin)
            .arg(m_rightMargin)
            .arg(qmlDirectory())
            .arg(application->icon().toString());
    application->setWindowQml(windowQml);

    QString imageQml = QString(
        "import QtQuick 2.0\n"
        "Image {\n"
        "   anchors.fill: parent\n"
        "   source: \"file://%1/Dash/graphics/phone/screenshots/%2.png\"\n"
        "   smooth: true\n"
        "   fillMode: Image.PreserveAspectCrop\n"
        "}").arg(qmlDirectory())
            .arg(application->icon().toString());
    application->setImageQml(imageQml);

    application->setScreenshot(QString("file://%1/Dash/graphics/phone/screenshots/%2@12.png").arg(qmlDirectory())
                                                                                             .arg(application->icon().toString()));
}

void ApplicationManager::buildListOfAvailableApplications()
{
    ApplicationInfo *application;

    application = new ApplicationInfo(this);
    application->setAppId("dialer-app");
    application->setName("Dialer");
    application->setIcon(QUrl("dialer"));
    application->setStage(ApplicationInfo::SideStage);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("camera-app");
    application->setName("Camera");
    application->setIcon(QUrl("camera"));
    application->setFullscreen(true);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("gallery-app");
    application->setName("Gallery");
    application->setIcon(QUrl("gallery"));
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("facebook-webapp");
    application->setName("Facebook");
    application->setIcon(QUrl("facebook"));
    application->setStage(ApplicationInfo::SideStage);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("webbrowser-app");
    application->setFullscreen(true);
    application->setName("Browser");
    application->setIcon(QUrl("browser"));
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("twitter-webapp");
    application->setName("Twitter");
    application->setIcon(QUrl("twitter"));
    application->setStage(ApplicationInfo::SideStage);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("gmail-webapp");
    application->setName("GMail");
    application->setIcon(QUrl("gmail"));
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("ubuntu-weather-app");
    application->setName("Weather");
    application->setIcon(QUrl("weather"));
    application->setStage(ApplicationInfo::SideStage);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("notes-app");
    application->setName("Notepad");
    application->setIcon(QUrl("notepad"));
    application->setStage(ApplicationInfo::SideStage);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("calendar-app");
    application->setName("Calendar");
    application->setIcon(QUrl("calendar"));
    application->setStage(ApplicationInfo::SideStage);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("mediaplayer-app");
    application->setName("Media Player");
    application->setIcon(QUrl("mediaplayer-app"));
    application->setFullscreen(true);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("evernote");
    application->setName("Evernote");
    application->setIcon(QUrl("evernote"));
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("map");
    application->setName("Map");
    application->setIcon(QUrl("map"));
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("pinterest");
    application->setName("Pinterest");
    application->setIcon(QUrl("pinterest"));
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("soundcloud");
    application->setName("SoundCloud");
    application->setIcon(QUrl("soundcloud"));
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("wikipedia");
    application->setName("Wikipedia");
    application->setIcon(QUrl("wikipedia"));
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setAppId("youtube");
    application->setName("YouTube");
    application->setIcon(QUrl("youtube"));
    m_availableApplications.append(application);
}

void ApplicationManager::createMainStageComponent()
{
    // The assumptions I make here really should hold.
    QQuickView *quickView =
        qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

    QQmlEngine *engine = quickView->engine();

    m_mainStageComponent = new QQmlComponent(engine, this);
    QString mainStageQml =
        "import QtQuick 2.0\n"
        "Rectangle {\n"
        "   anchors.fill: parent\n"
        "   color: 'black'\n"
        "   z: -2000\n"
        "}\n";
    m_mainStageComponent->setData(mainStageQml.toLatin1(), QUrl());
}

void ApplicationManager::createMainStage()
{
    if (!m_mainStageComponent)
        createMainStageComponent();

    // The assumptions I make here really should hold.
    QQuickView *quickView =
        qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

    QQuickItem *shell = quickView->rootObject();

    m_mainStage = qobject_cast<QQuickItem *>(m_mainStageComponent->create());
    m_mainStage->setParentItem(shell);
}

void ApplicationManager::createSideStageComponent()
{
    // The assumptions I make here really should hold.
    QQuickView *quickView =
        qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

    QQmlEngine *engine = quickView->engine();

    m_sideStageComponent = new QQmlComponent(engine, this);
    QString sideStageQml =
        "import QtQuick 2.0\n"
        "import Ubuntu.Components 0.1\n"
        "Item {\n"
        "   width: units.gu(40)\n" // from SideStage in Shell.qml
        "   anchors.top: parent.top\n"
        "   anchors.bottom: parent.bottom\n"
        "   anchors.right: parent.right\n"
        "   z: -1000\n"
        "}\n";
    m_sideStageComponent->setData(sideStageQml.toLatin1(), QUrl());
}

void ApplicationManager::createSideStage()
{
    if (!m_sideStageComponent)
        createSideStageComponent();

    // The assumptions I make here really should hold.
    QQuickView *quickView =
        qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

    QQuickItem *shell = quickView->rootObject();

    m_sideStage = qobject_cast<QQuickItem *>(m_sideStageComponent->create());
    m_sideStage->setParentItem(shell);
    m_sideStage->setFlag(QQuickItem::ItemHasContents, false);
}

QStringList ApplicationManager::availableApplications()
{
    QStringList appIds;
    Q_FOREACH(ApplicationInfo *app, m_availableApplications) {
        appIds << app->appId();
    }
    return appIds;
}

int ApplicationManager::rightMargin() const
{
    return m_rightMargin;
}

void ApplicationManager::setRightMargin(int rightMargin)
{
    m_rightMargin = rightMargin;
    Q_FOREACH(ApplicationInfo *app, m_availableApplications) {
        generateQmlStrings(app);
    }
}
