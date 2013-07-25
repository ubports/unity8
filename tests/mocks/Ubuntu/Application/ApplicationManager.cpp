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
#include "ApplicationInfo.h"
#include "ApplicationListModel.h"
#include "paths.h"

#include <QDir>
#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlComponent>

ApplicationManager::ApplicationManager(QObject *parent)
    : QObject(parent)
    , m_mainStageApplications(new ApplicationListModel())
    , m_sideStageApplications(new ApplicationListModel())
    , m_mainStageFocusedApplication(0)
    , m_sideStageFocusedApplication(0)
    , m_mainStageComponent(0)
    , m_mainStage(0)
    , m_sideStageComponent(0)
    , m_sideStage(0)
{
    buildListOfAvailableApplications();
}

ApplicationManager::~ApplicationManager()
{
    delete m_mainStageApplications;
    delete m_sideStageApplications;
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

ApplicationListModel* ApplicationManager::mainStageApplications() const
{
    return m_mainStageApplications;
}

ApplicationListModel* ApplicationManager::sideStageApplications() const
{
    return m_sideStageApplications;
}

ApplicationInfo* ApplicationManager::mainStageFocusedApplication() const
{
    return m_mainStageFocusedApplication;
}

ApplicationInfo* ApplicationManager::sideStageFocusedApplication() const
{
    return m_sideStageFocusedApplication;
}

ApplicationInfo* ApplicationManager::startProcess(QString desktopFile,
                                              ExecFlags flags,
                                              QStringList arguments)
{
    Q_UNUSED(arguments)
    ApplicationInfo *application = 0;

    for (int i = 0; i < m_availableApplications.count(); ++i) {
        ApplicationInfo *availableApp = m_availableApplications[i];
        if (availableApp->desktopFile() == desktopFile) {
            application = availableApp;
            break;
        }
    }

    if (!application)
        return 0;

    if (flags.testFlag(ApplicationManager::ForceMainStage)
            || application->stage() == ApplicationInfo::MainStage) {
        m_mainStageApplications->add(application);
    } else {
        m_sideStageApplications->add(application);
    }

    return application;
}

void ApplicationManager::stopProcess(ApplicationInfo* application)
{
    if (m_mainStageApplications->contains(application)) {
        m_mainStageApplications->remove(application);

        if (m_mainStageFocusedApplication == application) {
            m_mainStageFocusedApplication = 0;
            Q_EMIT mainStageFocusedApplicationChanged();
        }
    } else if (m_sideStageApplications->contains(application)){
        m_sideStageApplications->remove(application);

        if (m_sideStageFocusedApplication == application) {
            m_sideStageFocusedApplication = 0;
            Q_EMIT sideStageFocusedApplicationChanged();
        }
    }
}

void ApplicationManager::focusApplication(int handle)
{
    for (int i = 0; i < m_mainStageApplications->m_applications.count(); ++i) {
        ApplicationInfo *application = m_mainStageApplications->m_applications[i];
        if (application->handle() == handle) {
            if (m_mainStageFocusedApplication)
                m_mainStageFocusedApplication->hideWindow();
            m_mainStageFocusedApplication = application;
            if (!m_mainStage)
                createMainStage();
            application->showWindow(m_mainStage);
            m_mainStage->setZ(-1000);
            if (m_sideStage)
                m_sideStage->setZ(-2000);
            Q_EMIT mainStageFocusedApplicationChanged();
            return;
        }
    }

    for (int i = 0; i < m_sideStageApplications->m_applications.count(); ++i) {
        ApplicationInfo *application = m_sideStageApplications->m_applications[i];
        if (application->handle() == handle) {
            if (m_sideStageFocusedApplication)
                m_sideStageFocusedApplication->hideWindow();
            m_sideStageFocusedApplication = application;
            if (!m_sideStage)
                createSideStage();
            application->showWindow(m_sideStage);
            m_sideStage->setZ(-1000);
            if (m_mainStage)
                m_mainStage->setZ(-2000);
            Q_EMIT sideStageFocusedApplicationChanged();
            return;
        }
    }
}

void ApplicationManager::unfocusCurrentApplication(StageHint stageHint)
{
    if (stageHint == SideStage) {
        if (m_sideStageFocusedApplication) {
            m_sideStageFocusedApplication->hideWindow();
            m_sideStageFocusedApplication = 0;
            Q_EMIT sideStageFocusedApplicationChanged();
        }
    } else {
        if (m_mainStageFocusedApplication) {
            m_mainStageFocusedApplication->hideWindow();
            m_mainStageFocusedApplication = 0;
            Q_EMIT mainStageFocusedApplicationChanged();
        }
    }
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
        "   source: \"file://%2/Dash/graphics/phone/screenshots/%3.png\"\n"
        "   smooth: true\n"
        "   fillMode: Image.PreserveAspectCrop\n"
        "}").arg(topMargin)
            .arg(shellAppDirectory())
            .arg(application->icon());
    application->setWindowQml(windowQml);

    QString imageQml = QString(
        "import QtQuick 2.0\n"
        "Image {\n"
        "   anchors.fill: parent\n"
        "   source: \"file://%1/Dash/graphics/phone/screenshots/%2.png\"\n"
        "   smooth: true\n"
        "   fillMode: Image.PreserveAspectCrop\n"
        "}").arg(shellAppDirectory())
            .arg(application->icon());
    application->setImageQml(imageQml);
}

