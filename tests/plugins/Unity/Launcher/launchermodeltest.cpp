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
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

// unity-api
#include <unity/shell/launcher/LauncherModelInterface.h>
#include <unity/shell/application/ApplicationInfoInterface.h>

#include "launcheritem.h"
#include "launchermodel.h"
#include "dbusinterface.h"

#include <QtTest>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDomDocument>

// This is a mock, specifically to test the LauncherModel
class MockApp: public unity::shell::application::ApplicationInfoInterface
{
    Q_OBJECT
public:
    MockApp(const QString &appId, QObject *parent = 0): ApplicationInfoInterface(appId, parent), m_appId(appId), m_focused(false) { }
    QString appId() const { return m_appId; }
    QString name() const { return "mock"; }
    QString comment() const { return "this is a mock"; }
    QUrl icon() const { return QUrl(); }
    ApplicationInfoInterface::Stage stage() const { return ApplicationInfoInterface::MainStage; }
    ApplicationInfoInterface::State state() const { return ApplicationInfoInterface::Running; }
    bool focused() const { return m_focused; }
    QString splashTitle() const override { return QString(); }
    QUrl splashImage() const override { return QUrl(); }
    bool splashShowHeader() const override { return true; }
    QColor splashColor() const override { return QColor(0,0,0,0); }
    QColor splashColorHeader() const override { return QColor(0,0,0,0); }
    QColor splashColorFooter() const override { return QColor(0,0,0,0); }

    // Methods used for mocking (not in the interface)
    void setFocused(bool focused) { m_focused = focused; Q_EMIT focusedChanged(focused); }
private:
    QString m_appId;
    bool m_focused;
};

// This is a mock, specifically to test the LauncherModel
class MockAppManager: public unity::shell::application::ApplicationManagerInterface
{
    Q_OBJECT
public:
    MockAppManager(QObject *parent = 0): ApplicationManagerInterface(parent) {}
    int rowCount(const QModelIndex &) const { return m_list.count(); }
    QVariant data(const QModelIndex &, int ) const { return QVariant(); }
    QString focusedApplicationId() const {
        Q_FOREACH(MockApp *app, m_list) {
            if (app->focused()) return app->appId();
        }
        return QString();
    }
    unity::shell::application::ApplicationInfoInterface *get(int index) const { return m_list.at(index); }
    unity::shell::application::ApplicationInfoInterface *findApplication(const QString &appId) const {
        Q_FOREACH(MockApp* app, m_list) {
            if (app->appId() == appId) {
                return app;
            }
        }
        return nullptr;
    }
    unity::shell::application::ApplicationInfoInterface *startApplication(const QString &, const QStringList &) { return nullptr; }
    bool stopApplication(const QString &) { return false; }
    bool focusApplication(const QString &appId) {
        Q_FOREACH(MockApp* app, m_list) {
            app->setFocused(app->appId() == appId);
        }
        Q_EMIT focusedApplicationIdChanged();
        return true;
    }

    void unfocusCurrentApplication() { }

    void addApplication(MockApp *app) {
        beginInsertRows(QModelIndex(), count(), count());
        m_list.append(app);
        endInsertRows();
    }
    void removeApplication(int index) {
        beginRemoveRows(QModelIndex(), index, index);
        m_list.takeAt(index)->deleteLater();
        endRemoveRows();
    }
    bool requestFocusApplication(const QString &appId) { Q_UNUSED(appId); return true; }
    bool suspended() const { return false; }
    void setSuspended(bool) {}
    bool dashActive() const { return false; }
    void setDashActive(bool) {}

private:
    QList<MockApp*> m_list;
};

class LauncherModelTest : public QObject
{
    Q_OBJECT

private:
    LauncherModel *launcherModel;
    MockAppManager *appManager;

private Q_SLOTS:

    void initTestCase() {
        launcherModel = new LauncherModel(this);
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 0);

