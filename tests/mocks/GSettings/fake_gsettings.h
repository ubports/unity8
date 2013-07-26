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

#include <QtQml>
#include <QQmlParserStatus>

class GSettingsControllerQml: public QObject
{
    Q_OBJECT

public:
    static GSettingsControllerQml* getInstance();
    ~GSettingsControllerQml();

    void setPictureUri(const QString &str);

private:
    GSettingsControllerQml();
    GSettingsControllerQml(const GSettingsControllerQml&);
    GSettingsControllerQml& operator=(const GSettingsControllerQml&);

    static bool instance_exists;

    static GSettingsControllerQml* _controllerInstance;
};

class GSettingsSchemaQml: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QByteArray id READ id WRITE setId)

public:
    GSettingsSchemaQml(QObject *parent = NULL);
    ~GSettingsSchemaQml();

    QByteArray id() const;
    void setId(const QByteArray &id);

    QByteArray path() const;
    void setPath(const QByteArray &path);

private:
    struct GSettingsSchemaQmlPrivate *priv;
};

class GSettingsQml: public QObject
{
    Q_OBJECT

    Q_PROPERTY(GSettingsSchemaQml* schema READ schema NOTIFY schemaChanged)
    Q_PROPERTY(QString pictureUri READ pictureUri WRITE setPictureUri NOTIFY pictureUriChanged)

public:
    GSettingsQml(QObject *parent = NULL);
    ~GSettingsQml();

    GSettingsSchemaQml * schema() const;
    QString pictureUri() const;

    void setPictureUric

Q_SIGNALS:
    void schemaChanged();
    void pictureUriChanged(const QString&);

private:
    struct GSettingsQmlPrivate *priv;

    QString m_pictureUri;

    friend class GSettingsSchemaQml;
};

#endif // FAKE_GSETTINGS_H
