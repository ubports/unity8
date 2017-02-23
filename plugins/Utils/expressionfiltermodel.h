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

#ifndef EXPRESSIONFILTERMODEL_H
#define EXPRESSIONFILTERMODEL_H

#include "unitysortfilterproxymodelqml.h"
#include <QJSValue>

class ExpressionFilterModel : public UnitySortFilterProxyModelQML
{
    Q_OBJECT
    Q_PROPERTY(QJSValue matchExpression READ matchExpression WRITE setMatchExpression NOTIFY matchExpressionChanged)
public:
    explicit ExpressionFilterModel(QObject *parent = 0);

    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

    QJSValue matchExpression() const;
    void setMatchExpression(const QJSValue& value);

Q_SIGNALS:
    void matchExpressionChanged();

private:
    mutable QJSValue m_matchExpression;
};

#endif // EXPRESSIONFILTERMODEL_H
