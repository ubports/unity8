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
    Q_PROPERTY(quint64 lockedOutUntil READ lockedOutUntil WRITE setLockedOutUntil NOTIFY lockedOutUntilChanged)

public:
    GSettingsQml(QObject *parent = nullptr);

    GSettingsSchemaQml * schema() const;
    QString pictureUri() const;
    QString usageMode() const;
    quint64 lockedOutUntil() const;

    void setPictureUri(const QString &str);
    void setUsageMode(const QString &usageMode);
    void setLockedOutUntil(quint64 timestamp);

Q_SIGNALS:
    void schemaChanged();
    void pictureUriChanged(const QString&);
    void usageModeChanged(const QString&);
    void lockedOutUntilChanged(quint64);

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

    quint64 lockedOutUntil() const;
    Q_INVOKABLE void setLockedOutUntil(quint64 timestamp);

Q_SIGNALS:
    void pictureUriChanged(const QString&);
    void usageModeChanged(const QString&);
    void lockedOutUntilChanged(quint64 timestamp);

private:
    GSettingsControllerQml();

    QString m_pictureUri;
    QString m_usageMode;
    quint64 m_lockedOutUntil;

    static GSettingsControllerQml* s_controllerInstance;
    QList<GSettingsQml *> m_registeredGSettings;
};

#endif // FAKE_GSETTINGS_H
