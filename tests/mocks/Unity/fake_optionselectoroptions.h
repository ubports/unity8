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

#ifndef FAKE_OPTIONSELECTOROPTIONS_H
#define FAKE_OPTIONSELECTOROPTIONS_H

#include <unity/shell/scopes/OptionSelectorFilterInterface.h>

#include <QSet>

class FakeOptionSelectorFilter;

class FakeOptionSelectorOptions : public unity::shell::scopes::OptionSelectorOptionsInterface
{
    Q_OBJECT

public:
    FakeOptionSelectorOptions(const QStringList &optionLabels, FakeOptionSelectorFilter* parent);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    Q_INVOKABLE void setChecked(int index, bool checked) override;

    bool anyChecked() const;

Q_SIGNALS:
    void anyCheckedChanged();

private:
    QStringList m_optionLabels;
    QSet<int> m_checkedIndexes;
};

#endif
