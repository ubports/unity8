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
 */

#include "fake_schema.h"

Schema::Schema(QObject *parent) :
    QObject(parent)
{
}

QString Schema::id() const {
    return m_id;
}

void Schema::setId(const QString &str) {
    if (str != m_id) {
        m_id = str;
        Q_EMIT idChanged(m_id);
    }
}