void ApplicationManager::buildListOfAvailableApplications()
{
    ApplicationInfo *application;
    qint64 nextHandle = 1;

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/phone-app.desktop");
    application->setName("Phone");
    application->setIcon("phone");
    application->setExec("/usr/bin/phone-app");
    application->setStage(ApplicationInfo::SideStage);
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/camera-app.desktop");
    application->setName("Camera");
    application->setIcon("camera");
    application->setFullscreen(true);
    application->setExec("/usr/bin/camera-app --fullscreen");
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/gallery-app.desktop");
    application->setName("Gallery");
    application->setIcon("gallery");
    application->setExec("/usr/bin/gallery-app");
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/facebook-webapp.desktop");
    application->setName("Facebook");
    application->setIcon("facebook");
    application->setExec("/usr/bin/webbrowser-app --chromeless http://m.facebook.com");
    application->setStage(ApplicationInfo::SideStage);
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/webbrowser-app.desktop");
    application->setName("Browser");
    application->setIcon("browser");
    application->setExec("/usr/bin/webbrowser-app");
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/twitter-webapp.desktop");
    application->setName("Twitter");
    application->setIcon("twitter");
    application->setExec("/usr/bin/webbrowser-app --chromeless http://www.twitter.com");
    application->setStage(ApplicationInfo::SideStage);
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/gmail-webapp.desktop");
    application->setName("GMail");
    application->setIcon("gmail");
    application->setExec("/usr/bin/webbrowser-app --chromeless http://m.gmail.com");
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/ubuntu-weather-app.desktop");
    application->setName("Weather");
    application->setIcon("weather");
    application->setExec("/usr/bin/qmlscene /usr/share/ubuntu-weather-app/ubuntu-weather-app.qml");
    application->setStage(ApplicationInfo::SideStage);
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/notes-app.desktop");
    application->setName("Notepad");
    application->setIcon("notepad");
    application->setExec("/usr/bin/qmlscene /usr/share/notes-app/NotesApp.qml");
    application->setStage(ApplicationInfo::SideStage);
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/calendar-app.desktop");
    application->setName("Calendar");
    application->setIcon("calendar");
    application->setExec("/usr/bin/qmlscene /usr/share/calendar-app/calendar.qml");
    application->setStage(ApplicationInfo::SideStage);
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/mediaplayer-app.desktop");
    application->setName("Media Player");
    application->setIcon("mediaplayer-app");
    application->setFullscreen(true);
    application->setExec("/usr/bin/mediaplayer-app");
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/evernote.desktop");
    application->setName("Evernote");
    application->setIcon("evernote");
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/map.desktop");
    application->setName("Map");
    application->setIcon("map");
    application->setHandle(nextHandle++);
    generateQmlStrings(application);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/pinterest.desktop");
    application->setName("Pinterest");
    application->setIcon("pinterest");
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/soundcloud.desktop");
    application->setName("SoundCloud");
    application->setIcon("soundcloud");
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/wikipedia.desktop");
    application->setName("Wikipedia");
    application->setIcon("wikipedia");
    application->setHandle(nextHandle++);
    m_availableApplications.append(application);

    application = new ApplicationInfo(this);
    application->setDesktopFile("/usr/share/applications/youtube.desktop");
    application->setName("YouTube");
    application->setIcon("youtube");
    application->setHandle(nextHandle++);
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
