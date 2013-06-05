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
 * Author: Pete Woods <pete.woods@canonical.com>
 */

#ifndef INFOGRAPHICMODEL_PRIVATE_H
#define INFOGRAPHICMODEL_PRIVATE_H

#include <QtCore/QSharedPointer>

#include "InfographicModel.h"
#include "plugins/Utils/qvariantlistmodel.h"

namespace QLightDM
{
class InfographicDataPrivate;

class Q_DECL_EXPORT InfographicData: public QObject
{
public:
    explicit InfographicData(QObject *parent);

    InfographicData(const QString &label,
            const InfographicColorTheme &firstColor,
            const QVariantList &firstMonth,
            const InfographicColorTheme &secondColor,
            const QVariantList &secondMonth, QObject* parent);

    ~InfographicData();

protected:
    InfographicDataPrivate * const d_ptr;

public:
    const QString & label() const;
    const InfographicColorTheme & firstColor() const;
    const QVariantList & firstMonth() const;
    const InfographicColorTheme & secondColor() const;
    const QVariantList & secondMonth() const;
    int length() const;

private:
    Q_DECLARE_PRIVATE(InfographicData)
};

class InfographicModelPrivate: QObject
{

public:
    explicit InfographicModelPrivate(InfographicModel *parent);

    ~InfographicModelPrivate();

public:
    typedef QSharedPointer<InfographicData> InfographicDataPtr;
    typedef QMultiMap<QString, InfographicDataPtr> FakeDataMap;

    InfographicModel * const q_ptr;
    QString m_label;
    InfographicColorTheme m_firstColor;
    QVariantListModel m_firstMonth;
    InfographicColorTheme m_secondColor;
    QVariantListModel m_secondMonth;
    int m_currentDay;
    QString m_username;
    FakeDataMap::const_iterator m_dataIndex;
    InfographicDataPtr m_newData;
    FakeDataMap m_fakeData;

    void setUsername(const QString &username);

protected:
    void nextFakeData();

    void generateFakeData();

    void loadFakeData();

    void finishSetFakeData();

private:
    Q_DECLARE_PUBLIC(InfographicModel)
};
}

#endif // INFOGRAPHICMODEL_PRIVATE_H
