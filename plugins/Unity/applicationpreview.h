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

#ifndef APPLICATIONPREVIEW_H
#define APPLICATIONPREVIEW_H

// local
#include "preview.h"

// Qt
#include <QObject>
#include <QMetaType>

// libunity-core
#include <UnityCore/ApplicationPreview.h>

class ApplicationPreview: public Preview
{
    Q_OBJECT

    Q_PROPERTY(QString lastUpdate READ lastUpdate)
    Q_PROPERTY(QString copyright READ copyright)
    Q_PROPERTY(QString license READ license)
    Q_PROPERTY(QString appIcon READ appIcon)
    Q_PROPERTY(float rating READ rating)
    Q_PROPERTY(unsigned int numRatings READ numRatings)

public:
    explicit ApplicationPreview(QObject *parent = 0);

    QString lastUpdate() const;
    QString copyright() const;
    QString license() const;
    QString appIcon() const;
    float rating() const;
    unsigned int numRatings() const;

protected:
    void setUnityPreview(unity::dash::Preview::Ptr unityPreview) override;

private:
    unity::dash::ApplicationPreview::Ptr m_unityAppPreview;
};

Q_DECLARE_METATYPE(ApplicationPreview *)

#endif
