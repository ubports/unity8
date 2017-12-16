/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "Greeter.h"
#include "MockController.h"
#include "UsersModel.h"

#include <QLightDM/UsersModel>
#include <QtTest>

class GreeterUsersModelTest : public QObject
{
    Q_OBJECT

private:
    static int findName(QAbstractItemModel *model, const QString &name)
    {
        for (int i = 0; i < model->rowCount(QModelIndex()); i++) {
            if (model->data(model->index(i, 0), QLightDM::UsersModel::NameRole).toString() == name) {
                return i;
            }
        }
        return -1;
    }

    static QString getStringValue(QAbstractItemModel *model, const QString &name, int role)
    {
        int i = findName(model, name);
        return model->data(model->index(i, 0), role).toString();
    }

    void recreateModel()
    {
        delete model;
        model = new UsersModel();
        QVERIFY(model);
    }

private Q_SLOTS:

    void init()
    {
        recreateModel();
    }

    void cleanup()
    {
        QLightDM::MockController::instance()->reset();
    }

    void testMangleColor()
    {
        auto background = getStringValue(model, "color-background", QLightDM::UsersModel::BackgroundPathRole);
        QVERIFY(background == "data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#E95420'/></svg>");
    }

    void testMangleEmptyName()
    {
        auto name = getStringValue(model, "empty-name", QLightDM::UsersModel::RealNameRole);
        QVERIFY(name == "empty-name");
    }

    void testHasGuest()
    {
        // sanity check that it doesn't start already present
        QCOMPARE(findName(model, QStringLiteral("*guest")), -1);

        QLightDM::MockController::instance()->setHasGuestAccountHint(true);

        int i = findName(model, QStringLiteral("*guest"));
        QVERIFY(i >= 0);

        auto realName = model->data(i, QLightDM::UsersModel::RealNameRole).toString();
        QCOMPARE(realName, QStringLiteral("Guest Session"));

        auto loggedIn = model->data(i, QLightDM::UsersModel::LoggedInRole).toBool();
        QVERIFY(!loggedIn);

        auto session = model->data(i, QLightDM::UsersModel::SessionRole).toString();
        QCOMPARE(session, Greeter::instance()->defaultSessionHint());
    }

    void testHasManual()
    {
        // sanity check that it doesn't start already present
        QCOMPARE(findName(model, QStringLiteral("*other")), -1);

        QLightDM::MockController::instance()->setShowManualLoginHint(true);

        int i = findName(model, QStringLiteral("*other"));
        QVERIFY(i >= 0);

        auto realName = model->data(i, QLightDM::UsersModel::RealNameRole).toString();
        QCOMPARE(realName, QStringLiteral("Login"));

        auto loggedIn = model->data(i, QLightDM::UsersModel::LoggedInRole).toBool();
        QVERIFY(!loggedIn);

        auto session = model->data(i, QLightDM::UsersModel::SessionRole).toString();
        QCOMPARE(session, Greeter::instance()->defaultSessionHint());
    }


    void testEmptySession()
    {
        int i = findName(model, QStringLiteral("no-session"));
        QVERIFY(i >= 0);

        // A valid test as 'no-session' is instantiated with it's
        // SessionRole as an empty string. This ensures something,
        // hopefully sensical, is returned.
        auto session = model->data(i, QLightDM::UsersModel::SessionRole);
        QCOMPARE(session.toString().isEmpty(), false);
    }

    void testHideUsers()
    {
        QLightDM::MockController::instance()->setHideUsersHint(true);

        QCOMPARE(model->count(), 1);
        auto name = model->data(0, QLightDM::UsersModel::NameRole).toString();
        QCOMPARE(name, QStringLiteral("*other"));
    }

    void testHideUsersWithGuest()
    {
        QLightDM::MockController::instance()->setHideUsersHint(true);
        QLightDM::MockController::instance()->setHasGuestAccountHint(true);

        QCOMPARE(model->count(), 1);
        auto name = model->data(0, QLightDM::UsersModel::NameRole).toString();
        QCOMPARE(name, QStringLiteral("*guest"));
    }

    void testCustomEntriesAreLast()
    {
        QLightDM::MockController::instance()->setHasGuestAccountHint(true);
        QLightDM::MockController::instance()->setShowManualLoginHint(true);

        QVERIFY(model->count() > 2);

        int manualIndex = findName(model, QStringLiteral("*other"));
        QCOMPARE(manualIndex, model->count() - 2);

        int guestIndex = findName(model, QStringLiteral("*guest"));
        QCOMPARE(guestIndex, model->count() - 1);
    }

private:
    UsersModel *model = nullptr;
};

QTEST_MAIN(GreeterUsersModelTest)

#include "usersmodel.moc"
