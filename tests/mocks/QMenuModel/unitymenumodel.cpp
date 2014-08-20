/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 * Authors: Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "unitymenumodel.h"

enum MenuRoles {
    LabelRole  = Qt::DisplayRole + 1,
    SensitiveRole,
    IsSeparatorRole,
    IconRole,
    TypeRole,
    ExtendedAttributesRole,
    ActionRole,
    ActionStateRole,
    IsCheckRole,
    IsRadioRole,
    IsToggledRole
};

UnityMenuModel::UnityMenuModel(QObject *parent)
:   QAbstractListModel(parent)
{
}

QVariant UnityMenuModel::modelData() const
{
    return m_modelData;
}

void UnityMenuModel::setModelData(const QVariant& data)
{
    beginResetModel();

    m_modelData.clear();
    m_modelData = data.toList();

    endResetModel();
}


void UnityMenuModel::insertRow(int row, const QVariant& data)
{
    row = qMin(row, rowCount());

    beginInsertRows(QModelIndex(), row, row);

    m_modelData.insert(row, data);

    endInsertRows();
}

void UnityMenuModel::appendRow(const QVariant& data)
{
    insertRow(rowCount(), data);
}

void UnityMenuModel::removeRow(int row)
{
    if (row < 0 || rowCount() <= row) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);

    m_modelData.removeAt(row);

    endRemoveRows();
}

UnityMenuModel::~UnityMenuModel()
{
}

QByteArray UnityMenuModel::busName() const
{
    return m_busName;
}

void UnityMenuModel::setBusName(const QByteArray &busName)
{
    this->m_busName = busName;
}

QVariantMap UnityMenuModel::actions() const
{
    return m_actions;
}

void UnityMenuModel::setActions(const QVariantMap &actions)
{
    this->m_actions = actions;
}

QByteArray UnityMenuModel::menuObjectPath() const
{
    return m_menuObjectPath;
}

void UnityMenuModel::setMenuObjectPath(const QByteArray &path)
{
    this->m_menuObjectPath = path;
}

ActionStateParser* UnityMenuModel::actionStateParser() const
{
    return NULL;
}

void UnityMenuModel::setActionStateParser(ActionStateParser*)
{
}

QString UnityMenuModel::nameOwner() const
{
    return QString("");
}

int UnityMenuModel::rowCount(const QModelIndex&) const
{
    return m_modelData.count();
}

int UnityMenuModel::columnCount(const QModelIndex&) const
{
    return 1;
}

QVariant UnityMenuModel::data(const QModelIndex &index, int role) const
{
    return rowData(index.row())[roleNames()[role]];
}

QVariantMap UnityMenuModel::rowData(int row) const
{
    if (m_modelData.count() <= row) {
        return QVariantMap();
    }
    return m_modelData[row].toMap()["rowData"].toMap();
}

QVariant UnityMenuModel::subMenuData(int row) const
{
    return m_modelData[row].toMap()["submenu"];
}

QModelIndex UnityMenuModel::index(int row, int column, const QModelIndex&) const
{
    return createIndex(row, column);
}

QModelIndex UnityMenuModel::parent(const QModelIndex &) const
{
    return QModelIndex();
}

QHash<int, QByteArray> UnityMenuModel::roleNames() const
{
    QHash<int, QByteArray> names;

    names[LabelRole] = "label";
    names[SensitiveRole] = "sensitive";
    names[IsSeparatorRole] = "isSeparator";
    names[IconRole] = "icon";
    names[TypeRole] = "type";
    names[ExtendedAttributesRole] = "ext";
    names[ActionRole] = "action";
    names[ActionStateRole] = "actionState";
    names[IsCheckRole] = "isCheck";
    names[IsRadioRole] = "isRadio";
    names[IsToggledRole] = "isToggled";

    return names;
}

QObject * UnityMenuModel::submenu(int position, QQmlComponent*)
{
    if (position < 0 || m_modelData.count() < position) {
        return NULL;
    }

    while (submenus.count() <= position) {
        submenus.append(NULL);
    }

    QVariant submenuData = subMenuData(position);
    if (submenuData.type() == (int)QMetaType::QVariantList) {
        UnityMenuModel*& model = submenus[position];
        if (!model) {
            model = new UnityMenuModel(this);
        }
        if (model->modelData() != submenuData) {
            model->setModelData(submenuData);
        }
        return model;
    }

    return NULL;
}

bool UnityMenuModel::loadExtendedAttributes(int, const QVariantMap &)
{
    return false;
}

QVariant UnityMenuModel::get(int row, const QByteArray &role)
{
    static QHash<QByteArray, int> roles;
    if (roles.isEmpty()) {
        QHash<int, QByteArray> names = roleNames();
        Q_FOREACH (int role, names.keys())
            roles.insert(names[role], role);
    }

    return this->data(this->index(row, 0), roles[role]);
}

void UnityMenuModel::activate(int, const QVariant&)
{
}

void UnityMenuModel::changeState(int, const QVariant&)
{
}

void UnityMenuModel::registerAction(UnityMenuAction*)
{
}

void UnityMenuModel::unregisterAction(UnityMenuAction*)
{
}
