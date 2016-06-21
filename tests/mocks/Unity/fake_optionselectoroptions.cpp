/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "fake_optionselectoroptions.h"

#include "fake_optionselectorfilter.h"

FakeOptionSelectorOptions::FakeOptionSelectorOptions(const QStringList &optionLabels, FakeOptionSelectorFilter* parent)
 : unity::shell::scopes::OptionSelectorOptionsInterface(parent),
   m_optionLabels(optionLabels)
{
}

int FakeOptionSelectorOptions::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_optionLabels.count();
}

QVariant FakeOptionSelectorOptions::data(const QModelIndex &index, int role) const
{
    const int row = index.row();
    if (row < 0 || row >= m_optionLabels.count())
        return QVariant();

    switch (role) {
        case RoleOptionId: {
            const QString id = static_cast<FakeOptionSelectorFilter*>(parent())->filterId() + QString::number(row);
            return id;
        }
        case RoleOptionLabel:
            return m_optionLabels[row];
        case RoleOptionChecked:
            return m_checkedIndexes.contains(row);
        default:
            return QVariant();
    }

}

void FakeOptionSelectorOptions::setChecked(int row, bool checked)
{
    if (checked) {
        if (!static_cast<FakeOptionSelectorFilter*>(parent())->multiSelect()) {
            if (!m_checkedIndexes.isEmpty()) {
                setChecked(*m_checkedIndexes.begin(), false);
            }
            Q_ASSERT(m_checkedIndexes.isEmpty());
        }
        m_checkedIndexes << row;
    } else {
        m_checkedIndexes.remove(row);
    }
    const QModelIndex idx = index(row, 0);
    Q_EMIT dataChanged(idx, idx,  QVector<int>() << RoleOptionChecked);
    Q_EMIT anyCheckedChanged();
}

bool FakeOptionSelectorOptions::anyChecked() const
{
    return !m_checkedIndexes.isEmpty();
}

void FakeOptionSelectorOptions::clear()
{
    if (!m_checkedIndexes.isEmpty()) {
        auto checkedIndexes = m_checkedIndexes;
        m_checkedIndexes.clear();
        Q_FOREACH(int row, checkedIndexes) {
            const QModelIndex idx = index(row, 0);
            Q_EMIT dataChanged(idx, idx,  QVector<int>() << RoleOptionChecked);
        }
        Q_EMIT anyCheckedChanged();
    }
}
