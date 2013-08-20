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

// self
#include "genericoptionsmodel.h"

// local
#include "abstractfilteroption.h"

GenericOptionsModel::GenericOptionsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

GenericOptionsModel::~GenericOptionsModel()
{
    Q_FOREACH(auto opt, m_options)
    {
        opt->deleteLater();
    }
}

QHash<int, QByteArray> GenericOptionsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[GenericOptionsModel::RoleId] = "id";
    roles[GenericOptionsModel::RoleName] = "name";
    roles[GenericOptionsModel::RoleIconHint] = "iconHint";
    roles[GenericOptionsModel::RoleActive] = "active";
    return roles;
}

QVariant GenericOptionsModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    auto filterOption = m_options[index.row()];
    switch (role)
    {
        case GenericOptionsModel::RoleId:
            return filterOption->id();
        case GenericOptionsModel::RoleName:
        case Qt::DisplayRole:
            return filterOption->name();
        case GenericOptionsModel::RoleIconHint:
            return filterOption->iconHint();
        case GenericOptionsModel::RoleActive:
            return filterOption->active();
        default:
            break;
    }

    return QVariant();
}

int GenericOptionsModel::rowCount(const QModelIndex& /* parent */) const
{
    return m_options.size ();
}

void GenericOptionsModel::setActive(QVector<AbstractFilterOption *>::size_type idx, bool value)
{
    if (idx < m_options.size())
    {
        m_options[idx]->setActive(value);
    }
}

AbstractFilterOption* GenericOptionsModel::getRawOption(QVector<AbstractFilterOption *>::size_type idx) const
{
    if (idx < m_options.size())
    {
        return m_options[idx];
    }
    return nullptr;
}

void GenericOptionsModel::ensureTheOnlyActive(AbstractFilterOption *activeOption)
{
    if (activeOption->active()) {
        // disable all other options
        Q_FOREACH(auto opt, m_options) {
            if (opt != activeOption && opt->active()) {
                opt->setActive(false);
            }
        }
    }
}

void GenericOptionsModel::addOption(AbstractFilterOption *option, int index)
{
    m_options.insert(index, option);

    connect(option, SIGNAL(idChanged(const QString &)), this, SLOT(onOptionChanged()));
    connect(option, SIGNAL(nameChanged(const QString &)), this, SLOT(onOptionChanged()));
    connect(option, SIGNAL(iconHintChanged(const QString &)), this, SLOT(onOptionChanged()));
    connect(option, SIGNAL(activeChanged(bool)), this, SLOT(onOptionChanged()));
    connect(option, SIGNAL(activeChanged(bool)), this, SLOT(onActiveChanged()));
}

void GenericOptionsModel::removeOption(int index)
{
    m_options[index]->deleteLater();
    m_options.remove(index);
}

int GenericOptionsModel::indexOf(const QString &option_id)
{
    int row = 0;
    Q_FOREACH(auto opt, m_options)
    {
        if (opt->id() == option_id)
        {
            return row;
        }
        ++row;
    }
    return -1;
}

void GenericOptionsModel::onOptionChanged()
{
    AbstractFilterOption *option = dynamic_cast<AbstractFilterOption*>(QObject::sender());
    if (option)
    {
        int idx = indexOf(option->id());
        if (idx >= 0)
        {
            QModelIndex optionIndex = index(idx);
            Q_EMIT dataChanged(optionIndex, optionIndex);
        }
    }
}

void GenericOptionsModel::onActiveChanged()
{
    AbstractFilterOption *option = dynamic_cast<AbstractFilterOption*>(QObject::sender());
    if (option)
    {
        Q_EMIT activeChanged(option);
    }
}
