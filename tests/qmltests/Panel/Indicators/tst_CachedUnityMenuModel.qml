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
import "../../../../qml/Panel/Indicators"

Item {
    id: root
    width: units.gu(40)
    height: units.gu(70)

    Component {
        id: model
        CachedUnityMenuModel {}
    }

    UT.UnityTestCase {
        name: "CachedUnityMenuModel"
        when: windowShown

        function cleanup() {
            doGC();
        }

        function doGC() {
            // need to put some wait cycles here to get gc going properly.
            wait(10);
            gc();
            wait(10);
        }

        function test_createDifferent() {
            var cachedObject = model.createObject(null,
                               {
                                   "busName": "com.canonical.test1",
                                   "menuObjectPath": "/com/canonical/test1",
                                   "actionsObjectPath": "/com/canonical/test1"
                               });

            var cachedObject2 = model.createObject(null,
                               {
                                   "busName": "com.canonical.test2",
                                   "menuObjectPath": "/com/canonical/test2",
                                   "actionsObjectPath": "/com/canonical/test2"
                               });

            verify(cachedObject.model !== cachedObject2.model);
        }

        function test_createSame() {
            var cachedObject = model.createObject(null,
                               {
                                   "busName": "com.canonical.test3",
                                   "menuObjectPath": "/com/canonical/test3",
                                   "actionsObjectPath": "/com/canonical/test3"
                               });

            var cachedObject2 = model.createObject(null,
                               {
                                   "busName": "com.canonical.test3",
                                   "menuObjectPath": "/com/canonical/test3",
                                   "actionsObjectPath": "/com/canonical/test3"
                               });

            verify(cachedObject.model === cachedObject2.model);
        }

        // Tests that changing cached model data does not change the model path of others
        function test_lp1328646() {
            var cachedObject = model.createObject(null,
                               {
                                   "busName": "com.canonical.test4",
                                   "menuObjectPath": "/com/canonical/test4",
                                   "actionsObjectPath": "/com/canonical/test4"
                               });

            var cachedObject2 = model.createObject(null,
                               {
                                   "busName": "com.canonical.test4",
                                   "menuObjectPath": "/com/canonical/test4",
                                   "actionsObjectPath": "/com/canonical/test4"
                               });

            cachedObject.menuObjectPath = "/com/canonical/test5";
            compare(cachedObject.model.menuObjectPath, "/com/canonical/test5");
            compare(cachedObject2.model.menuObjectPath, "/com/canonical/test4");

            verify(cachedObject.model !== cachedObject2.model);
        }

        function createAndDestroy(test) {
            var cachedObject = model.createObject(null,
                               {
                                   "busName": "com.canonical."+test,
                                   "menuObjectPath": "/com/canonical/"+test,
                                   "actionsObjectPath": "/com/canonical/"+test
                               });
            var cachedObject2 = model.createObject(null,
                               {
                                   "busName": "com.canonical."+test,
                                   "menuObjectPath": "/com/canonical/"+test,
                                   "actionsObjectPath": "/com/canonical/"+test
                               });
            cachedObject.destroy();
            return cachedObject2;
        }

        function test_destroyAllDeletesModel() {
            createAndDestroy("test6");
            doGC();
            compare(Indicators.UnityMenuModelCache.contains("/com/canonical/test6"), false);
        }

        function test_destroyPartialKeepsModel() {
            var model = createAndDestroy("test7");
            doGC();
            compare(Indicators.UnityMenuModelCache.contains("/com/canonical/test7"), true);
        }
    }
}
