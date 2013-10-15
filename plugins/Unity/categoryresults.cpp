/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michal Hruby <michal.hruby@canonical.com>
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

// self
#include "categoryresults.h"
#include "iconutils.h"

// TODO: use something from libunity once it's public
enum ResultsColumn {
    URI,
    ICON_HINT,
    CATEGORY,
    RESULT_TYPE,
    MIMETYPE,
    TITLE,
    COMMENT,
    DND_URI,
    METADATA
};

CategoryResults::CategoryResults(QObject* parent)
    : DeeListModel(parent)
    , m_categoryIndex(-1)
{
    m_roles[CategoryResults::RoleUri] = "uri";
    m_roles[CategoryResults::RoleIconHint] = "icon";
    m_roles[CategoryResults::RoleCategory] = "category";
    m_roles[CategoryResults::RoleMimetype] = "mimetype";
    m_roles[CategoryResults::RoleTitle] = "title";
    m_roles[CategoryResults::RoleComment] = "comment";
    m_roles[CategoryResults::RoleDndUri] = "dndUri";
    m_roles[CategoryResults::RoleMetadata] = "metadata";
    m_roles[CategoryResults::RoleRendererHints] = "rendererHints";
}

int CategoryResults::categoryIndex() const
{
    return m_categoryIndex;
}

void CategoryResults::setCategoryIndex(int index)
{
    if (m_categoryIndex != index) {
        m_categoryIndex = index;
        Q_EMIT categoryIndexChanged(m_categoryIndex);
    }
}

QHash<int, QByteArray>
CategoryResults::roleNames() const
{
    return m_roles;
}

QVariant
CategoryResults::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
        case RoleUri:
            return DeeListModel::data(index, ResultsColumn::URI);
        case RoleIconHint: {
            QString giconString(DeeListModel::data(index, ResultsColumn::ICON_HINT).toString());
            if (giconString.isEmpty()) {
                QString mimetype(DeeListModel::data(index, ResultsColumn::MIMETYPE).toString());
                QString uri(DeeListModel::data(index, ResultsColumn::URI).toString());
                QString thumbnailerUri(uriToThumbnailerProviderString(uri, mimetype, DeeListModel::data(index, ResultsColumn::METADATA).toHash()));
                if (!thumbnailerUri.isNull()) {
                    return QVariant::fromValue(thumbnailerUri);
                }
            }
            return QVariant::fromValue(gIconToDeclarativeImageProviderString(giconString));
        }
        case RoleCategory:
            return DeeListModel::data(index, ResultsColumn::CATEGORY);
        case RoleMimetype:
            return DeeListModel::data(index, ResultsColumn::MIMETYPE);
        case RoleTitle:
            return DeeListModel::data(index, ResultsColumn::TITLE);
        case RoleComment:
            return DeeListModel::data(index, ResultsColumn::COMMENT);
        case RoleDndUri:
            return DeeListModel::data(index, ResultsColumn::DND_URI);
        case RoleMetadata:
            return DeeListModel::data(index, ResultsColumn::METADATA);
        case RoleRendererHints:
        {
            QVariantHash hash(DeeListModel::data(index, ResultsColumn::METADATA).toHash());
            if (hash.contains("content")) {
                QVariantMap hints;
                QVariantHash innerHash(hash["content"].toHash());
                if (innerHash.contains("scope_disabled")) {
                    hints["scope_disabled"] = innerHash["scope_disabled"];
                }
                return hints.empty() ? QVariant() : QVariant::fromValue(hints);
            }
            return QVariant();
        }
        default:
            return QVariant();
    }
}
