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

#include <QUrl>
#include <QUrlQuery>
#include <QStringList>

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

QVariantHash convertToQVariantHash(const unity::glib::HintsMap& var)
{
    QVariantHash hash;
    for (auto hint: var) {
        hash.insert(QString::fromStdString(hint.first), DeeListModel::VariantForData(hint.second));
    }
    return hash;
}

/* This will translate uris in the form of:
 *   "subscope:master.scope/sub.scope?foo=bar"
 * into a QVariantHash that can be passed as a metadata field to scope.
 */
QVariantHash subscopeUriToMetadataHash(const QString &metadata_string)
{
    QUrl metadata_url(metadata_string);
    if (metadata_url.scheme() == QLatin1String("subscope")) {
        QString subscope_uri(metadata_url.toString(QUrl::RemoveScheme | QUrl::RemoveQuery));
        QVariantHash new_metadata;
        QUrlQuery query(metadata_url.query());
        QList<QPair<QString,QString>> queryItems(query.queryItems());
        for (auto it = queryItems.begin(); it != queryItems.end(); ++it) {
            new_metadata[it->first] = QVariant::fromValue(it->second);
        }
        QStringList parts(subscope_uri.split(QChar('/')));
        for (int i = parts.size() - 1; i >= 0; i--) {
            QVariantHash inner;
            inner["scope-id"] = QVariant::fromValue(parts[i]);
            inner["content"] = QVariant::fromValue(new_metadata);
            new_metadata = inner;
        }
        return new_metadata;
    }
    return QVariantHash();
}
