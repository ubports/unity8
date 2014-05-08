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
#include <gio/gio.h>

class RootActionStateTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void testDeleteRootActionState()
    {
        UnityMenuModel* menuModel = new UnityMenuModel();
        ActionStateParser* originalParser = menuModel->actionStateParser();
        RootActionState* rootState = new RootActionState();

        rootState->setMenu(menuModel);

        delete rootState;
        QCOMPARE(menuModel->actionStateParser(), originalParser);
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

    void testToQVariantIcons()
    {
        GVariantBuilder builderIcons;
        g_variant_builder_init(&builderIcons, G_VARIANT_TYPE_ARRAY);

        for (int i = 0; i < 3; i ++) {
            GIcon* icon = NULL;
            icon = g_icon_new_for_string (QString("testIcon%1").arg(i).toUtf8().constData(), NULL);

            g_variant_builder_add_value(&builderIcons, g_icon_serialize (icon));
            g_object_unref(icon);
        }

        GVariantBuilder builderParams;
        g_variant_builder_init(&builderParams, G_VARIANT_TYPE_ARRAY);
        GVariant* icons = g_variant_builder_end (&builderIcons);
        g_variant_ref_sink (icons);
        g_variant_builder_add (&builderParams, "{sv}", g_strdup ("icons"), icons, NULL);

        GVariant* params = g_variant_builder_end (&builderParams);

        RootActionState rootState;
        QVariant result = rootState.toQVariant(params);
        g_variant_unref(params);

        QVariantMap paramResult = result.toMap();
        QVERIFY(paramResult.contains("icons"));

        QStringList serializedIcons = paramResult["icons"].toStringList();
        QVERIFY(serializedIcons[0] == "image://theme/testIcon0");
        QVERIFY(serializedIcons[1] == "image://theme/testIcon1");
        QVERIFY(serializedIcons[2] == "image://theme/testIcon2");
    }
};

QTEST_GUILESS_MAIN(RootActionStateTest)
#include "rootactionstatetest.moc"