        appManager = new MockAppManager(this);
        launcherModel->setApplicationManager(appManager);
    }

    // Adding 2 apps to the mock appmanager. Both should appear in the launcher.
    void init() {
        appManager->addApplication(new MockApp("abs-icon"));
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);

        appManager->addApplication(new MockApp("no-icon"));
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);
    }

    // Removing apps from appmanager and launcher as pinned ones would stick
    void cleanup() {
        while (appManager->count() > 0) {
            appManager->removeApplication(0);
        }
        while (launcherModel->rowCount(QModelIndex()) > 0) {
            launcherModel->requestRemove(launcherModel->get(0)->appId());
        }
    }

    void testMove() {
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);

        LauncherItemInterface *item0BeforeMove = launcherModel->get(0);
        LauncherItemInterface *item1BeforeMove = launcherModel->get(1);
        launcherModel->move(1, 0);

        QCOMPARE(item0BeforeMove, launcherModel->get(1));
        QCOMPARE(item1BeforeMove, launcherModel->get(0));

        // moved item must be pinned now
        QCOMPARE(item0BeforeMove->pinned(), false);
        QCOMPARE(item1BeforeMove->pinned(), true);
    }

    void testPinning() {
        QSignalSpy spy(launcherModel, SIGNAL(dataChanged(QModelIndex,QModelIndex,QVector<int>)));
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        launcherModel->pin(launcherModel->get(0)->appId());
        QCOMPARE(launcherModel->get(0)->pinned(), true);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        QCOMPARE(spy.count(), 1);
        QCOMPARE(spy.at(0).at(2).value<QVector<int>>().first(), (int)LauncherModelInterface::RolePinned);

        launcherModel->requestRemove(launcherModel->get(0)->appId());
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        QCOMPARE(spy.count(), 2);
        QCOMPARE(spy.at(1).at(2).value<QVector<int>>().first(), (int)LauncherModelInterface::RolePinned);
    }

    void testRemove_data() {

        QTest::addColumn<bool>("pinned");
        QTest::addColumn<bool>("running");

        QTest::newRow("non-pinned, running") << false << true;
        QTest::newRow("pinned, running") << true << false;
        QTest::newRow("pinned, non-running") << true << false;
    }

    void testRemove() {
        QFETCH(bool, pinned);
        QFETCH(bool, running);

        // In the beginning we always have two items
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        // pin one if required
        if (pinned) {
            launcherModel->pin(launcherModel->get(1)->appId());
        }

        // stop it if required
        if (!running) {
            appManager->removeApplication(1);
        }

        // Now remove it
        launcherModel->requestRemove(launcherModel->get(1)->appId());

        if (running) {
            // both apps are running, both apps must still be here
            QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

           // Item must be unpinned now
           QCOMPARE(launcherModel->get(1)->pinned(), false);

        } else if (pinned) {
           // Item 1 must go away, item 0 is here to stay
            QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
        }

        // done our checks. now stop the app if was still running
        if (running) {
            appManager->removeApplication(1);
        }

        // It needs to go away in any case now
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
    }

    void testQuickListPinningRemoving() {
        // we start with 2 unpinned items
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        // find the Pin item in the quicklist
        QuickListModel *model = qobject_cast<QuickListModel*>(launcherModel->get(0)->quickList());
        int pinActionIndex = -1;
        for (int i = 0; i < model->rowCount(QModelIndex()); ++i) {
            if (model->get(i).actionId() == "pin_item") {
                pinActionIndex = i;
                break;
            }
        }
        QVERIFY(pinActionIndex >= 0);

        // trigger pin item quicklist action => Item must be pinned now.
        launcherModel->quickListActionInvoked(launcherModel->get(0)->appId(), pinActionIndex);
        QCOMPARE(launcherModel->get(0)->pinned(), true);
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        // quicklist needs to transform to remove item. trigger it and check it item goes away
        launcherModel->quickListActionInvoked(launcherModel->get(0)->appId(), pinActionIndex);
        QCOMPARE(launcherModel->get(0)->pinned(), false);

        // still needs to be here as the app is still here
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);
        // close the app
        appManager->removeApplication(0);
        // Now it needs to go away
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
    }

    void testApplicationFocused() {
        // all apps unfocused at beginning...
        QCOMPARE(launcherModel->get(0)->focused(), false);
        QCOMPARE(launcherModel->get(1)->focused(), false);

        appManager->focusApplication("abs-icon");
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);
        QCOMPARE(launcherModel->get(0)->focused(), true);
        QCOMPARE(launcherModel->get(1)->focused(), false);

        appManager->focusApplication("no-icon");
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);
        QCOMPARE(launcherModel->get(0)->focused(), false);
        QCOMPARE(launcherModel->get(1)->focused(), true);
    }

    void testClosingApps() {
        // At the start there are 2 items. Let's pin one.
        launcherModel->pin("abs-icon");
        while (appManager->count() > 0) {
            appManager->removeApplication(0);
        }
        // The pinned one needs to stay, the other needs to disappear
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
        QCOMPARE(launcherModel->get(0)->appId(), QLatin1String("abs-icon"));
    }

    void testGetUrlForAppId() {
        QCOMPARE(launcherModel->getUrlForAppId(QString()), QString());
        QCOMPARE(launcherModel->getUrlForAppId(""), QString());
        QCOMPARE(launcherModel->getUrlForAppId("no-name"), QString("application:///no-name.desktop"));
        QCOMPARE(launcherModel->getUrlForAppId("com.test.good"), QString("application:///com.test.good.desktop"));
        QCOMPARE(launcherModel->getUrlForAppId("com.test.good_application"), QString("appid://com.test.good/application/current-user-version"));
        QCOMPARE(launcherModel->getUrlForAppId("com.test.good_application_1.2.3"), QString("appid://com.test.good/application/current-user-version"));
    }

    void testIntrospection() {
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher", "org.freedesktop.DBus.Introspectable");
        QDBusReply<QString> reply = interface.call("Introspect");
        QStringList nodes = extractNodes(reply.value());
        QCOMPARE(nodes.count(), launcherModel->rowCount());

        appManager->addApplication(new MockApp("foobar"));
        reply = interface.call("Introspect");
        nodes = extractNodes(reply.value());
        QCOMPARE(nodes.contains("foobar"), true);

        appManager->removeApplication(2);
        reply = interface.call("Introspect");
        nodes = extractNodes(reply.value());
        QCOMPARE(nodes.contains("foobar"), false);
    }

    QStringList extractNodes(const QString &introspectionXml) {
        QXmlStreamReader introspectReply(introspectionXml);

        QStringList ret;
        while (!introspectReply.atEnd() && !introspectReply.hasError()) {
            QXmlStreamReader::TokenType token = introspectReply.readNext();

            if (token == QXmlStreamReader::StartElement) {
                if (introspectReply.name() == "node" && introspectReply.attributes().count() > 0) {
                    ret  << introspectReply.attributes().value("name").toString();
                }
            }
        }
        return ret;
    }

    void testCountEmblems() {
        // Call GetAll on abs-icon
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher/abs_2Dicon", "org.freedesktop.DBus.Properties");
        QDBusReply<QVariantMap> reply = interface.call("GetAll");
        QVariantMap map = reply.value();

        // Make sure GetAll returns a map with count and countVisible props
        QCOMPARE(map.contains("count"), true);
        QCOMPARE(map.contains("countVisible"), true);

        // Make sure count is intitilized to 0 and non-visible
        QCOMPARE(map.value("count").toInt(), 0);
        QCOMPARE(map.value("countVisible").toBool(), false);

        // Now make it visible and set it to 55 through D-Bus
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "count", 55);
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "countVisible", true);

        // Fetch it again using GetAll
        reply = interface.call("GetAll");
        map = reply.value();

        // Make sure values have changed on the D-Bus interface
        QCOMPARE(map.value("count").toInt(), 55);
        QCOMPARE(map.value("countVisible").toBool(), true);

        // Now the item on the upper side of the API
        int index = launcherModel->findApplication("abs-icon");
        QCOMPARE(index >= 0, true);

        // And make sure values have changed there as well
        QCOMPARE(launcherModel->get(index)->countVisible(), true);
        QCOMPARE(launcherModel->get(index)->count(), 55);
    }

    void testRefresh() {
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher", "com.canonical.Unity.Launcher");
        QDBusReply<void> reply = interface.call("Refresh");

        // Make sure the call to Refresh returned without error.
        QCOMPARE(reply.isValid(), true);
    }
};

QTEST_GUILESS_MAIN(LauncherModelTest)
#include "launchermodeltest.moc"
