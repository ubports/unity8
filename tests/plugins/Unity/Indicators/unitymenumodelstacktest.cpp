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
 *
 * Authors:
 *  Nick Dedekind <nick.dedekind@canonical.com>
 */

#include "indicatorsmanager.h"
#include "paths.h"
#include "unitymenumodelstack.h"

#include <QtTest>
#include <QDebug>

#include <glib.h>
#include <gio/gio.h>
#include <unitymenumodel.h>

 #define BUS_NAME       "com.canonical.unity8.unitymenumodelstacktest"
 #define OBJECT_PATH    "/com/canonical/unity8/unitymenumodelstack"

static void on_bus_acquired (GDBusConnection *bus, const gchar *name, gpointer user_data);
static void on_name_aquired (GDBusConnection *bus, const gchar *name, gpointer user_data);
static void on_name_lost (GDBusConnection *bus, const gchar *name, gpointer user_data);


class UnityMenuModelStackTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void initTestCase()
    {
        m_menuUid = 0;
        m_connection = NULL;
        m_connected = NULL;
        m_failed = false;
        m_menu = NULL;

        GBusNameOwnerFlags flags;
        flags = (GBusNameOwnerFlags) (G_BUS_NAME_OWNER_FLAGS_ALLOW_REPLACEMENT | G_BUS_NAME_OWNER_FLAGS_REPLACE);

        g_bus_own_name (G_BUS_TYPE_SESSION, BUS_NAME, flags,
                on_bus_acquired, on_name_aquired, on_name_lost, this, NULL);
    }

    void cleanupTestCase()
    {
        if (m_connection) {
            g_object_unref(m_connection);
            m_connection = NULL;
        }
    }

    void init()
    {
        QFETCH(QString, test);
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);

        waitFor([this]() { return this->m_connected || this->m_failed; }, 500);
        QVERIFY(m_connected);

        const QString& path = QString(OBJECT_PATH) + "/" + test;

        m_menuUid = exportMenuModel(&m_menu, m_connection, path, subMenuCount, menuDepth);

        m_model = new UnityMenuModel;
        m_model->setBusName(BUS_NAME);
        m_model->setMenuObjectPath(path.toUtf8());
    }

    void cleanup() {
        if (m_model) {
            delete m_model;
            m_model = NULL;
        }
        if (m_menuUid != 0) {
            g_dbus_connection_unexport_menu_model(m_connection, m_menuUid);
            m_menuUid = 0;
        }
        if (m_menu) {
            g_object_unref(m_menu);
        }
    }


    void testPushPop_data() {
        QTest::addColumn<QString>("test");
        QTest::addColumn<int>("menuDepth");
        QTest::addColumn<int>("subMenuCount");
        QTest::addColumn<int>("subMenuIndex");

        QTest::newRow("depth=0") << "testPushPop1" << 0 << 1 << 0;
        QTest::newRow("depth=1") << "testPushPop2" << 1 << 1 << 0;
        QTest::newRow("depth=8") << "testPushPop3" << 8 << 2 << 1;
    }

    void testPushPop()
    {
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);
        QFETCH(int, subMenuIndex);

        UnityMenuModelStack stack;
        QList<UnityMenuModel*> models;

        UnityMenuModel* parent = m_model;
        UnityMenuModel* child = m_model;

        while(child) {
            // submenus aren't immediate
            bool rows = waitFor([child, subMenuCount]() { return child->rowCount() == subMenuCount; }, 500);
            QVERIFY(rows);

            stack.push(child, subMenuIndex);
            models << child;

            parent = child;
            child = qobject_cast<UnityMenuModel*>(parent->submenu(subMenuIndex));
        }

        QCOMPARE(stack.count(), models.count());
        QCOMPARE(stack.count(), menuDepth+1);
        while(stack.count() > 0) {
            QCOMPARE(stack.pop(), models.takeLast());
        }
    }

    void testPopOnRemove_data() {
        QTest::addColumn<QString>("test");
        QTest::addColumn<int>("menuDepth");
        QTest::addColumn<int>("subMenuCount");
        QTest::addColumn<int>("subMenuIndex");
        QTest::addColumn<int>("removeIndex");
        QTest::addColumn<int>("resultCount");

        QTest::newRow("removeIndexBefore") << "removeIndexBefore" << 4 << 2 << 1 << 0 << 5;
        QTest::newRow("removeCurrentIndex") << "removeCurrentIndex" << 4 << 2 << 0 << 0 << 1;
        QTest::newRow("removeIndexAfter") << "removeIndexAfter" << 4 << 2 << 0 << 1 << 5;
    }

    void testPopOnRemove()
    {
        QFETCH(int, menuDepth);
        QFETCH(int, subMenuCount);
        QFETCH(int, subMenuIndex);
        QFETCH(int, removeIndex);
        QFETCH(int, resultCount);

        UnityMenuModelStack stack;

        UnityMenuModel* parent = m_model;
        UnityMenuModel* child = m_model;

        while(child) {
            // submenus aren't immediate
            bool rows = waitFor([child, subMenuCount]() { return child->rowCount() == subMenuCount; }, 1000);
            QVERIFY(rows);

            stack.push(child, subMenuIndex);

            parent = child;
            child = qobject_cast<UnityMenuModel*>(parent->submenu(subMenuIndex));
        }

        QCOMPARE(stack.count(), menuDepth+1);
        g_menu_remove(m_menu, removeIndex);

        waitFor([&stack, resultCount]() { return stack.count() == resultCount; }, 1000);
        QCOMPARE(stack.count(), resultCount);
    }

