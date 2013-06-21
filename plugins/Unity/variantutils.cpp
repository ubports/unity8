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

#include "variantutils.h"

/* Returns floating ref */
GVariant* GVariantFromQVariant(const QVariant &var)
{
    GVariant *gv = nullptr;

    switch (var.type()) {
        case QVariant::String:
            gv = g_variant_new_string(var.toString().toUtf8());
            break;
        case QVariant::UInt:
            gv = g_variant_new_uint32(var.toUInt());
            break;
        case QVariant::Int:
            gv = g_variant_new_int32(var.toInt());
            break;
        case QVariant::LongLong:
            gv = g_variant_new_int64(var.toLongLong());
            break;
        case QVariant::ULongLong:
            gv = g_variant_new_uint64(var.toULongLong());
            break;
        case QVariant::Double:
            gv = g_variant_new_double(var.toDouble());
            break;
        case QVariant::Bool:
            gv = g_variant_new_boolean(var.toBool());
            break;
        case QVariant::Hash: {
            const auto hash = var.toHash();
            GVariant **children = new GVariant*[hash.size()];
            int cnt = 0;
            QHash<QString, QVariant>::const_iterator it = hash.constBegin();
            while (it != hash.constEnd()) {
                GVariant *key = g_variant_new_string(it.key().toUtf8());
                children[++cnt] = g_variant_new_dict_entry(key, GVariantFromQVariant(it.value()));
                ++it;
            }
            gv = g_variant_new_array(G_VARIANT_TYPE_DICT_ENTRY, children, 1);
            delete [] children;
            break;
        }
        default:
            return NULL;
    }
    return gv;
}

unity::glib::HintsMap hintsMapFromQVariant(const QVariant &var)
{
    if (var.type() == QVariant::Hash) {
    }
    return unity::glib::HintsMap();
}
