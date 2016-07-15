/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include <QString>
#include <QVariant>

#include "MockOperation.h"

MockOperation::MockOperation(QObject *parent)
    : QObject(parent)
    , m_observer(nullptr)
{
}

bool MockOperation::running() const
{
    return m_observer != nullptr;
}

void MockOperation::start(QObject *observer)
{
    if (!m_observer)
        m_observer = observer;
}

void MockOperation::cancel()
{
    m_observer = nullptr;
}

void MockOperation::mockSuccess(unsigned int uid)
{
    if (m_observer)
        QMetaObject::invokeMethod(m_observer, "succeeded", Qt::DirectConnection,
                                  Q_ARG(QVariant, QVariant::fromValue(uid)));
}

void MockOperation::mockFailure(const QString &reason)
{
    if (m_observer)
        QMetaObject::invokeMethod(m_observer, "failed", Qt::DirectConnection,
                                  Q_ARG(QString, reason));
}
