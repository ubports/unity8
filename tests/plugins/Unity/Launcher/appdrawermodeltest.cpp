/*
 * Copyright 2017 Canonical Ltd.
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
 */

#include "ualwrapper.h"
#include "xdgwatcher.h"
#include "appdrawermodel.h"

#include <QtTest>

class AppDrawerModelTest : public QObject
{
    Q_OBJECT

private:
    AppDrawerModel *appDrawerModel;

private Q_SLOTS:

    void initTestCase() {
        UalWrapper::s_list << QStringLiteral("app1") << QStringLiteral("app2");
        appDrawerModel = new AppDrawerModel(this);
        QCOMPARE(appDrawerModel->rowCount(QModelIndex()), 2);
    }

    void testUalAppAddedRemoved() {
        QCOMPARE(appDrawerModel->rowCount(QModelIndex()), 2);

        UalWrapper::instance()->addMockApp("app3");
        XdgWatcher::instance()->addMockApp("app3");
        qApp->processEvents(); // ualwrapper is connected Queued

        QCOMPARE(appDrawerModel->rowCount(QModelIndex()), 3);

        UalWrapper::instance()->removeMockApp("app3");
        XdgWatcher::instance()->removeMockApp("app3");
        qApp->processEvents();

        QCOMPARE(appDrawerModel->rowCount(QModelIndex()), 2);
    }
};

QTEST_GUILESS_MAIN(AppDrawerModelTest)
#include "appdrawermodeltest.moc"
