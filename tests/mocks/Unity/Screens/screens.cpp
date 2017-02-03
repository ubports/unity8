/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "screens.h"

// Qt
#include <QGuiApplication>
#include <QDebug>

Screens::Screens(QObject *parent) :
    QAbstractListModel(parent)
{
    bool ok = false;
    int screenCount = qEnvironmentVariableIntValue("UNITY_MOCK_SCREEN_COUNT", &ok);
    if (!ok) screenCount = 1;
    QPoint lastPoint(0,0);
    for (int i = 0; i < screenCount; ++i) {
        auto screen = new Screen();
        screen->m_active = i == 0;
        screen->m_name = QString("Monitor %1").arg(i);
        screen->m_position = QPoint(lastPoint.x(), lastPoint.y());
        screen->m_sizes.append(new ScreenMode(50, QSize(640,480)));
        screen->m_sizes.append(new ScreenMode(60, QSize(1280,1024)));
        screen->m_sizes.append(new ScreenMode(60, QSize(1440,900)));
        screen->m_sizes.append(new ScreenMode(60, QSize(1920,1080)));
        screen->m_currentModeIndex = 3;
        screen->m_physicalSize = QSize(300,200);
        m_screenList.append(screen);

        lastPoint.rx() += screen->m_sizes[screen->m_currentModeIndex]->size.width();
    }
}

Screens::~Screens() noexcept
{
    qDeleteAll(m_screenList);
    m_screenList.clear();
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
    }

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

void Screens::activateScreen(int)
{
    qWarning("Not Implemented");
}

Screen::Screen(QObject* parent)
    : QObject(parent)
{
}

Screen::~Screen()
{
    qDeleteAll(m_sizes);
    m_sizes.clear();
}

QQmlListProperty<ScreenMode> Screen::availableModes()
{
    return QQmlListProperty<ScreenMode>(this, m_sizes);
}

Screen *Screen::beginConfiguration()
{
    qWarning("Not Implemented");
    return nullptr;
}

void Screen::applyConfiguration()
{
    qWarning("Not Implemented");
}
