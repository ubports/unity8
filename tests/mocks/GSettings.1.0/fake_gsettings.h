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
#include <QQmlParserStatus>
#include <QStringList>
#include <QVariant>

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

class GSettingsQml: public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(GSettingsSchemaQml* schema READ schema NOTIFY schemaChanged)
    Q_PROPERTY(QVariant disableHeight READ disableHeight WRITE setDisableHeight NOTIFY disableHeightChanged)
    Q_PROPERTY(QVariant pictureUri READ pictureUri WRITE setPictureUri NOTIFY pictureUriChanged)
    Q_PROPERTY(QVariant usageMode READ usageMode WRITE setUsageMode NOTIFY usageModeChanged)
    Q_PROPERTY(QVariant lockedOutTime READ lockedOutTime WRITE setLockedOutTime NOTIFY lockedOutTimeChanged)
    Q_PROPERTY(QVariant lifecycleExemptAppids READ lifecycleExemptAppids WRITE setLifecycleExemptAppids NOTIFY lifecycleExemptAppidsChanged)
    Q_PROPERTY(QVariant autohideLauncher READ autohideLauncher WRITE setAutohideLauncher NOTIFY autohideLauncherChanged)
    Q_PROPERTY(QVariant launcherWidth READ launcherWidth WRITE setLauncherWidth NOTIFY launcherWidthChanged)
    Q_PROPERTY(QVariant edgeDragWidth READ edgeDragWidth WRITE setEdgeDragWidth NOTIFY edgeDragWidthChanged)

public:
    GSettingsQml(QObject *parent = nullptr);

    void classBegin() override;
    void componentComplete() override;

    GSettingsSchemaQml * schema() const;
    QVariant disableHeight() const;
    QVariant pictureUri() const;
    QVariant usageMode() const;
    QVariant lockedOutTime() const;
    QVariant lifecycleExemptAppids() const;
    QVariant autohideLauncher() const;
    QVariant launcherWidth() const;
    QVariant edgeDragWidth() const;

    void setDisableHeight(const QVariant &val);
    void setPictureUri(const QVariant &str);
    void setUsageMode(const QVariant &usageMode);
    void setLockedOutTime(const QVariant &timestamp);
    void setLifecycleExemptAppids(const QVariant &appIds);
    void setAutohideLauncher(const QVariant &autohideLauncher);
    void setLauncherWidth(const QVariant &launcherWidth);
    void setEdgeDragWidth(const QVariant &edgeDragWidth);

Q_SIGNALS:
    void disableHeightChanged();
    void schemaChanged();
    void pictureUriChanged();
    void usageModeChanged();
    void lockedOutTimeChanged();
    void lifecycleExemptAppidsChanged();
    void autohideLauncherChanged();
    void launcherWidthChanged();
    void edgeDragWidthChanged();

private:
    GSettingsSchemaQml* m_schema;
    bool m_valid;

    friend class GSettingsSchemaQml;
};

class GSettingsControllerQml: public QObject
{
    Q_OBJECT

public:
    static GSettingsControllerQml* instance();
    ~GSettingsControllerQml();

    bool disableHeight() const;
    Q_INVOKABLE void setDisableHeight(bool val);

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

    uint edgeDragWidth() const;
    Q_INVOKABLE void setEdgeDragWidth(uint edgeDragWidth);

Q_SIGNALS:
    void disableHeightChanged();
    void pictureUriChanged(const QString&);
    void usageModeChanged(const QString&);
    void lockedOutTimeChanged(qint64 timestamp);
    void lifecycleExemptAppidsChanged(const QStringList&);
    void autohideLauncherChanged(bool autohideLauncher);
    void launcherWidthChanged(int launcherWidth);
    void edgeDragWidthChanged(uint edgeDragWidth);

private:
    GSettingsControllerQml();

    bool m_disableHeight;
    QString m_pictureUri;
    QString m_usageMode;
    qint64 m_lockedOutTime;
    QStringList m_lifecycleExemptAppids;
    bool m_autohideLauncher;
    int m_launcherWidth;
    uint m_edgeDragWidth;

    static GSettingsControllerQml* s_controllerInstance;
    QList<GSettingsQml *> m_registeredGSettings;
};

#endif // FAKE_GSETTINGS_H
