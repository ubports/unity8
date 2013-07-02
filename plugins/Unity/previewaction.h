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

#ifndef PREVIEWACTION_H
#define PREVIEWACTION_H

// Qt
#include <QObject>
#include <QList>

// libuinity-core
#include <UnityCore/Preview.h>

enum LayoutHint // keep in sync with unty::dash::LayoutHint
{
    None,
    Left,
    Right,
    Top,
    Bottom
};

class PreviewAction : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id NOTIFY previewActionChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY previewActionChanged)
    Q_PROPERTY(QString iconHint READ iconHint NOTIFY previewActionChanged)
    Q_PROPERTY(QString extraText READ extraText NOTIFY previewActionChanged)
    Q_PROPERTY(QString activationUri READ activationUri NOTIFY previewActionChanged)
    Q_PROPERTY(LayoutHint layoutHint READ layoutHint NOTIFY previewActionChanged)

public:
    explicit PreviewAction(QObject *parent = 0);
    void setUnityAction(unity::dash::Preview::ActionPtr unityAction);

    QString id() const;
    QString displayName() const;
    QString iconHint() const;
    QString extraText() const;
    QString activationUri() const;
    LayoutHint layoutHint() const;

Q_SIGNALS:
    void previewActionChanged();

private:
    unity::dash::Preview::ActionPtr m_unityAction;
};

Q_DECLARE_METATYPE(PreviewAction *)
Q_DECLARE_METATYPE(LayoutHint)

#endif
