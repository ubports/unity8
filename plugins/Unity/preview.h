/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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

#ifndef PREVIEW_H
#define PREVIEW_H

// Qt
#include <QObject>
#include <QString>
#include <QMetaType>

// libunity-core
#include <UnityCore/Preview.h>

// local
#include "previewaction.h"

class Preview : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QString rendererName READ rendererName NOTIFY rendererNameChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString subtitle READ subtitle NOTIFY subtitleChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QVariant actions READ actions NOTIFY actionsChanged)
    Q_PROPERTY(QString image READ image NOTIFY imageChanged)
    Q_PROPERTY(QString imageSourceUri READ imageSourceUri NOTIFY imageSourceUriChanged)
    
public:
    explicit Preview(QObject *parent = 0);
    static Preview* newFromUnityPreview(unity::dash::Preview::Ptr unityPreview);

    QString rendererName() const;
    QString title() const;
    QString subtitle() const;
    QString description() const;
    QVariant actions();
    QString image() const;
    QString imageSourceUri() const;

    Q_INVOKABLE void execute(const QString& actionId, const QHash<QString, QVariant>& hints);

Q_SIGNALS:
    void rendererNameChanged();
    void titleChanged();
    void subtitleChanged();
    void descriptionChanged();
    void actionsChanged();
    void imageChanged();
    void imageSourceUriChanged();

protected:
    virtual void setUnityPreview(unity::dash::Preview::Ptr unityPreview);

    unity::dash::Preview::Ptr m_unityPreview;
};

Q_DECLARE_METATYPE(Preview *)

#endif
