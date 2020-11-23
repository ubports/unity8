/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef MOCK_SCREENS_H
#define MOCK_SCREENS_H

#include <QAbstractListModel>
#include <QSharedPointer>

#include <qtmir/screens.h>

namespace qtmir
{
class Screens;
}

class ConcreteScreen;
class ScreenWindow;

class MockScreens : public qtmir::Screens
{
    Q_OBJECT
public:
    MockScreens();
    ~MockScreens();

    QVector<qtmir::Screen*> screens() const override;

    qtmir::Screen *activeScreen() const override;

    static QSharedPointer<MockScreens> instance();

public Q_SLOTS:
    void connectWindow(ScreenWindow *w);

private:
    QVector<qtmir::Screen*> m_mocks;
};


#endif // MOCK_SCREENS_H
