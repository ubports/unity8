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
#include "ApplicationInfo.h"

// unity-api
#include <unity/shell/application/ApplicationManagerInterface.h>

class QQuickItem;
using namespace unity::shell::application;

class ApplicationManager : public ApplicationManagerInterface {
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

    Q_PROPERTY(bool fake READ fake CONSTANT)

    // Only for testing
    // This can be used to place some controls to right, like make tryPhoneStage for example
    Q_PROPERTY(int rightMargin READ rightMargin WRITE setRightMargin)

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
        CameraApplication, GalleryApplication, BrowserApplication, ShareApplication,
        PhoneApplication, DialerApplication, MessagingApplication, AddressbookApplication
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

    bool fake() { return true; }

    // QAbstractItemModel methods.
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    Q_INVOKABLE ApplicationInfo *get(int index) const override;
    Q_INVOKABLE ApplicationInfo *findApplication(const QString &appId) const override;

    Q_INVOKABLE void move(int from, int to);

    // Application control methods
    Q_INVOKABLE bool requestFocusApplication(const QString &appId) override;
    Q_INVOKABLE bool focusApplication(const QString &appId) override;
    Q_INVOKABLE void unfocusCurrentApplication() override;
    Q_INVOKABLE ApplicationInfo *startApplication(const QString &appId, const QStringList &arguments = QStringList()) override;
    Q_INVOKABLE ApplicationInfo *startApplication(const QString &appId, ExecFlags flags, const QStringList &arguments = QStringList());
    Q_INVOKABLE bool stopApplication(const QString &appId) override;
    Q_INVOKABLE bool updateScreenshot(const QString &appId) override;

    QString focusedApplicationId() const override;
    bool suspended() const;
    void setSuspended(bool suspended);

    // Only for testing
    Q_INVOKABLE QStringList availableApplications();
    int rightMargin() const;
    void setRightMargin(int rightMargin);

 Q_SIGNALS:
    void keyboardHeightChanged();
    void keyboardVisibleChanged();
    void focusRequested(FavoriteApplication favoriteApplication);
    void focusRequested(const QString &appId);

 private:
    void add(ApplicationInfo *application);
    void remove(ApplicationInfo* application);
    void showApplicationWindow(ApplicationInfo *application);
    void buildListOfAvailableApplications();
    void generateQmlStrings(ApplicationInfo *application);
    void createMainStageComponent();
    void createMainStage();
    void createSideStageComponent();
    void createSideStage();
    int m_keyboardHeight;
    bool m_keyboardVisible;
    bool m_suspended;
    QList<ApplicationInfo*> m_runningApplications;
    QList<ApplicationInfo*> m_availableApplications;
    QQmlComponent *m_mainStageComponent;
    QQuickItem *m_mainStage;
    QQmlComponent *m_sideStageComponent;
    QQuickItem *m_sideStage;

    int m_rightMargin;
};

Q_DECLARE_OPERATORS_FOR_FLAGS(ApplicationManager::ExecFlags)

Q_DECLARE_METATYPE(ApplicationManager*)

#endif  // APPLICATION_MANAGER_H
