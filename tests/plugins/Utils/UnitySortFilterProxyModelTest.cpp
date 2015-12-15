/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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

// local
#include "unitysortfilterproxymodelqml.h"
#include "ModelTest.h"

// Qt
#include <QTest>
#include <QSignalSpy>
#include <QModelIndex>
#include <QAbstractListModel>
#include <QDebug>


class MockListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    MockListModel(QObject* parent = 0)
        : QAbstractListModel(parent)
    {
    }

    int rowCount(const QModelIndex& /* parent */ = QModelIndex()) const override
    {
        return m_list.size();
    }

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override
    {
        if (!index.isValid() || index.row() < 0 || index.row() >= m_list.size() || role != Qt::DisplayRole) {
           return QVariant();
        }
        return QVariant(m_list[index.row()]);
    }

    QHash<int, QByteArray> roleNames() const override
    {
        return m_roles;
    }

    void setRoles(const QHash<int,QByteArray> &roles) {
        m_roles = roles;
    }

    bool insertRows(int row, int count, const QModelIndex &parent=QModelIndex()) override {
        beginInsertRows(parent, row, row+count-1);
        for (int i=0; i<count; i++) {
            m_list.insert(i+row, QString("test%1").arg(i));
        }
        endInsertRows();
        return true;
    }

    bool appendRows(QStringList &rows, const QModelIndex &parent=QModelIndex()) {
        beginInsertRows(parent, rowCount(), rowCount() + rows.count() - 1);
        m_list.append(rows);
        endInsertRows();
        return true;
    }

    bool removeRows(int row, int count, const QModelIndex &parent=QModelIndex()) override {
        beginRemoveRows(parent, row, row+count-1);
        for (int i=0; i<count; i++) {
            m_list.removeAt(row);
        }
        endRemoveRows();
        return true;
    }

private:
    QStringList m_list;
    QHash<int, QByteArray> m_roles;
};

class UnitySortFilterProxyModelTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase() {
        qRegisterMetaType<QModelIndex>("QModelIndex");
    }

    void testRoleNamesSetAfter()
    {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model;
        QHash<int, QByteArray> roles;

        proxy.setModel(&model);

        roles[0] = "role0";
        roles[1] = "role1";
        model.setRoles(roles);
        QCOMPARE(model.roleNames(), proxy.roleNames());
    }

    void testRoleNamesSetBefore()
    {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model;
        QHash<int, QByteArray> roles;

        roles[0] = "role0";
        roles[1] = "role1";
        model.setRoles(roles);

        proxy.setModel(&model);
        QCOMPARE(model.roleNames(), proxy.roleNames());
    }

    void testCountSetAfter()
    {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model;
        model.insertRows(0, 5);

        QSignalSpy spyOnCountChanged(&proxy, &UnitySortFilterProxyModelQML::countChanged);

        proxy.setModel(&model);
        QCOMPARE(proxy.count(), 5);
        QVERIFY(spyOnCountChanged.count() >= 1);
    }

    void testCountInsert()
    {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model;

        proxy.setModel(&model);

        QSignalSpy spyOnCountChanged(&proxy, &UnitySortFilterProxyModelQML::countChanged);

        model.insertRows(0, 5);
        QCOMPARE(proxy.count(), 5);
        QCOMPARE(spyOnCountChanged.count(), 1);
    }

    void testCountRemove()
    {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model;
        model.insertRows(0, 5);

        proxy.setModel(&model);
        QCOMPARE(proxy.count(), 5);

        QSignalSpy spyOnCountChanged(&proxy, &UnitySortFilterProxyModelQML::countChanged);

        model.removeRows(0, 3);
        QCOMPARE(proxy.count(), 2);
        QCOMPARE(spyOnCountChanged.count(), 1);
    }

    void testInvertMatch() {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model;

        proxy.setModel(&model);
        proxy.setDynamicSortFilter(true);

        QStringList rows;
        rows << "a/foobar/b" << "foobar" << "foobarbaz" << "hello";
        model.appendRows(rows);

        // Check that without a filterRegExp all rows are accepted regardless of invertMatch
        QCOMPARE(model.rowCount(), rows.count());
        QCOMPARE(proxy.rowCount(), rows.count());
        for (int i=0; i<rows.count(); i++) {
            QCOMPARE(proxy.index(i, 0).data().toString(), model.index(i, 0).data().toString());
        }
        proxy.setInvertMatch(true);
        QCOMPARE(model.rowCount(), rows.count());
        QCOMPARE(proxy.rowCount(), rows.count());
        for (int i=0; i<rows.count(); i++) {
            QCOMPARE(proxy.index(i, 0).data().toString(), model.index(i, 0).data().toString());
        }


        // Test non-anchored regexp with invertMatch active
        proxy.setFilterRegExp("foobar");
        QCOMPARE(proxy.rowCount(), 1);
        QCOMPARE(proxy.index(0, 0).data().toString(), rows.last());

        // Test anchored regexp with invertMatch active
        proxy.setFilterRegExp("^foobar$");
        QCOMPARE(proxy.rowCount(), 3);
        QCOMPARE(proxy.index(0, 0).data().toString(), rows.at(0));
        QCOMPARE(proxy.index(1, 0).data().toString(), rows.at(2));
        QCOMPARE(proxy.index(2, 0).data().toString(), rows.at(3));

        // Test regexp with OR and invertMatch active
        proxy.setFilterRegExp("foobar|hello");
        QCOMPARE(proxy.count(), 0);
    }

    void testNestedProxyRoleNames() {
        UnitySortFilterProxyModelQML proxy1, proxy2;
        MockListModel model;
        QHash<int, QByteArray> roles;
        roles[0] = "role0";
        roles[1] = "role1";
        model.setRoles(roles);

        proxy1.setModel(&model);
        proxy2.setModel(&proxy1);

        QCOMPARE(proxy2.roleNames(), model.roleNames());
    }

    void testModelTest() {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model;

        proxy.setModel(&model);
        proxy.setDynamicSortFilter(true);

        QStringList rows;
        rows << "a/foobar/b" << "foobar" << "foobarbaz" << "hello";
        model.appendRows(rows);

        proxy.setInvertMatch(true);
        proxy.setFilterRegExp("^foobar$");

        ModelTest t1(&proxy);
    }

    void testModelChanged() {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model, model2;

        QSignalSpy spyOnModelChanged(&proxy, &UnitySortFilterProxyModelQML::modelChanged);

        proxy.setModel(&model);
        QCOMPARE(spyOnModelChanged.count(), 1);

        proxy.setModel(&model2);
        QCOMPARE(spyOnModelChanged.count(), 2);

        proxy.setModel(&model);
        QCOMPARE(spyOnModelChanged.count(), 3);

        proxy.setModel(&model);
        QCOMPARE(spyOnModelChanged.count(), 3);
    }

    void testData() {
        UnitySortFilterProxyModelQML proxy;
        MockListModel model, model2;

        QStringList rows;
        rows << "a" << "c" << "b";
        model.appendRows(rows);

        proxy.setModel(&model);
        proxy.sort(0);

        QCOMPARE(proxy.data(-1, Qt::DisplayRole), QVariant());
        QCOMPARE(proxy.data(3, Qt::DisplayRole), QVariant());
        QCOMPARE(proxy.data(0, Qt::DisplayRole - 1), QVariant());
        QCOMPARE(proxy.data(0, Qt::DisplayRole + 1), QVariant());
        QCOMPARE(proxy.data(0, Qt::DisplayRole), QVariant("a"));
        QCOMPARE(proxy.data(1, Qt::DisplayRole), QVariant("b"));
        QCOMPARE(proxy.data(2, Qt::DisplayRole), QVariant("c"));
    }
};

QTEST_GUILESS_MAIN(UnitySortFilterProxyModelTest)

#include "UnitySortFilterProxyModelTest.moc"
