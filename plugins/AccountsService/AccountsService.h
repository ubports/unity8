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
 *
 * Authors: Michael Terry <michael.terry@canonical.com>
 */

#ifndef UNITY_ACCOUNTSSERVICE_H
#define UNITY_ACCOUNTSSERVICE_H

#include <QObject>
#include <QString>

class AccountsServiceDBusAdaptor;

class AccountsService: public QObject
{
    Q_OBJECT
    Q_ENUMS(PasswordDisplayHint)
    Q_PROPERTY (QString user
                READ user
                WRITE setUser
                NOTIFY userChanged)
    Q_PROPERTY (bool demoEdges
                READ demoEdges
                WRITE setDemoEdges
                NOTIFY demoEdgesChanged)
    Q_PROPERTY (bool enableLauncherWhileLocked
                READ enableLauncherWhileLocked
                NOTIFY enableLauncherWhileLockedChanged)
    Q_PROPERTY (bool enableIndicatorsWhileLocked
                READ enableIndicatorsWhileLocked
                NOTIFY enableIndicatorsWhileLockedChanged)
    Q_PROPERTY (QString backgroundFile
                READ backgroundFile
                NOTIFY backgroundFileChanged)
    Q_PROPERTY (bool statsWelcomeScreen
                READ statsWelcomeScreen
                NOTIFY statsWelcomeScreenChanged)
    Q_PROPERTY (PasswordDisplayHint passwordDisplayHint
                READ passwordDisplayHint
                NOTIFY passwordDisplayHintChanged)
    Q_PROPERTY (uint failedLogins
                READ failedLogins
                WRITE setFailedLogins
                NOTIFY failedLoginsChanged)
    Q_PROPERTY(bool hereEnabled
               READ hereEnabled
               WRITE setHereEnabled
               NOTIFY hereEnabledChanged)
    Q_PROPERTY(QString hereLicensePath
               READ hereLicensePath
               NOTIFY hereLicensePathChanged)

public:
    enum PasswordDisplayHint {
        Keyboard,
        Numeric,
    };

    explicit AccountsService(QObject *parent = 0);

    QString user() const;
    void setUser(const QString &user);
    bool demoEdges() const;
    void setDemoEdges(bool demoEdges);
    bool enableLauncherWhileLocked() const;
    bool enableIndicatorsWhileLocked() const;
    QString backgroundFile() const;
    bool statsWelcomeScreen() const;
    PasswordDisplayHint passwordDisplayHint() const;
    uint failedLogins() const;
    void setFailedLogins(uint failedLogins);
    bool hereEnabled() const;
    void setHereEnabled(bool enabled);
    QString hereLicensePath() const;

Q_SIGNALS:
    void userChanged();
    void demoEdgesChanged();
    void enableLauncherWhileLockedChanged();
    void enableIndicatorsWhileLockedChanged();
    void backgroundFileChanged();
    void statsWelcomeScreenChanged();
    void passwordDisplayHintChanged();
    void failedLoginsChanged();
    void hereEnabledChanged();
    void hereLicensePathChanged();

private Q_SLOTS:
    void propertiesChanged(const QString &user, const QString &interface, const QStringList &changed);
    void maybeChanged(const QString &user);

private:
    void updateDemoEdges();
    void updateEnableLauncherWhileLocked();
    void updateEnableIndicatorsWhileLocked();
    void updateBackgroundFile();
    void updateStatsWelcomeScreen();
    void updatePasswordDisplayHint();
    void updateFailedLogins();
    void updateHereEnabled();
    void updateHereLicensePath();

    AccountsServiceDBusAdaptor *m_service;
    QString m_user;
    bool m_demoEdges;
    bool m_enableLauncherWhileLocked;
    bool m_enableIndicatorsWhileLocked;
    QString m_backgroundFile;
    bool m_statsWelcomeScreen;
    PasswordDisplayHint m_passwordDisplayHint;
    uint m_failedLogins;
    bool m_hereEnabled;
    QString m_hereLicensePath;
};

#endif
