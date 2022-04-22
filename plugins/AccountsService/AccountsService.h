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

#ifndef UNITY_ACCOUNTSSERVICE_H
#define UNITY_ACCOUNTSSERVICE_H

#include <QHash>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariant>

class AccountsServiceDBusAdaptor;
class QDBusInterface;

class AccountsService: public QObject
{
    Q_OBJECT
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
                NOTIFY demoEdgesCompletedChanged)
    Q_PROPERTY (bool enableFingerprintIdentification
                READ enableFingerprintIdentification
                NOTIFY enableFingerprintIdentificationChanged)
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
    Q_PROPERTY(QString pinCodePromptManager READ pinCodePromptManager NOTIFY pinCodePromptManagerChanged)
    Q_PROPERTY(QString defaultPinCodePromptManager READ defaultPinCodePromptManager CONSTANT)
    Q_PROPERTY (uint failedLogins
                READ failedLogins
                WRITE setFailedLogins
                NOTIFY failedLoginsChanged)
    Q_PROPERTY (uint failedFingerprintLogins
                READ failedFingerprintLogins
                WRITE setFailedFingerprintLogins
                NOTIFY failedFingerprintLoginsChanged)
    Q_PROPERTY(QString realName READ realName WRITE setRealName NOTIFY realNameChanged)
    Q_PROPERTY(QString email READ email WRITE setEmail NOTIFY emailChanged)
    Q_PROPERTY(QStringList keymaps READ keymaps WRITE setKeymaps NOTIFY keymapsChanged)

public:
    enum PasswordDisplayHint {
        Keyboard,
        Numeric,
    };
    Q_ENUM(PasswordDisplayHint)

    explicit AccountsService(QObject *parent = 0, const QString & user = QString());
    ~AccountsService() = default;

    QString user() const;
    void setUser(const QString &user);
    bool demoEdges() const;
    void setDemoEdges(bool demoEdges);
    QStringList demoEdgesCompleted() const;
    Q_INVOKABLE void markDemoEdgeCompleted(const QString &edge);
    bool enableFingerprintIdentification() const;
    bool enableLauncherWhileLocked() const;
    bool enableIndicatorsWhileLocked() const;
    QString backgroundFile() const;
    bool statsWelcomeScreen() const;
    PasswordDisplayHint passwordDisplayHint() const;
    QString pinCodePromptManager() const;
    QString defaultPinCodePromptManager() const;
    uint failedLogins() const;
    void setFailedLogins(uint failedLogins);
    uint failedFingerprintLogins() const;
    void setFailedFingerprintLogins(uint failedFingerprintLogins);
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
    void realNameChanged();
    void emailChanged();
    void keymapsChanged();
    void pinCodePromptManagerChanged();

private Q_SLOTS:
    void onPropertiesChanged(const QString &user, const QString &interface, const QStringList &changed);
    void onMaybeChanged(const QString &user);

private:
    typedef QVariant (*ProxyConverter)(const QVariant &);

    void refresh(bool async);
    void registerProperty(const QString &interface, const QString &property, const QString &signal);
    void registerProxy(const QString &interface, const QString &property, QDBusInterface *iface, const QString &method, ProxyConverter converter = nullptr);

    void updateAllProperties(const QString &interface, bool async);
    void updateProperty(const QString &interface, const QString &property);
    void updateCache(const QString &interface, const QString &property, const QVariant &value);

    void setProperty(const QString &interface, const QString &property, const QVariant &value);
    QVariant getProperty(const QString &interface, const QString &property) const;

    void emitChangedForProperty(const QString &interface, const QString &property);

    struct PropertyInfo {
        QVariant value{};
        QString signal{};
        QDBusInterface *proxyInterface{};
        QString proxyMethod{};
        ProxyConverter proxyConverter{};
    };
    typedef QHash< QString, QHash<QString, PropertyInfo> > PropertyHash;
    QString m_defaultPinPromptManager;
    PropertyHash m_properties;
    AccountsServiceDBusAdaptor *m_service;
    QDBusInterface *m_unityInput;
    QString m_user;
};

#endif
