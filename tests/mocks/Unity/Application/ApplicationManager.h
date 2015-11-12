/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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
#include <QTimer>
#include "ApplicationInfo.h"

// unity-api
#include <unity/shell/application/ApplicationManagerInterface.h>

class QQuickItem;
using namespace unity::shell::application;

class ApplicationManager : public ApplicationManagerInterface {
    Q_OBJECT
    Q_FLAGS(ExecFlags)

    Q_PROPERTY(bool empty READ isEmpty NOTIFY emptyChanged)
    Q_PROPERTY(QStringList availableApplications READ availableApplications NOTIFY availableApplicationsChanged)

 public:
    ApplicationManager(QObject *parent = nullptr);
    virtual ~ApplicationManager();

    static ApplicationManager *singleton();

    enum MoreRoles {
        RoleSession = RoleIsTouchApp+1,
        RoleFullscreen,
    };
    enum Flag {
        NoFlag = 0x0,
        ForceMainStage = 0x1,
    };
    Q_DECLARE_FLAGS(ExecFlags, Flag)

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

    QString focusedApplicationId() const override;

    // Only for testing
    QStringList availableApplications();
    Q_INVOKABLE ApplicationInfo* add(QString appId);

    QModelIndex findIndex(ApplicationInfo* application);

    bool isEmpty() const;

 Q_SIGNALS:
    void focusRequested(const QString &appId);
    void emptyChanged(bool empty);
    void availableApplicationsChanged(QStringList list);

 private Q_SLOTS:
    void onWindowCreatedTimerTimeout();

 private:
    void add(ApplicationInfo *application);
    void remove(ApplicationInfo* application);
    void buildListOfAvailableApplications();
    void onWindowCreated();
    QList<ApplicationInfo*> m_runningApplications;
    QList<ApplicationInfo*> m_availableApplications;
    QTimer m_windowCreatedTimer;

    static ApplicationManager *the_application_manager;
};

Q_DECLARE_OPERATORS_FOR_FLAGS(ApplicationManager::ExecFlags)

Q_DECLARE_METATYPE(ApplicationManager*)

#endif  // APPLICATION_MANAGER_H
