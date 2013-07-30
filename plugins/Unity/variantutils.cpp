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
#include "variantutils.h"

unity::glib::HintsMap convertToHintsMap(const QHash<QString, QVariant> &val)
{
    unity::glib::HintsMap hintsMap;
    QHash<QString, QVariant>::const_iterator it = val.constBegin();
    while (it != val.constEnd()) {
        hintsMap[it.key().toStdString()] = DeeListModel::DataFromVariant(it.value());
        ++it;
    }
    return hintsMap;
}

unity::glib::HintsMap convertToHintsMap(const QVariant &var)
{
    if (var.type() == QVariant::Hash) {
        unity::glib::HintsMap hintsMap;
        const auto hash = var.toHash();
        return convertToHintsMap(hash);
    }
    return unity::glib::HintsMap();
}