private:
    bool waitFor(std::function<bool()> functor, int ms) {

        QElapsedTimer timer;
        timer.start();
        while(!functor() && timer.elapsed() < ms) { QTest::qWait(10); }
        return functor();
    }
    guint exportMenuModel(GMenu** menu, GDBusConnection* connection, const QString& object_path, int submenuCount, int depth);

public:
    GDBusConnection* m_connection;
    bool m_failed;
    bool m_connected;
    guint m_menuUid;
    GMenu* m_menu;
    UnityMenuModel* m_model;
};

void recuseAddMenu(GMenu* menu, int subMenuCount, int depth_remaining)
{
    for (int i = 0; i < subMenuCount; i ++) {
        GMenuItem* item = g_menu_item_new("", NULL);

        if (depth_remaining > 0) {
            GMenu* submenu = g_menu_new ();
            recuseAddMenu(submenu, subMenuCount, depth_remaining-1);
            g_menu_item_set_submenu (item, G_MENU_MODEL (submenu));
        }

        g_menu_append_item (menu, item);
    }
}

guint UnityMenuModelStackTest::exportMenuModel(GMenu** menu, GDBusConnection* connection, const QString& object_path, int submenuCount, int depth)
{
    *menu=g_menu_new();
    recuseAddMenu(*menu, submenuCount, depth);

    QByteArray path = object_path.toUtf8();

    return g_dbus_connection_export_menu_model (connection, path.constData(), G_MENU_MODEL (*menu), NULL);
}

static void
on_bus_acquired (GDBusConnection *bus, const gchar *, gpointer user_data)
{
    UnityMenuModelStackTest* test = (UnityMenuModelStackTest*)user_data;
    test->m_connection = bus;
}

static void
on_name_aquired (GDBusConnection*, const gchar*, gpointer user_data)
{
    UnityMenuModelStackTest* test = (UnityMenuModelStackTest*)user_data;
    test->m_connected = true;
    test->m_failed = false;
}


static void
on_name_lost (GDBusConnection*, const gchar*, gpointer user_data)
{
    UnityMenuModelStackTest* test = (UnityMenuModelStackTest*)user_data;
    test->m_connected = false;
    test->m_failed = true;
}

QTEST_GUILESS_MAIN(UnityMenuModelStackTest)
#include "unitymenumodelstacktest.moc"
