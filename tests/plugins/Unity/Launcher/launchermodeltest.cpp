/*
 * Copyright 2013-2015 Canonical Ltd.
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
#include "gsettings.h"
#include "asadapter.h"
#include "AccountsServiceDBusAdaptor.h"

#include <QtTest>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusMetaType>
#include <QDomDocument>

// This is a mock, specifically to test the LauncherModel
class MockApp: public unity::shell::application::ApplicationInfoInterface
{
    Q_OBJECT
public:
    MockApp(const QString &appId, QObject *parent = 0): ApplicationInfoInterface(appId, parent), m_appId(appId), m_focused(false) { }

    RequestedState requestedState() const override { return RequestedRunning; }
    void setRequestedState(RequestedState) override {}
    QString appId() const override { return m_appId; }
    QString name() const override { return "mock"; }
    QString comment() const override { return "this is a mock"; }
    QUrl icon() const override { return QUrl(); }
    ApplicationInfoInterface::Stage stage() const override { return ApplicationInfoInterface::MainStage; }
    ApplicationInfoInterface::State state() const override { return ApplicationInfoInterface::Running; }
    bool focused() const override { return m_focused; }
    QString splashTitle() const override { return QString(); }
    QUrl splashImage() const override { return QUrl(); }
    bool splashShowHeader() const override { return true; }
    QColor splashColor() const override { return QColor(0,0,0,0); }
    QColor splashColorHeader() const override { return QColor(0,0,0,0); }
    QColor splashColorFooter() const override { return QColor(0,0,0,0); }
    Qt::ScreenOrientations supportedOrientations() const override { return Qt::PortraitOrientation; }
    bool rotatesWindowContents() const override { return false; }
    bool isTouchApp() const override { return true; }
    bool exemptFromLifecycle() const override { return false; }
    void setExemptFromLifecycle(bool) override {}

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
    ~MockAppManager() {}
    int rowCount(const QModelIndex &) const override { return m_list.count(); }
    QVariant data(const QModelIndex &, int ) const override { return QVariant(); }
    QString focusedApplicationId() const override {
        Q_FOREACH(MockApp *app, m_list) {
            if (app->focused()) return app->appId();
        }
        return QString();
    }
    unity::shell::application::ApplicationInfoInterface *get(int index) const override { return m_list.at(index); }
    unity::shell::application::ApplicationInfoInterface *findApplication(const QString &appId) const override {
        Q_FOREACH(MockApp* app, m_list) {
            if (app->appId() == appId) {
                return app;
            }
        }
        return nullptr;
    }
    unity::shell::application::ApplicationInfoInterface *startApplication(const QString &, const QStringList &) override { return nullptr; }
    bool stopApplication(const QString &appId) override {
        Q_FOREACH(MockApp* app, m_list) {
            if (app->appId() == appId) {
                removeApplication(m_list.indexOf(app));
                return true;
            }
        }
        return false;
    }
    bool focusApplication(const QString &appId) override {
        Q_FOREACH(MockApp* app, m_list) {
            app->setFocused(app->appId() == appId);
        }
        Q_EMIT focusedApplicationIdChanged();
        return true;
    }

    void unfocusCurrentApplication() override { }

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
    bool requestFocusApplication(const QString &appId) override { Q_UNUSED(appId); return true; }

private:
    QList<MockApp*> m_list;
};

class LauncherModelTest : public QObject
{
    Q_OBJECT

private:
    LauncherModel *launcherModel;
    MockAppManager *appManager;

    QList<QVariantMap> getASConfig() {
        AccountsServiceDBusAdaptor *as = launcherModel->m_asAdapter->m_accounts;
        QDBusReply<QVariant> reply = as->getUserPropertyAsync(QString(qgetenv("USER")),
                                                              "com.canonical.unity.AccountsService",
                                                              "LauncherItems");
        return qdbus_cast<QList<QVariantMap>>(reply.value().value<QDBusArgument>());
    }

private Q_SLOTS:

    void initTestCase() {
        qDBusRegisterMetaType<QList<QVariantMap>>();

        launcherModel = new LauncherModel(this);
        QCoreApplication::processEvents(); // to let the model register on DBus
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 0);

        appManager = new MockAppManager(this);
        launcherModel->setApplicationManager(appManager);
    }

    // Adding 2 apps to the mock appmanager. Both should appear in the launcher.
    void init() {
        QDBusInterface accountsInterface(QStringLiteral("org.freedesktop.Accounts"),
                                         QStringLiteral("/org/freedesktop/Accounts"),
                                         QStringLiteral("org.freedesktop.Accounts"));
        QDBusReply<bool> addReply = accountsInterface.call(QStringLiteral("AddUser"),
                                                           QString(qgetenv("USER")));
        QVERIFY(addReply.isValid());
        QCOMPARE(addReply.value(), true);

        appManager->addApplication(new MockApp("abs-icon"));
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);

        appManager->addApplication(new MockApp("no-icon"));
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        launcherModel->m_settings->setStoredApplications(QStringList());
    }

    // Removing apps from appmanager and launcher as pinned ones would stick
    void cleanup() {
        while (appManager->count() > 0) {
            appManager->removeApplication(0);
        }
        while (launcherModel->rowCount(QModelIndex()) > 0) {
            launcherModel->requestRemove(launcherModel->get(0)->appId());
        }

        QDBusInterface accountsInterface(QStringLiteral("org.freedesktop.Accounts"),
                                         QStringLiteral("/org/freedesktop/Accounts"),
                                         QStringLiteral("org.freedesktop.Accounts"));
        QDBusReply<bool> removeReply = accountsInterface.call(QStringLiteral("RemoveUser"),
                                                              QString(qgetenv("USER")));
        QVERIFY(removeReply.isValid());
        QCOMPARE(removeReply.value(), true);
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
        QSignalSpy spy(launcherModel, &LauncherModel::dataChanged);
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        launcherModel->pin(launcherModel->get(0)->appId());
        QCOMPARE(launcherModel->get(0)->pinned(), true);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        QCOMPARE(spy.count() > 0, true);
        QCOMPARE(spy.at(0).at(2).value<QVector<int>>().first(), (int)LauncherModelInterface::RolePinned);

        // App should be pinned now
        spy.clear();
        launcherModel->requestRemove(launcherModel->get(0)->appId());
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        QCOMPARE(spy.count(), 1);
        QCOMPARE(spy.at(0).at(2).value<QVector<int>>().first(), (int)LauncherModelInterface::RolePinned);

        // Now that the app is unpinned, nothing should change and the signal should not be emitted
        spy.clear();
        launcherModel->requestRemove(launcherModel->get(0)->appId());
        QCOMPARE(launcherModel->get(0)->pinned(), false);
        QCOMPARE(launcherModel->get(1)->pinned(), false);
        QCOMPARE(spy.count(), 0);
    }

    void testRemove_data() {

        QTest::addColumn<bool>("pinned");
        QTest::addColumn<bool>("running");

        QTest::newRow("non-pinned, running") << false << true;
        QTest::newRow("pinned, running") << true << true;
        QTest::newRow("pinned, non-running") << true << false;
    }

    void testRemove() {
        QFETCH(bool, pinned);
        QFETCH(bool, running);

        // In the beginning we always have two items
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

        // pin one if required
        if (pinned) {
            launcherModel->pin("abs-icon");
        }

        // stop it if required
        if (!running) {
            appManager->stopApplication("abs-icon");
        }

        // Now remove it
        launcherModel->requestRemove("abs-icon");

        if (running) {
            // both apps are running, both apps must still be here
            QCOMPARE(launcherModel->rowCount(QModelIndex()), 2);

           // Item must be unpinned now
           int index = launcherModel->findApplication("abs-icon");
           QCOMPARE(launcherModel->get(index)->pinned(), false);

        } else if (pinned) {
           // Item 1 must go away, item 0 is here to stay
            QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
        }

        // done our checks. now stop the app if was still running
        if (running) {
            appManager->stopApplication("abs-icon");
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

    void testApplicationRunning() {
        launcherModel->pin("abs-icon");
        launcherModel->pin("no-icon");

        QCOMPARE(launcherModel->get(0)->running(), true);
        QCOMPARE(launcherModel->get(1)->running(), true);

        appManager->stopApplication("abs-icon");
        QCOMPARE(launcherModel->get(0)->running(), false);
        QCOMPARE(launcherModel->get(1)->running(), true);

        appManager->stopApplication("no-icon");
        QCOMPARE(launcherModel->get(0)->running(), false);
        QCOMPARE(launcherModel->get(1)->running(), false);
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

    void testQuitMenuItem() {
        // we have 2 apps running, both should have the Quit action in its quick list
        QCOMPARE(launcherModel->rowCount(), 2);

        // stop the second one keeping it pinned so that it doesn't go away
        launcherModel->pin("no-icon");
        appManager->stopApplication("no-icon");

        // find the first Quit item, should be there
        QuickListModel *model = qobject_cast<QuickListModel*>(launcherModel->get(0)->quickList());
        int quitActionIndex = -1;
        for (int i = 0; i < model->rowCount(); ++i) {
            if (model->get(i).actionId() == "stop_item") {
                quitActionIndex = i;
                break;
            }
        }
        QVERIFY(quitActionIndex >= 0);

        // find the second Quit item, should NOT be there, the app is stopped
        QuickListModel *model2 = qobject_cast<QuickListModel*>(launcherModel->get(1)->quickList());
        int quitActionIndex2 = -1;
        for (int i = 0; i < model2->rowCount(); ++i) {
            if (model2->get(i).actionId() == "stop_item") {
                quitActionIndex2 = i;
                break;
            }
        }
        QVERIFY(quitActionIndex2 == -1);

        // trigger the first quit item quicklist action
        launcherModel->quickListActionInvoked(launcherModel->get(0)->appId(), quitActionIndex);
        // first app should be gone...
        QCOMPARE(launcherModel->rowCount(QModelIndex()), 1);
        // ... the second app (now at index 0) should still be there, pinned and stopped
        QCOMPARE(launcherModel->get(0)->appId(), QStringLiteral("no-icon"));
        QCOMPARE(launcherModel->get(0)->pinned(), true);
        QCOMPARE(launcherModel->get(0)->running(), false);
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
        QSignalSpy spy(launcherModel, &LauncherModel::dataChanged);

        // Call GetAll on abs-icon
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher/abs_2Dicon", "org.freedesktop.DBus.Properties");
        QDBusReply<QVariantMap> reply = interface.call("GetAll");
        QVariantMap map = reply.value();

        // Check that the alerting-status is still false, and the item on the upper side of the API
        int index = launcherModel->findApplication("abs-icon");
        QCOMPARE(index >= 0, true);
        QVERIFY(launcherModel->get(index)->alerting() == false);

        // Make sure GetAll returns a map with count and countVisible props
        QCOMPARE(map.contains("count"), true);
        QCOMPARE(map.contains("countVisible"), true);

        // Make sure count is intitilized to 0 and non-visible
        QCOMPARE(map.value("count").toInt(), 0);
        QCOMPARE(map.value("countVisible").toBool(), false);

        // Now make it visible and set it to 55 through D-Bus
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "count", QVariant::fromValue(QDBusVariant(55)));
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "countVisible", QVariant::fromValue(QDBusVariant(true)));

        // Fetch it again using GetAll
        reply = interface.call("GetAll");
        map = reply.value();

        // Make sure values have changed on the D-Bus interface
        QCOMPARE(map.value("count").toInt(), 55);
        QCOMPARE(map.value("countVisible").toBool(), true);

        // Finally check, that the change to "count" implicitly also set the alerting-state to true
        QVERIFY(launcherModel->get(index)->alerting() == true);
    }

    void testCountEmblemAddsRemovesItem_data() {
        QTest::addColumn<bool>("isPinned");
        QTest::addColumn<bool>("isRunning");
        QTest::addColumn<bool>("startWhenVisible");
        QTest::newRow("not pinned, not running") << false << false << false;
        QTest::newRow("pinned, not running") << true << false << false;
        QTest::newRow("not pinned, not running, starting from notification") << false << false << true;
        QTest::newRow("pinned, not running, starting from notification") << true << false << true;
        QTest::newRow("not pinned, running") << false << true << false;
        QTest::newRow("pinned, running") << true << true << false;
    }

    void testCountEmblemAddsRemovesItem() {
        QFETCH(bool, isPinned);
        QFETCH(bool, isRunning);
        QFETCH(bool, startWhenVisible);

        // Make sure item is here as expected after init() and that count is not visible
        int index = launcherModel->findApplication("abs-icon");
        QCOMPARE(index == -1, false);
        QCOMPARE(launcherModel->get(index)->countVisible(), false);

        // Pin if we need to
        if (isPinned) {
            launcherModel->pin("abs-icon");
        }
        QCOMPARE(launcherModel->get(0)->pinned(), isPinned);

        // Stop it if we need to
        if (!isRunning) {
            appManager->stopApplication("abs-icon");
        }
        QCOMPARE(launcherModel->findApplication("abs-icon") >= 0, isRunning || isPinned);


        // set the count emblem to visible
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher/abs_2Dicon", "org.freedesktop.DBus.Properties");
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "count", QVariant::fromValue(QDBusVariant(55)));
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "countVisible", QVariant::fromValue(QDBusVariant(true)));

        // Make sure item is here and that count is visible
        index = launcherModel->findApplication("abs-icon");
        QCOMPARE(index == -1, false);
        QCOMPARE(launcherModel->get(index)->countVisible(), true);

        if (!isRunning && startWhenVisible) {
            appManager->addApplication(new MockApp("abs-icon"));
        }

        // Hide count emblem again
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "countVisible", QVariant::fromValue(QDBusVariant(false)));

        // Make sure item is shown/hidden as expected
        index = launcherModel->findApplication("abs-icon");
        QCOMPARE(index == -1, !isRunning && !isPinned && !startWhenVisible);
    }

    void testAlert() {
        // Check that the alerting-status is still false
        int index = launcherModel->findApplication("abs-icon");
        QCOMPARE(index >= 0, true);
        QVERIFY(launcherModel->get(index)->alerting() == false);

        // Call Alert() on "abs-icon"
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher/abs_2Dicon", "com.canonical.Unity.Launcher.Item");
        interface.call("Alert");

        // Check that the alerting-status is now true
        QVERIFY(launcherModel->get(index)->alerting() == true);
    }

    void testRefreshAfterDeletedDesktopFiles_data() {
        QTest::addColumn<bool>("deleted");
        QTest::newRow("have .desktop files") << false;
        QTest::newRow("deleted .desktop files") << true;
    }

    void testRefreshAfterDeletedDesktopFiles() {
        QFETCH(bool, deleted);

        // pin both apps
        launcherModel->pin("abs-icon");
        launcherModel->pin("no-icon");
        // close both apps
        appManager->removeApplication(0);
        appManager->removeApplication(0);

        // "delete" the .desktop files
        QString oldCurrent = QDir::currentPath();
        if (deleted) {
            // In testing mode, the launcher searches the current dir for the sample .desktop file
            // We can make that fail by changing the current dir
            QDir::setCurrent("..");
        }

        // Call refresh
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher", "com.canonical.Unity.Launcher");
        QDBusReply<void> reply = interface.call("Refresh");

        // Make sure the call to Refresh returned without error.
        QCOMPARE(reply.isValid(), true);

        QCOMPARE(launcherModel->rowCount(), deleted ? 0 : 2);

        // Restoring current dir
        QDir::setCurrent(oldCurrent);
    }

    void testSettings() {
        GSettings *settings = launcherModel->m_settings;
        QSignalSpy spy(launcherModel, &LauncherModel::hint);

        // Nothing pinned at startup
        QCOMPARE(settings->storedApplications().count(), 0);

        // pin both apps
        launcherModel->pin("abs-icon");
        launcherModel->pin("no-icon");
        QCOMPARE(spy.count(), 0);

        // Now settings should have 2 apps
        QCOMPARE(settings->storedApplications().count(), 2);

        // close both apps
        appManager->removeApplication(0);
        appManager->removeApplication(0);

        // Now settings should have 2 apps
        QCOMPARE(settings->storedApplications().count(), 2);

        // Now remove 1 app through the backend, make sure one is still there
        settings->simulateDConfChanged(QStringList() << "abs-icon");
        QCOMPARE(settings->storedApplications().count(), 1);
        QCOMPARE(spy.count(), 1);

        // Check if it disappeared from the frontend too
        QCOMPARE(launcherModel->rowCount(), 1);

        // Add them back but in reverse order
        settings->simulateDConfChanged(QStringList() << "no-icon" << "abs-icon");
        QCOMPARE(launcherModel->rowCount(), 2);
        QCOMPARE(launcherModel->get(0)->appId(), QString("no-icon"));
        QCOMPARE(launcherModel->get(1)->appId(), QString("abs-icon"));
        QCOMPARE(spy.count(), 2);
    }

    void testAddSyncsToAS() {
        // Make sure launcher and AS are in sync when we start the test
        QCOMPARE(launcherModel->rowCount(), getASConfig().count());

        int oldCount = launcherModel->rowCount();
        appManager->addApplication(new MockApp("rel-icon"));
        QCOMPARE(launcherModel->rowCount(), oldCount + 1);
        QCOMPARE(launcherModel->rowCount(), getASConfig().count());
    }

    void testRemoveSyncsToAS() {
        // Make sure launcher and AS are in sync when we start the test
        QCOMPARE(launcherModel->rowCount(), getASConfig().count());

        int oldCount = launcherModel->rowCount();
        appManager->stopApplication("abs-icon");
        QCOMPARE(launcherModel->rowCount(), oldCount - 1);
        QCOMPARE(launcherModel->rowCount(), getASConfig().count());
    }

    void testMoveSyncsToAS() {
        // Make sure launcher and AS are in sync when we start the test
        QCOMPARE(launcherModel->rowCount(), getASConfig().count());

        for (int i = 0; i < launcherModel->rowCount(); i++) {
            QString launcherAppId = launcherModel->get(i)->appId();
            QString asAppId = getASConfig().at(i).value("id").toString();
            QCOMPARE(launcherAppId, asAppId);
        }

        launcherModel->move(0, 1);

        for (int i = 0; i < launcherModel->rowCount(); i++) {
            QString launcherAppId = launcherModel->get(i)->appId();
            QString asAppId = getASConfig().at(i).value("id").toString();
            QCOMPARE(launcherAppId, asAppId);
        }
    }

    void testCountChangeSyncsToAS() {
        // Find the index of the abs-icon app
        int index = launcherModel->findApplication("abs-icon");

        // Make sure it's invisible and 0 at the beginning
        QCOMPARE(getASConfig().at(index).value("countVisible").toBool(), false);
        QCOMPARE(getASConfig().at(index).value("count").toInt(), 0);

        // Change the count of the abs-icon app through D-Bus
        QDBusInterface interface("com.canonical.Unity.Launcher", "/com/canonical/Unity/Launcher/abs_2Dicon", "org.freedesktop.DBus.Properties");
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "count", QVariant::fromValue(QDBusVariant(55)));
        interface.call("Set", "com.canonical.Unity.Launcher.Item", "countVisible", QVariant::fromValue(QDBusVariant(true)));

        // Make sure it changed to visible and 55
        QCOMPARE(getASConfig().at(index).value("countVisible").toBool(), true);
        QCOMPARE(getASConfig().at(index).value("count").toInt(), 55);
    }
};

QTEST_GUILESS_MAIN(LauncherModelTest)
#include "launchermodeltest.moc"
