/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "rootactionstate.h"

#include <unitymenumodel.h>
#include <QtTest>

class RootActionStateTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void testDeleteRootActionState()
    {
        UnityMenuModel* menuModel = new UnityMenuModel();
        RootActionState* rootState = new RootActionState();

        rootState->setMenu(menuModel);

        QCOMPARE(menuModel->actionStateParser(), rootState);
        delete rootState;
        QVERIFY(menuModel->actionStateParser() == NULL);

        delete menuModel;
    }

    void testDeleteUnityMenuModel()
    {
        UnityMenuModel* menuModel = new UnityMenuModel();
        RootActionState* rootState = new RootActionState();

        rootState->setMenu(menuModel);

        QCOMPARE(rootState->menu(), menuModel);
        delete menuModel;
        QVERIFY(rootState->menu() == NULL);
        delete rootState;
    }
};

QTEST_GUILESS_MAIN(RootActionStateTest)
#include "rootactionstatetest.moc"
