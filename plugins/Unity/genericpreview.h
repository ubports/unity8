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

#ifndef GENERICPREVIEW_H
#define GENERICPREVIEW_H

// local
#include "preview.h"

// Qt
#include <QObject>
#include <QMetaType>

class GenericPreview : public Preview
{
    Q_OBJECT

public:
    explicit GenericPreview(QObject *parent = 0);

Q_SIGNALS:
    void previewChanged();

protected:
    void setUnityPreview(unity::dash::Preview::Ptr unityPreview) override;
};

Q_DECLARE_METATYPE(GenericPreview *)

#endif
