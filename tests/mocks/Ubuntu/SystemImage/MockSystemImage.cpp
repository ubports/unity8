/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

#include <QDebug>
#include <QTimer>

#include "MockSystemImage.h"

MockSystemImage::MockSystemImage(QObject *parent)
    : QObject(parent)
{
}

void MockSystemImage::checkForUpdate()
{
    qDebug() << "Doing a fake system update check";
}

void MockSystemImage::applyUpdate()
{
    qDebug() << "Applying a fake system update";
    setUpdateApplying(true);
    QTimer::singleShot(3000, [this] {setUpdateApplying(false);});
}

void MockSystemImage::factoryReset()
{
    Q_EMIT resettingDevice();
}

void MockSystemImage::setUpdateApplying(bool status)
{
    if (status != m_updateApplying) {
        m_updateApplying = status;
        Q_EMIT updateApplyingChanged();
    }
}
