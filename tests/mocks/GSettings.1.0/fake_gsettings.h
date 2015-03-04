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
#include <QHash>
#include <QObject>

class GSettingsSchemaQml: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QByteArray id READ id WRITE setId NOTIFY idChanged)

public:
    GSettingsSchemaQml(QObject *parent = nullptr);

    QByteArray id() const;
    void setId(const QByteArray &id);

    QByteArray path() const;
    void setPath(const QByteArray &path);

Q_SIGNALS:
    void idChanged(const QByteArray &id);

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

public:
    GSettingsQml(QObject *parent = nullptr);
    ~GSettingsQml();

    GSettingsSchemaQml * schema() const;

    void setPictureUri(const QString &str);
    QString pictureUri() const;

    void setUsageMode(const QString &str);
    QString usageMode() const;

Q_SIGNALS:
    void schemaChanged();
    void pictureUriChanged(const QString&);
    void usageModeChanged(const QString&);

private:
    GSettingsSchemaQml* m_schema;
    QString m_pictureUri;

    friend class GSettingsSchemaQml;
};

class GSettingsControllerQml: public QObject
{
    Q_OBJECT

public:
    static GSettingsControllerQml* instance();
    ~GSettingsControllerQml();

    void registerSettingsObject(GSettingsQml *obj);
    void unRegisterSettingsObject(GSettingsQml *obj);

    Q_INVOKABLE void setPictureUri(const QByteArray &id, const QString &str);
    QString pictureUri(const QByteArray &id) const;

    Q_INVOKABLE void setUsageMode(const QByteArray &id, const QString &str);
    QString usageMode(const QByteArray &id) const;

private:
    GSettingsControllerQml();

    static GSettingsControllerQml* s_controllerInstance;
    QList<GSettingsQml *> m_registeredGSettings;

    QHash<QString, QString> m_pictureUri;
    QHash<QString, QString> m_usageMode;
};

#endif // FAKE_GSETTINGS_H
