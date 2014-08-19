/*
 * Copyright 2014 Canonical Ltd.
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

import QtQuick 2.0
import QtTest 1.0
import Unity.Test 0.1 as UT
import QMenuModel 0.1
import Unity.Indicators 0.1 as Indicators

Item {
    id: root
    width: units.gu(40)
    height: units.gu(70)

    Component {
        id: model
        Indicators.CachedUnityMenuModel {}
    }

    UT.UnityTestCase {
        name: "CachedUnityMenuModel"
        when: windowShown

        function test_createDifferent() {
            var cachedObject = model.createObject(root,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "com/canonical/test1",
                                   "actionsObjectPath": "com/canonical/test1/actions"
                               });

            var cachedObject2 = model.createObject(root,
                               {
                                   "busName": "com.canonical.test2",
                                   "menuObjectPath": "com/canonical/test2",
                                   "actionsObjectPath": "com/canonical/test2/actions"
                               });

            verify(cachedObject.model !== cachedObject2.model);

            cachedObject.destroy();
            cachedObject2.destroy();
        }

        function test_createSame() {
            var cachedObject = model.createObject(root,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "com/canonical/test1",
                                   "actionsObjectPath": "com/canonical/test1/actions"
                               });

            var cachedObject2 = model.createObject(root,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "com/canonical/test1",
                                   "actionsObjectPath": "com/canonical/test1/actions"
                               });

            verify(cachedObject.model === cachedObject2.model);

            cachedObject.destroy();
            cachedObject2.destroy();
        }

        function test_destroyAllDeletesModel() {
            var cachedObject = model.createObject(root,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "com/canonical/test1",
                                   "actionsObjectPath": "com/canonical/test1/actions"
                               });

            var cachedObject2 = model.createObject(root,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "com/canonical/test1",
                                   "actionsObjectPath": "com/canonical/test1/actions"
                               });

            var menuModel = cachedObject.model;
            cachedObject.destroy();
            cachedObject2.destroy();
            tryCompareFunction(function() { return Indicators.UnityMenuModelCache.contains(menuModel) }, false);
        }

        function test_destroyPartialKeepsModel() {
            var cachedObject = model.createObject(root,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "com/canonical/test1",
                                   "actionsObjectPath": "com/canonical/test1/actions"
                               });

            var cachedObject2 = model.createObject(root,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "com/canonical/test1",
                                   "actionsObjectPath": "com/canonical/test1/actions"
                               });

            var menuModel = cachedObject.model;
            cachedObject.destroy();
            wait(1);
            compare(Indicators.UnityMenuModelCache.contains(menuModel), true);
        }
    }
}
