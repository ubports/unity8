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

#ifndef APPLICATION_MANAGER_H
#define APPLICATION_MANAGER_H

#include <QObject>
#include <QList>
#include <QStringList>
#include <QTimer>
#include "ApplicationInfo.h"

// unity-api
#include <unity/shell/application/ApplicationManagerInterface.h>

namespace unity {
    namespace shell {
        namespace application {
            class MirSurfaceInterface;
        }
    }
}

class QQuickItem;
using namespace unity::shell::application;

class ApplicationManager : public ApplicationManagerInterface {
    Q_OBJECT

    Q_PROPERTY(QStringList availableApplications READ availableApplications NOTIFY availableApplicationsChanged)

 public:
    ApplicationManager(QObject *parent = nullptr);
    virtual ~ApplicationManager();

    // QAbstractItemModel methods.
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;

    // ApplicationManagerInterface methods
    Q_INVOKABLE ApplicationInfo *get(int index) const override;
    Q_INVOKABLE ApplicationInfo *findApplication(const QString &appId) const override;
    unity::shell::application::ApplicationInfoInterface *findApplicationWithSurface(unity::shell::application::MirSurfaceInterface* surface) const override;

    // Application control methods
    Q_INVOKABLE bool requestFocusApplication(const QString &appId) override;
    Q_INVOKABLE ApplicationInfo *startApplication(const QString &appId, const QStringList &arguments = QStringList()) override;
    Q_INVOKABLE bool stopApplication(const QString &appId) override;

    QString focusedApplicationId() const override;

    // Only for testing
    QStringList availableApplications();
    Q_INVOKABLE ApplicationInfo* add(QString appId);

    QModelIndex findIndex(ApplicationInfo* application);

 Q_SIGNALS:
    void focusRequested(const QString &appId);
    void availableApplicationsChanged(QStringList list);

 private Q_SLOTS:
    void raiseApp(const QString &appId);

 private:
    void move(int from, int to);
    bool add(ApplicationInfo *application);
    void remove(ApplicationInfo* application);
    void buildListOfAvailableApplications();
    QString toString();
    ApplicationInfo *findApplication(MirSurface* surface);
    QList<ApplicationInfo*> m_runningApplications;
    QList<ApplicationInfo*> m_availableApplications;
    bool m_modelBusy{false};
};

/*
    Lifecycle of the ApplicationManager instance belongs to the QML plugin.
    So this guy here is used to notify other parts of the system when the plugin creates and destroys
    the ApplicationManager.

    Unlike ApplicationManager, we create ApplicationManagerNotifier whenever we want.
 */
class ApplicationManagerNotifier : public QObject {
    Q_OBJECT
public:
    static ApplicationManagerNotifier *instance();

    ApplicationManager *applicationManager() { return m_applicationManager; }

Q_SIGNALS:
    void applicationManagerChanged(ApplicationManager *applicationManager);

private:
    void setApplicationManager(ApplicationManager *);
    static ApplicationManagerNotifier *m_instance;
    ApplicationManager *m_applicationManager{nullptr};

friend class ApplicationManager;
};

Q_DECLARE_METATYPE(ApplicationManager*)

#endif  // APPLICATION_MANAGER_H
