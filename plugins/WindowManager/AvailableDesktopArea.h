/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#ifndef AVAILABLEDESKTOPAREA_H
#define AVAILABLEDESKTOPAREA_H

#include <QQuickItem>

/**
    @brief Used to inform qtmir/miral about the available desktop area of shell

    So that qtmir/miral can take correct window management decisions.
 */
class AvailableDesktopArea : public QQuickItem
{
    Q_OBJECT
public:
    AvailableDesktopArea(QQuickItem *parent = nullptr);
protected:
    void itemChange(ItemChange change, const ItemChangeData &value) override;
private Q_SLOTS:
    void updatePlatformWindowProperty();
};

#endif // AVAILABLEDESKTOPAREA_H
