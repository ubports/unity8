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
#include <QScreen>
#include <QDebug>

Q_DECLARE_METATYPE(QScreen*)

Screens::Screens(QObject *parent) :
    QAbstractListModel(parent)
{
    bool ok = false;
    int screenCount = qEnvironmentVariableIntValue("UNITY_MOCK_SCREEN_COUNT", &ok);
    if (!ok) screenCount = 1;
    QPoint lastPoint(0,0);
    for (int i = 0; i < screenCount; ++i) {
        auto screen = new Screen();
        screen->enabled = i == 0;
        screen->name = QString("Monitor %1").arg(i);
        screen->sizes = { QSize(640,480), QSize(1024,748), QSize(1280,1024), QSize(1440,900), QSize(1920,1080) };
        screen->geometry = QRect(lastPoint.x(), lastPoint.y(), 1024, 786 );
        m_screenList.append(screen);

        lastPoint.rx() += screen->geometry.width();
    }
}

Screens::~Screens()
{
    qDeleteAll(m_screenList);
    m_screenList.clear();
}

QHash<int, QByteArray> Screens::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ScreenRole] = "screen";
    roles[OutputTypeRole] = "outputType";
    roles[EnabledRole] = "enabled";
    roles[NameRole] = "name";
    roles[ScaleRole] = "scale";
    roles[FormFactorRole] = "formFactor";
    roles[GeometryRole] = "geometry";
    roles[SizesRole] = "sizes";
    return roles;
}

QVariant Screens::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_screenList.size()) {
        return QVariant();
    }

    switch(role) {
    case ScreenRole:
        return QVariant::fromValue(m_screenList.at(index.row())->qScreen);
    case OutputTypeRole:
        return m_screenList.at(index.row())->outputTypes;
    case EnabledRole:
        return m_screenList.at(index.row())->enabled;
    case NameRole:
        return m_screenList.at(index.row())->name;
    case ScaleRole:
        return m_screenList.at(index.row())->scale;
    case FormFactorRole:
        return m_screenList.at(index.row())->formFactor;
    case GeometryRole:
        return m_screenList.at(index.row())->geometry;
    case SizesRole:
        {
            QVariantList sizes;
            auto availableSizes = m_screenList.at(index.row())->sizes;
            Q_FOREACH(auto size, availableSizes) {
                sizes.append(QVariant(size));
            }
            return sizes;
        }
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
