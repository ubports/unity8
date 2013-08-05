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

#include <deelistmodel.h>
// local
#include "previewinfohint.h"

PreviewInfoHint::PreviewInfoHint(QObject *parent):
    QObject(parent),
    m_unityInfoHint(nullptr)
{
}

void PreviewInfoHint::setUnityInfoHint(unity::dash::Preview::InfoHintPtr unityInfoHint)
{
    m_unityInfoHint = unityInfoHint;

    Q_EMIT previewInfoHintChanged();
}

QString PreviewInfoHint::id() const
{
    if (m_unityInfoHint) {
        return QString::fromStdString(m_unityInfoHint->id);
    }
    return QString();
}

QString PreviewInfoHint::displayName() const
{
    if (m_unityInfoHint) {
        return QString::fromStdString(m_unityInfoHint->display_name);
    }
    return QString();
}

QString PreviewInfoHint::iconHint() const
{
   if (m_unityInfoHint) {
       return QString::fromStdString(m_unityInfoHint->icon_hint);
   }
   return QString();
}

QVariant PreviewInfoHint::value() const
{
    if (m_unityInfoHint) {
        return DeeListModel::VariantForData(m_unityInfoHint->value);
    }
    return QVariant();
}
