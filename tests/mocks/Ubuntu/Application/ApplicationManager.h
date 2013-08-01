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

#ifndef APPLICATION_MANAGER_H
#define APPLICATION_MANAGER_H

#include <QObject>
#include <QList>
#include <QStringList>
#include "ApplicationListModel.h"
#include "ApplicationInfo.h"

class QQuickItem;

class ApplicationManager : public QObject {
    Q_OBJECT
    Q_ENUMS(Role)
    Q_ENUMS(StageHint)
    Q_ENUMS(FormFactorHint)
    Q_ENUMS(FavoriteApplication)
    Q_FLAGS(ExecFlags)

    Q_PROPERTY(int keyboardHeight READ keyboardHeight NOTIFY keyboardHeightChanged)
    Q_PROPERTY(bool keyboardVisible READ keyboardVisible NOTIFY keyboardVisibleChanged)

    Q_PROPERTY(int sideStageWidth READ sideStageWidth)
    Q_PROPERTY(StageHint stageHint READ stageHint)
    Q_PROPERTY(FormFactorHint formFactorHint READ formFactorHint)
    Q_PROPERTY(ApplicationListModel* mainStageApplications READ mainStageApplications)
    Q_PROPERTY(ApplicationListModel* sideStageApplications READ sideStageApplications)
    Q_PROPERTY(ApplicationInfo* mainStageFocusedApplication READ mainStageFocusedApplication
               NOTIFY mainStageFocusedApplicationChanged)
    Q_PROPERTY(ApplicationInfo* sideStageFocusedApplication READ sideStageFocusedApplication
               NOTIFY sideStageFocusedApplicationChanged)

    Q_PROPERTY(bool fake READ fake CONSTANT)

 public:
    ApplicationManager(QObject *parent = NULL);
    virtual ~ApplicationManager();

    enum Role {
        Dash, Default, Indicators, Notifications, Greeter, Launcher, OnScreenKeyboard,
        ShutdownDialog
    };
    enum StageHint {
        MainStage, IntegrationStage, ShareStage, ContentPickingStage,
        SideStage, ConfigurationStage
    };
    enum FormFactorHint {
        DesktopFormFactor, PhoneFormFactor, TabletFormFactor
    };
    enum FavoriteApplication {
        CameraApplication, GalleryApplication, BrowserApplication, ShareApplication
    };
    enum Flag {
        NoFlag = 0x0,
        ForceMainStage = 0x1,
    };
    Q_DECLARE_FLAGS(ExecFlags, Flag)

    int keyboardHeight() const;
    bool keyboardVisible() const;
    int sideStageWidth() const;
    StageHint stageHint() const;
    FormFactorHint formFactorHint() const;
    ApplicationListModel* mainStageApplications() const;
    ApplicationListModel* sideStageApplications() const;
    ApplicationInfo* mainStageFocusedApplication() const;
    ApplicationInfo* sideStageFocusedApplication() const;

    bool fake() { return true; }

    Q_INVOKABLE void focusApplication(int handle);
    Q_INVOKABLE void unfocusCurrentApplication(StageHint stageHint);
    Q_INVOKABLE ApplicationInfo* startProcess(QString desktopFile,
                                        ExecFlags flags,
                                        QStringList arguments = QStringList());
    Q_INVOKABLE void stopProcess(ApplicationInfo* application);
    Q_INVOKABLE void startWatcher() {}

 Q_SIGNALS:
    void keyboardHeightChanged();
    void keyboardVisibleChanged();
    void mainStageFocusedApplicationChanged();
    void sideStageFocusedApplicationChanged();
    void focusRequested(FavoriteApplication favoriteApplication);

 private:
    void showApplicationWindow(ApplicationInfo *application);
    void buildListOfAvailableApplications();
    void generateQmlStrings(ApplicationInfo *application);
    void createMainStageComponent();
    void createMainStage();
    void createSideStageComponent();
    void createSideStage();
    int m_keyboardHeight;
    bool m_keyboardVisible;
    ApplicationListModel* m_mainStageApplications;
    ApplicationListModel* m_sideStageApplications;
    ApplicationInfo* m_mainStageFocusedApplication;
    ApplicationInfo* m_sideStageFocusedApplication;
    QList<ApplicationInfo*> m_availableApplications;
    QQmlComponent *m_mainStageComponent;
    QQuickItem *m_mainStage;
    QQmlComponent *m_sideStageComponent;
    QQuickItem *m_sideStage;
};

Q_DECLARE_OPERATORS_FOR_FLAGS(ApplicationManager::ExecFlags)

Q_DECLARE_METATYPE(ApplicationManager*)

#endif  // APPLICATION_MANAGER_H
