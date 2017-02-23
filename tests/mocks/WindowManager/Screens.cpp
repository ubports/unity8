/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Screens.h"
#include "Screen.h"

// qtmirserver
#include <qtmir/qtmir.h>
#include <qtmir/screens.h>
#include <QGuiApplication>

// Qt
#include <QScreen>
#include <QWindow>

Screens::Screens(QObject *parent)
    : QAbstractListModel(parent)
{
    bool ok = false;
    int screenCount = qEnvironmentVariableIntValue("UNITY_MOCK_SCREEN_COUNT", &ok);
    if (!ok) screenCount = 1;
    QPoint lastPoint(0,0);
    for (int i = 0; i < screenCount; ++i) {
        auto screen = new Screen();
        screen->m_id = qtmir::OutputId{i};
        screen->m_active = i == 0;
        screen->m_name = QString("Monitor %1").arg(i);
        screen->m_position = QPoint(lastPoint.x(), lastPoint.y());
        screen->m_sizes.append(new qtmir::ScreenMode(50, QSize(640,480)));
        screen->m_sizes.append(new qtmir::ScreenMode(60, QSize(1280,1024)));
        screen->m_sizes.append(new qtmir::ScreenMode(60, QSize(1440,900)));
        screen->m_sizes.append(new qtmir::ScreenMode(60, QSize(1920,1080)));
        screen->m_currentModeIndex = 3;
        screen->m_physicalSize = QSize(800,568);
        m_screenList.append(screen);

        lastPoint.rx() += screen->m_sizes[screen->m_currentModeIndex]->size.width();
    }
}

QHash<int, QByteArray> Screens::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ScreenRole] = "screen";
    return roles;
}

QVariant Screens::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_screenList.size()) {
        return QVariant();
    }

    switch(role) {
    case ScreenRole:
        return QVariant::fromValue(m_screenList.at(index.row()));
    } // switch

    return QVariant();
}

int Screens::rowCount(const QModelIndex &) const
{
    return count();
}

int Screens::count() const
{
    return m_screenList.size();
}

QVariant Screens::activeScreen() const
{
    for (int i = 0; i < m_screenList.count(); i++) {
        if (m_screenList[i]->isActive()) return i;
    }
    return QVariant();
}

void Screens::activateScreen(const QVariant& vindex)
{
    bool ok = false;
    int index = vindex.toInt(&ok);
    if (!ok || index < 0 || m_screenList.count() <= index) return;

    auto screen = m_screenList.at(index);
    screen->setActive(true);
}
