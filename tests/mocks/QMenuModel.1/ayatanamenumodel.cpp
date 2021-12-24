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

#include "ayatanamenumodel.h"

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

AyatanaMenuModel::AyatanaMenuModel(QObject *parent)
 : QAbstractListModel(parent)
 , m_rowCountStatus(NoRequestMade)
{
}

AyatanaMenuModel::~AyatanaMenuModel()
{
}

QVariant AyatanaMenuModel::modelData() const
{
    return m_modelData;
}

void AyatanaMenuModel::setModelData(const QVariant& data)
{
    beginResetModel();

    m_modelData = data.toList();
    Q_EMIT modelDataChanged();

    endResetModel();
}

void AyatanaMenuModel::insertRow(int row, const QVariant& data)
{
    row = qMin(row, m_modelData.count());

    beginInsertRows(QModelIndex(), row, row);

    m_modelData.insert(row, data);

    endInsertRows();
}

void AyatanaMenuModel::appendRow(const QVariant& data)
{
    insertRow(m_modelData.count(), data);
}

void AyatanaMenuModel::removeRow(int row)
{
    if (row < 0 || m_modelData.count() <= row) {
        return;
    }

    beginRemoveRows(QModelIndex(), row, row);

    m_modelData.removeAt(row);

    endRemoveRows();
}

QByteArray AyatanaMenuModel::busName() const
{
    return m_busName;
}

void AyatanaMenuModel::setBusName(const QByteArray &busName)
{
    this->m_busName = busName;
}

QVariantMap AyatanaMenuModel::actions() const
{
    return m_actions;
}

void AyatanaMenuModel::setActions(const QVariantMap &actions)
{
    this->m_actions = actions;
}

QByteArray AyatanaMenuModel::menuObjectPath() const
{
    return m_menuObjectPath;
}

void AyatanaMenuModel::setMenuObjectPath(const QByteArray &path)
{
    this->m_menuObjectPath = path;
}

ActionStateParser* AyatanaMenuModel::actionStateParser() const
{
    return nullptr;
}

void AyatanaMenuModel::setActionStateParser(ActionStateParser*)
{
}

QString AyatanaMenuModel::nameOwner() const
{
    return QString("");
}

int AyatanaMenuModel::rowCount(const QModelIndex&) const
{
    // Fake the rowCount to be 0 for a while (100ms)
    // This emulates menus in real world that don't load immediately
    if (m_rowCountStatus == TimerRunning)
        return 0;

    if (m_rowCountStatus == NoRequestMade) {
        AyatanaMenuModel *that = const_cast<AyatanaMenuModel*>(this);
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

int AyatanaMenuModel::columnCount(const QModelIndex&) const
{
    return 1;
}

QVariant AyatanaMenuModel::data(const QModelIndex &index, int role) const
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

QVariantMap AyatanaMenuModel::rowData(int row) const
{
    if (m_modelData.count() <= row) {
        return QVariantMap();
    }
    QVariantMap vRow = m_modelData.value(row, QVariantMap()).toMap();
    return vRow["rowData"].toMap();
}

QVariant AyatanaMenuModel::subMenuData(int row) const
{
    QVariantMap v = m_modelData.value(row, QVariantMap()).toMap();
    return v.value("submenu", QVariant());
}

QModelIndex AyatanaMenuModel::index(int row, int column, const QModelIndex&) const
{
    return createIndex(row, column);
}

QModelIndex AyatanaMenuModel::parent(const QModelIndex &) const
{
    return QModelIndex();
}

QHash<int, QByteArray> AyatanaMenuModel::roleNames() const
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

QObject * AyatanaMenuModel::submenu(int position, QQmlComponent*)
{
    if (position < 0 || m_modelData.count() < position) {
        return nullptr;
    }

    while (submenus.count() <= position) {
        submenus.append(nullptr);
    }

    QVariant submenuData = subMenuData(position);
    if (submenuData.type() == (int)QMetaType::QVariantList) {
        AyatanaMenuModel*& model = submenus[position];
        if (!model) {
            model = new AyatanaMenuModel(this);
            connect(model, &AyatanaMenuModel::activated, this, &AyatanaMenuModel::activated);
        }
        if (model->modelData() != submenuData) {
            model->setModelData(submenuData);
        }
        return model;
    }

    return nullptr;
}

bool AyatanaMenuModel::loadExtendedAttributes(int, const QVariantMap &)
{
    return false;
}

QVariant AyatanaMenuModel::get(int row, const QByteArray &role)
{
    static QHash<QByteArray, int> roles;
    if (roles.isEmpty()) {
        const QHash<int, QByteArray> names = roleNames();
        for(auto it = names.begin(); it != names.end(); ++it)
            roles.insert(it.value(), it.key());
    }

    return data(index(row, 0), roles[role]);
}

void AyatanaMenuModel::activate(int row, const QVariant&)
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

void AyatanaMenuModel::aboutToShow(int index)
{
    Q_EMIT aboutToShowCalled(index);
}

void AyatanaMenuModel::changeState(int, const QVariant&)
{
}

void AyatanaMenuModel::registerAction(AyatanaMenuAction*)
{
}

void AyatanaMenuModel::unregisterAction(AyatanaMenuAction*)
{
}
