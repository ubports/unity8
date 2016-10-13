/*
 * Copyright (C) 2013, 2015 Canonical, Ltd.
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

#ifndef UNITY_MOCK_ACCOUNTSSERVICE_H
#define UNITY_MOCK_ACCOUNTSSERVICE_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariant>

class MockUsersModel;

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
    Q_PROPERTY (QStringList demoEdgesCompleted
                READ demoEdgesCompleted
                WRITE setDemoEdgesCompleted // only available in mock
                NOTIFY demoEdgesCompletedChanged)
    Q_PROPERTY (bool enableFingerprintIdentification
                READ enableFingerprintIdentification
                WRITE setEnableFingerprintIdentification // only available in mock
                NOTIFY enableFingerprintIdentificationChanged)
    Q_PROPERTY (bool enableLauncherWhileLocked
                READ enableLauncherWhileLocked
                WRITE setEnableLauncherWhileLocked // only available in mock
                NOTIFY enableLauncherWhileLockedChanged)
    Q_PROPERTY (bool enableIndicatorsWhileLocked
                READ enableIndicatorsWhileLocked
                WRITE setEnableIndicatorsWhileLocked // only available in mock
                NOTIFY enableIndicatorsWhileLockedChanged)
    Q_PROPERTY (QString backgroundFile
                READ backgroundFile
                WRITE setBackgroundFile // only available in mock
                NOTIFY backgroundFileChanged)
    Q_PROPERTY (bool statsWelcomeScreen
                READ statsWelcomeScreen
                WRITE setStatsWelcomeScreen // only available in mock
                NOTIFY statsWelcomeScreenChanged)
    Q_PROPERTY (PasswordDisplayHint passwordDisplayHint
                READ passwordDisplayHint
                NOTIFY passwordDisplayHintChanged)
    Q_PROPERTY (uint failedLogins
                READ failedLogins
                WRITE setFailedLogins
                NOTIFY failedLoginsChanged)
    Q_PROPERTY (uint failedFingerprintLogins
                READ failedFingerprintLogins
                WRITE setFailedFingerprintLogins
                NOTIFY failedFingerprintLoginsChanged)
    Q_PROPERTY(bool hereEnabled
               READ hereEnabled
               WRITE setHereEnabled
               NOTIFY hereEnabledChanged)
    Q_PROPERTY(QString hereLicensePath
               READ hereLicensePath
               WRITE setHereLicensePath // only available in mock
               NOTIFY hereLicensePathChanged)
    Q_PROPERTY(bool hereLicensePathValid // qml sees a null string as "", so we use proxy setting for that
               READ hereLicensePathValid
               NOTIFY hereLicensePathChanged)
    Q_PROPERTY(QString realName READ realName WRITE setRealName NOTIFY realNameChanged)
    Q_PROPERTY(QString email READ email WRITE setEmail NOTIFY emailChanged)
    Q_PROPERTY(QStringList keymaps
               READ keymaps
               WRITE setKeymaps
               NOTIFY keymapsChanged)

public:
    enum PasswordDisplayHint {
        Keyboard,
        Numeric
    };

    explicit AccountsService(QObject *parent = 0);

    QString user() const;
    void setUser(const QString &user);
    bool demoEdges() const;
    void setDemoEdges(bool demoEdges);
    QStringList demoEdgesCompleted() const;
    void setDemoEdgesCompleted(const QStringList &demoEdges);
    Q_INVOKABLE void markDemoEdgeCompleted(const QString &edge);
    bool enableFingerprintIdentification() const;
    void setEnableFingerprintIdentification(bool enableFingerprintIdentification);
    bool enableLauncherWhileLocked() const;
    void setEnableLauncherWhileLocked(bool enableLauncherWhileLocked);
    bool enableIndicatorsWhileLocked() const;
    void setEnableIndicatorsWhileLocked(bool enableIndicatorsWhileLocked);
    QString backgroundFile() const;
    void setBackgroundFile(const QString &backgroundFile);
    bool statsWelcomeScreen() const;
    void setStatsWelcomeScreen(bool statsWelcomeScreen);
    PasswordDisplayHint passwordDisplayHint() const;
    uint failedLogins() const;
    void setFailedLogins(uint failedLogins);
    uint failedFingerprintLogins() const;
    void setFailedFingerprintLogins(uint failedFingerprintLogins);
    bool hereEnabled() const;
    void setHereEnabled(bool enabled);
    QString hereLicensePath() const;
    void setHereLicensePath(const QString &path);
    bool hereLicensePathValid() const;
    QString realName() const;
    void setRealName(const QString &realName);
    QString email() const;
    void setEmail(const QString &email);
    QStringList keymaps() const;
    void setKeymaps(const QStringList &keymaps);

Q_SIGNALS:
    void userChanged();
    void demoEdgesChanged();
    void demoEdgesCompletedChanged();
    void enableFingerprintIdentificationChanged();
    void enableLauncherWhileLockedChanged();
    void enableIndicatorsWhileLockedChanged();
    void backgroundFileChanged();
    void statsWelcomeScreenChanged();
    void passwordDisplayHintChanged();
    void failedLoginsChanged();
    void failedFingerprintLoginsChanged();
    void hereEnabledChanged();
    void hereLicensePathChanged();
    void realNameChanged();
    void emailChanged();
    void keymapsChanged();

private:
    bool m_enableFingerprintIdentification;
    bool m_enableLauncherWhileLocked;
    bool m_enableIndicatorsWhileLocked;
    QString m_backgroundFile;
    QString m_user;
    bool m_statsWelcomeScreen;
    uint m_failedLogins;
    uint m_failedFingerprintLogins;
    bool m_demoEdges;
    QStringList m_demoEdgesCompleted;
    bool m_hereEnabled;
    QString m_hereLicensePath;
    QString m_realName;
    QStringList m_kbdMap;
    QString m_email;
    MockUsersModel *m_usersModel;
};

#endif
