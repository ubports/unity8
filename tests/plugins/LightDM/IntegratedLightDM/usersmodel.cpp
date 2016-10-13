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

private Q_SLOTS:

    void init()
    {
        model = new UsersModel();
        QVERIFY(model);
        sourceModel = new QLightDM::UsersModel();
        QVERIFY(sourceModel);
    }

    void cleanup()
    {
        delete model;
        delete sourceModel;
    }

    void testMangleColor()
    {
        QString background = getStringValue(sourceModel, "color-background", QLightDM::UsersModel::BackgroundPathRole);
        QVERIFY(background == "#E95420");

        background = getStringValue(model, "color-background", QLightDM::UsersModel::BackgroundPathRole);
        QVERIFY(background == "data:image/svg+xml,<svg><rect width='100%' height='100%' fill='#E95420'/></svg>");
    }

    void testMangleEmptyName()
    {
        QString name = getStringValue(sourceModel, "empty-name", QLightDM::UsersModel::RealNameRole);
        QVERIFY(name == "");

        name = getStringValue(model, "empty-name", QLightDM::UsersModel::RealNameRole);
        QVERIFY(name == "empty-name");
    }

private:
    UsersModel *model;
    QLightDM::UsersModel *sourceModel;
};

QTEST_MAIN(GreeterUsersModelTest)

#include "usersmodel.moc"
