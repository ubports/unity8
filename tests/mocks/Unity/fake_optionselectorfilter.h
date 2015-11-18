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

#ifndef FAKE_OPTIONSELECTORFILTER_H
#define FAKE_OPTIONSELECTORFILTER_H

#include <unity/shell/scopes/OptionSelectorFilterInterface.h>

class FakeOptionSelectorOptions;

class FakeOptionSelectorFilter : public unity::shell::scopes::OptionSelectorFilterInterface
{
    Q_OBJECT

public:
    FakeOptionSelectorFilter(const QString &id, const QString &tag, const QString &label, bool multiselect, const QStringList &optionLabels, QObject* parent);

    QString filterId() const override;
    QString filterTag() const override;
    QString title() const override;
    QString label() const override;
    bool multiSelect() const override;
    unity::shell::scopes::OptionSelectorOptionsInterface* options() const override;

    bool isActive() const;

Q_SIGNALS:
    void isActiveChanged();

private:
    QString m_filterId;
    QString m_filterTag;
    QString m_title;
    QString m_label;
    bool m_multiSelect;
    FakeOptionSelectorOptions* m_options;
};

#endif
