/*
 * This file is part of system-settings
 *
 * Copyright (C) 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QObject>
#include <QString>

class QDBusInterface;
class QDBusPendingCallWatcher;

class System : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool hereEnabled READ hereEnabled WRITE setHereEnabled NOTIFY hereEnabledChanged)
    Q_PROPERTY(QString hereLicensePath READ hereLicensePath NOTIFY hereLicensePathChanged)

public:
    System();

    bool hereEnabled() const;
    void setHereEnabled(bool enabled);

    QString hereLicensePath() const;

public Q_SLOTS:
    void updateSessionLanguage();

Q_SIGNALS:
    void hereEnabledChanged();
    void hereLicensePathChanged();

private Q_SLOTS:
    void propertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalid);
    void getHereEnabledFinished(QDBusPendingCallWatcher *watcher);
    void getHereLicensePathFinished(QDBusPendingCallWatcher *watcher);

private:
    Q_DISABLE_COPY(System)

    QDBusInterface *m_accounts;
    bool m_hereEnabled;
    QString m_hereLicensePath;
};
