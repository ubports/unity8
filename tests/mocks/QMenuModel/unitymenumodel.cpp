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

#include <QTimer>

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
    IsToggledRole,
    ShortcutRole,
    HasSubmenuRole
};

UnityMenuModel::UnityMenuModel(QObject *parent)
 : QAbstractListModel(parent)
 , m_rowCountStatus(NoRequestMade)
{
}

UnityMenuModel::~UnityMenuModel()
{
}

QVariant UnityMenuModel::modelData() const
{
    return m_modelData;
}

void UnityMenuModel::setModelData(const QVariant& data)
{
    beginResetModel();

    m_modelData = data.toList();
    Q_EMIT modelDataChanged();

    endResetModel();
}

void UnityMenuModel::insertRow(int row, const QVariant& data)
{
    row = qMin(row, m_modelData.count());

    beginInsertRows(QModelIndex(), row, row);

    m_modelData.insert(row, data);

    endInsertRows();
}

void UnityMenuModel::appendRow(const QVariant& data)
{
    insertRow(m_modelData.count(), data);
}

void UnityMenuModel::removeRow(int row)
{
    if (row < 0 || m_modelData.count() <= row) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);

    m_modelData.removeAt(row);

    endRemoveRows();
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
    return nullptr;
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
    // Fake the rowCount to be 0 for a while (100ms)
    // This emulates menus in real world that don't load immediately
    if (m_rowCountStatus == TimerRunning)
        return 0;

    if (m_rowCountStatus == NoRequestMade) {
        UnityMenuModel *that = const_cast<UnityMenuModel*>(this);
        that->m_rowCountStatus = TimerRunning;
        QTimer::singleShot(100, that, [that] {
            that->beginInsertRows(QModelIndex(), 0, that->m_modelData.count() - 1);
            that->m_rowCountStatus = TimerFinished;
            that->endInsertRows();
        });
        return 0;
    }

    return m_modelData.count();
}

int UnityMenuModel::columnCount(const QModelIndex&) const
{
    return 1;
}

QVariant UnityMenuModel::data(const QModelIndex &index, int role) const
{
    QVariantMap v = rowData(index.row());
    QString roleName = roleNames()[role];

    if (v.contains(roleName)) return v[roleName];

    // defaults
    switch (role) {
        case LabelRole: return QString();
        case SensitiveRole: return true;
        case IsSeparatorRole: return false;
        case IconRole: return QString();
        case TypeRole: return QString();
        case ExtendedAttributesRole: return QVariantMap();
        case ActionRole: return QString();
        case ActionStateRole: return QVariant();
        case IsCheckRole: return false;
        case IsRadioRole: return false;
        case IsToggledRole: return false;
        case ShortcutRole: return QString();
        case HasSubmenuRole: return subMenuData(index.row()).isValid();
        default: break;
    }
    return QVariant();
}

QVariantMap UnityMenuModel::rowData(int row) const
{
    if (m_modelData.count() <= row) {
        return QVariantMap();
    }
    QVariantMap vRow = m_modelData.value(row, QVariantMap()).toMap();
    return vRow["rowData"].toMap();
}

QVariant UnityMenuModel::subMenuData(int row) const
{
    QVariantMap v = m_modelData.value(row, QVariantMap()).toMap();
    return v.value("submenu", QVariant());
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
    names[ShortcutRole] = "shortcut";
    names[HasSubmenuRole] = "hasSubmenu";

    return names;
}

QObject * UnityMenuModel::submenu(int position, QQmlComponent*)
{
    if (position < 0 || m_modelData.count() < position) {
        return nullptr;
    }

    while (submenus.count() <= position) {
        submenus.append(nullptr);
    }

    QVariant submenuData = subMenuData(position);
    if (submenuData.type() == (int)QMetaType::QVariantList) {
        UnityMenuModel*& model = submenus[position];
        if (!model) {
            model = new UnityMenuModel(this);
            connect(model, &UnityMenuModel::activated, this, &UnityMenuModel::activated);
        }
        if (model->modelData() != submenuData) {
            model->setModelData(submenuData);
        }
        return model;
    }

    return nullptr;
}

bool UnityMenuModel::loadExtendedAttributes(int, const QVariantMap &)
{
    return false;
}

QVariant UnityMenuModel::get(int row, const QByteArray &role)
{
    static QHash<QByteArray, int> roles;
    if (roles.isEmpty()) {
        const QHash<int, QByteArray> names = roleNames();
        for(auto it = names.begin(); it != names.end(); ++it)
            roles.insert(it.value(), it.key());
    }

    return data(index(row, 0), roles[role]);
}

void UnityMenuModel::activate(int row, const QVariant&)
{
    QVariantMap vModelData = m_modelData.value(row, QVariantMap()).toMap();
    QVariantMap rd = vModelData["rowData"].toMap();

    bool isCheckable = rd[roleNames()[IsCheckRole]].toBool() || rd[roleNames()[IsRadioRole]].toBool();
    if (isCheckable) {
        rd[roleNames()[IsToggledRole]] = !rd[roleNames()[IsToggledRole]].toBool();
        vModelData["rowData"] = rd;
        m_modelData[row] = vModelData;

        dataChanged(index(row, 0), index(row, 0),  QVector<int>() << IsToggledRole);
    }
    Q_EMIT activated(rd[roleNames()[ActionRole]].toString());
}

void UnityMenuModel::aboutToShow(int index)
{
    Q_EMIT aboutToShowCalled(index);
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
