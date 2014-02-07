/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * Authors:
 *  Michał Sawicz <michal.sawicz@canonical.com>
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
#include "fake_preview_model.h"

// Qt
#include <QVariantMap>

namespace scopes_ng
{

struct PreviewData
{
    QString id;
    QString type;
    QVariantMap data;

    PreviewData(QString const& id_, QString const& type_, QVariantMap const& data_): id(id_), type(type_), data(data_)
    {
    }
};

PreviewModel::PreviewModel(QObject* parent) : QAbstractListModel(parent)
{
    m_roles[Roles::RoleWidgetId] = "widgetId";
    m_roles[Roles::RoleType] = "type";
    m_roles[Roles::RoleProperties] = "properties";

    populateWidgets();
}

void PreviewModel::populateWidgets()
{
    beginResetModel();
    m_previewWidgets.clear();
    for (int i = 0; i <= 20; i++) {
        // FIXME: the API will expose nicer getters soon, use those!
        QVariantMap attributes;
        attributes["text"] = QVariant::fromValue(QString("Widget %1").arg(i));
        attributes["title"] = QVariant::fromValue(QString("Title %1").arg(i));
        PreviewData* preview_data = new PreviewData(QString("widget-%1").arg(i), QString("text"), attributes);
        m_previewWidgets.append(QSharedPointer<PreviewData>(preview_data));
    }
    endResetModel();

}

void PreviewModel::triggered(QString widgetId, QString actionId, QVariantMap data)
{
    Q_EMIT actionTriggered(widgetId, actionId, data);
}

QHash<int, QByteArray> PreviewModel::roleNames() const
{
    return m_roles;
}

int PreviewModel::rowCount(const QModelIndex&) const
{
    return m_previewWidgets.size();
}

QVariant PreviewModel::data(const QModelIndex& index, int role) const
{
    auto widget_data = m_previewWidgets.at(index.row());
    switch (role) {
        case RoleWidgetId:
            return widget_data->id;
        case RoleType:
            return widget_data->type;
        case RoleProperties:
            return widget_data->data;
        default:
            return QVariant();
    }
}

} // namespace scopes_ng
