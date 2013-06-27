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

// local
#include "previewinfohint.h"
#include "variantutils.h"

PreviewInfoHint::PreviewInfoHint(QObject *parent):
    QObject(parent),
    m_unityInfoHint(nullptr)
{
}

void PreviewInfoHint::setUnityInfoHint(unity::dash::Preview::InfoHintPtr unityInfoHint)
{
    m_unityInfoHint = unityInfoHint;

    Q_EMIT displayNameChanged();
    Q_EMIT iconHintChanged();
    Q_EMIT valueChanged();
}

QString PreviewInfoHint::id() const
{
    if (m_unityInfoHint) {
        return QString::fromStdString(m_unityInfoHint->id);
    }
    return "";
}

QString PreviewInfoHint::displayName() const
{
    if (m_unityInfoHint) {
        return QString::fromStdString(m_unityInfoHint->display_name);
    }
    return "";
}

QString PreviewInfoHint::iconHint() const
{
   if (m_unityInfoHint) {
       return QString::fromStdString(m_unityInfoHint->icon_hint);
   }
   return "";
}

QVariant PreviewInfoHint::value() const
{
}
