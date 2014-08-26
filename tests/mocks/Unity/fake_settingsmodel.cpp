/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#include "fake_settingsmodel.h"

SettingsModel::SettingsModel(QObject* parent) :
        SettingsModelInterface(parent) {
    {
        QVariantMap parameters;
        m_data << QSharedPointer<Data>(new Data("boolean-setting", "Boolean Setting", "boolean", parameters, true));
    }
    {
        QVariantMap parameters;
        parameters["values"] = QVariantList() << "First" << "Second" << "Third";
        m_data << QSharedPointer<Data>(new Data("list-setting", "List Setting", "list", parameters, 1));
    }
    {
        QVariantMap parameters;
        m_data << QSharedPointer<Data>(new Data("number-setting", "Number Setting", "number", parameters, 1.23));
    }
    {
        QVariantMap parameters;
        m_data << QSharedPointer<Data>(new Data("string-setting", "String Setting", "string", parameters, "flibble"));
    }
}

QVariant SettingsModel::data(const QModelIndex& index, int role) const {
    int row = index.row();
    QVariant result;

    if (row < m_data.size()) {
        auto data = m_data[row];

        switch (role) {
        case Roles::RoleSettingId:
            result = data->id;
            break;
        case Roles::RoleDisplayName:
            result = data->displayName;
            break;
        case Roles::RoleType:
            result = data->type;
            break;
        case Roles::RoleProperties:
            result = data->properties;
            break;
        case Roles::RoleValue: {
            result = data->value;
            break;
        }
        default:
            break;
        }
    }

    return result;
}

bool SettingsModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    int row = index.row();
    if (row < m_data.size()) {
        switch (role) {
        case SettingsModelInterface::RoleValue: {
            auto data = m_data[row];
            data->value = value;
            return true;
        }
        default:
            break;
        }
    }

    return false;
}

int SettingsModel::rowCount(const QModelIndex&) const {
    return count();
}

int SettingsModel::count() const {
    return m_data.size();
}
