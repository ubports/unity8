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
                children[cnt++] = g_variant_new_dict_entry(key, g_variant_new_variant(GVariantFromQVariant(it.value())));
                ++it;
            }
            gv = g_variant_new_array(G_VARIANT_TYPE("{sv}"), children, hash.size());
            delete [] children;
            break;
        }
        default:
            break;
    }
    return gv;
}

// implementation of this conversion taken from libdee-qt private utility function.
QVariant QVariantFromGVariant(GVariant *value)
{
    /* We need to special-case a{sv} here as G_VARIANT_CLASS_ARRAY handles simple arrays;
       we need to create QVariantHash, not a list */
    if (g_variant_is_of_type(value, G_VARIANT_TYPE_VARDICT)) {
        const gsize nChildren = g_variant_n_children(value);
        QVariantHash hash;
        for (gsize i = 0; i < nChildren; ++i)
        {
            GVariant* dict_entry = g_variant_get_child_value(value, i);

            gchar* dict_key;
            GVariant *dict_var;
            g_variant_get(dict_entry, "{&sv}", &dict_key, &dict_var);
            hash.insert(QString::fromUtf8(dict_key), QVariantFromGVariant(dict_var));
            g_variant_unref(dict_var);
            g_variant_unref(dict_entry);
        }
        return hash;
    }

    switch (g_variant_classify(value)) {
        case G_VARIANT_CLASS_BOOLEAN:
            return QVariant((bool) g_variant_get_boolean(value));
        case G_VARIANT_CLASS_BYTE:
            return QVariant((uchar) g_variant_get_byte(value));
        case G_VARIANT_CLASS_INT16:
            return QVariant((qint16) g_variant_get_int16(value));
        case G_VARIANT_CLASS_UINT16:
            return QVariant((quint16) g_variant_get_uint16(value));
        case G_VARIANT_CLASS_INT32:
            return QVariant((qint32) g_variant_get_int32(value));
        case G_VARIANT_CLASS_UINT32:
            return QVariant((quint32) g_variant_get_uint32(value));
        case G_VARIANT_CLASS_INT64:
            return QVariant((qint64) g_variant_get_int64(value));
        case G_VARIANT_CLASS_UINT64:
            return QVariant((quint64) g_variant_get_uint64(value));
        case G_VARIANT_CLASS_DOUBLE:
            return QVariant(g_variant_get_double(value));
        case G_VARIANT_CLASS_STRING:
            return QVariant(QString::fromUtf8(g_variant_get_string(value, NULL)));
        case G_VARIANT_CLASS_ARRAY:
        case G_VARIANT_CLASS_TUPLE:
        {
            const gsize nChildren = g_variant_n_children(value);
            QList<QVariant> array;
            for (gsize i = 0; i < nChildren; ++i)
            {
              GVariant* gvariant = g_variant_get_child_value(value, i);
              array << QVariantFromGVariant(gvariant);
              g_variant_unref(gvariant);
            }
            return array;
        }
        default:
            /* Fallback on an empty QVariant.
               FIXME: Missing conversion of following GVariant types:
                - G_VARIANT_CLASS_HANDLE
                - G_VARIANT_CLASS_OBJECT_PATH
                - G_VARIANT_CLASS_SIGNATURE
                - G_VARIANT_CLASS_VARIANT
                - G_VARIANT_CLASS_MAYBE
                - G_VARIANT_CLASS_DICT_ENTRY
            */
            return QVariant();
    }
}

unity::glib::HintsMap convertToHintsMap(const QHash<QString, QVariant> &val)
{
    unity::glib::HintsMap hintsMap;
    QHash<QString, QVariant>::const_iterator it = val.constBegin();
    while (it != val.constEnd()) {
        hintsMap[it.key().toStdString()] = GVariantFromQVariant(it.value());
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
