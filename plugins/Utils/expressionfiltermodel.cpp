/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include "expressionfiltermodel.h"

ExpressionFilterModel::ExpressionFilterModel(QObject *parent)
    : UnitySortFilterProxyModelQML(parent)
{
}

QJSValue ExpressionFilterModel::matchExpression() const
{
    return m_matchExpression;
}

void ExpressionFilterModel::setMatchExpression(const QJSValue &value)
{
    m_matchExpression = value;
    invalidateFilter();
}

bool
ExpressionFilterModel::filterAcceptsRow(int sourceRow,
                                           const QModelIndex &sourceParent) const
{
    if (m_matchExpression.isCallable()) {
        QJSValueList args;
        args << sourceRow;
        QJSValue ret = m_matchExpression.call(args);
        if (ret.isBool()) {
            return ret.toBool();
        }
    }

    return UnitySortFilterProxyModelQML::filterAcceptsRow(sourceRow, sourceParent);
}
