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

#ifndef ACTIONDATA_H
#define ACTIONDATA_H

#include <QObject>
#include <QVariant>

typedef struct _GVariant GVariant;

class Q_DECL_EXPORT ActionData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant data READ data WRITE setData NOTIFY dataChanged)
public:
    ActionData(QObject* parent = 0)
        : QObject(parent)
        , m_data(QVariantMap())
    {
    }

    QVariant data() const { return m_data; }
    void setData(const QVariant& data)
    {
        if (m_data != data) {
            m_data = data;
            Q_EMIT dataChanged();
        }
    }

Q_SIGNALS:
    void dataChanged();

private:
    QVariant m_data;
};

#endif // ACTIONDATA_H
