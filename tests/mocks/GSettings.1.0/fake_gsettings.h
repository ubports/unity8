/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef FAKE_GSETTINGS_H
#define FAKE_GSETTINGS_H

#include <QList>
#include <QObject>
#include <QStringList>

class GSettingsSchemaQml: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QByteArray id READ id WRITE setId)

public:
    GSettingsSchemaQml(QObject *parent = nullptr);

    QByteArray id() const;
    void setId(const QByteArray &id);

    QByteArray path() const;
    void setPath(const QByteArray &path);

private:
    QByteArray m_id;
    QByteArray m_path;
};

class GSettingsQml: public QObject
{
    Q_OBJECT

    Q_PROPERTY(GSettingsSchemaQml* schema READ schema NOTIFY schemaChanged)
    Q_PROPERTY(QString pictureUri READ pictureUri WRITE setPictureUri NOTIFY pictureUriChanged)
    Q_PROPERTY(QString usageMode READ usageMode WRITE setUsageMode NOTIFY usageModeChanged)
    Q_PROPERTY(qint64 lockedOutTime READ lockedOutTime WRITE setLockedOutTime NOTIFY lockedOutTimeChanged)
    Q_PROPERTY(QStringList lifecycleExemptAppids READ lifecycleExemptAppids WRITE setLifecycleExemptAppids NOTIFY lifecycleExemptAppidsChanged)
    Q_PROPERTY(bool autohideLauncher READ autohideLauncher WRITE setAutohideLauncher NOTIFY autohideLauncherChanged)
    Q_PROPERTY(int launcherWidth READ launcherWidth WRITE setLauncherWidth NOTIFY launcherWidthChanged)

public:
    GSettingsQml(QObject *parent = nullptr);

    GSettingsSchemaQml * schema() const;
    QString pictureUri() const;
    QString usageMode() const;
    qint64 lockedOutTime() const;
    QStringList lifecycleExemptAppids() const;
    bool autohideLauncher() const;
    int launcherWidth() const;

    void setPictureUri(const QString &str);
    void setUsageMode(const QString &usageMode);
    void setLockedOutTime(qint64 timestamp);
    void setLifecycleExemptAppids(const QStringList &appIds);
    void setAutohideLauncher(bool autohideLauncher);
    void setLauncherWidth(int launcherWidth);

Q_SIGNALS:
    void schemaChanged();
    void pictureUriChanged(const QString&);
    void usageModeChanged(const QString&);
    void lockedOutTimeChanged(qint64);
    void lifecycleExemptAppidsChanged(const QStringList &);
    void autohideLauncherChanged(bool);
    void launcherWidthChanged(int launcherWidth);

private:
    GSettingsSchemaQml* m_schema;

    friend class GSettingsSchemaQml;
};

class GSettingsControllerQml: public QObject
{
    Q_OBJECT

public:
    static GSettingsControllerQml* instance();
    ~GSettingsControllerQml();

    QString pictureUri() const;
    Q_INVOKABLE void setPictureUri(const QString &str);

    QString usageMode() const;
    Q_INVOKABLE void setUsageMode(const QString &usageMode);

    qint64 lockedOutTime() const;
    Q_INVOKABLE void setLockedOutTime(qint64 timestamp);

    QStringList lifecycleExemptAppids() const;
    Q_INVOKABLE void setLifecycleExemptAppids(const QStringList &appIds);

    bool autohideLauncher() const;
    Q_INVOKABLE void setAutohideLauncher(bool autohideLauncher);

    int launcherWidth() const;
    Q_INVOKABLE void setLauncherWidth(int launcherWidth);

Q_SIGNALS:
    void pictureUriChanged(const QString&);
    void usageModeChanged(const QString&);
    void lockedOutTimeChanged(qint64 timestamp);
    void lifecycleExemptAppidsChanged(const QStringList&);
    void autohideLauncherChanged(bool autohideLauncher);
    void launcherWidthChanged(int launcherWidth);

private:
    GSettingsControllerQml();

    QString m_pictureUri;
    QString m_usageMode;
    qint64 m_lockedOutTime;
    QStringList m_lifecycleExemptAppids;
    bool m_autohideLauncher;
    int m_launcherWidth;

    static GSettingsControllerQml* s_controllerInstance;
    QList<GSettingsQml *> m_registeredGSettings;
};

#endif // FAKE_GSETTINGS_H
