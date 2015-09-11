/*
 * Copyright (C) 2011, 2013 Canonical, Ltd.
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
#include "qlimitproxymodelqml.h"
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

    void clear()
    {
        beginRemoveRows(QModelIndex(), 0, m_list.count() - 1);
        m_list.clear();
        endRemoveRows();
    }

    bool insertRows(int row, int count, const QModelIndex &parent=QModelIndex()) override {
        beginInsertRows(parent, row, row+count-1);
        for (int i=0; i<count; i++) {
            m_list.insert(i+row, QString::number(i));
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

class MirrorModel : public QObject
{
    Q_OBJECT

public:
    MirrorModel(QAbstractItemModel *model) : m_mirror(model)
    {
        connect(model, &QAbstractItemModel::rowsInserted, this, &MirrorModel::rowsInserted);
        connect(model, &QAbstractItemModel::rowsRemoved, this, &MirrorModel::rowsRemoved);
        connect(model, &QAbstractItemModel::dataChanged, this, &MirrorModel::dataChanged);
    }

    void check()
    {
        QCOMPARE(m_list.count(), m_mirror->rowCount());
        for (int i = 0; i < m_list.count(); ++i) {
            QCOMPARE(m_list[i], m_mirror->data(m_mirror->index(i, 0)).toString());
        }
    }

private Q_SLOTS:
    void rowsInserted(const QModelIndex &parent, int start, int end)
    {
        QVERIFY(!parent.isValid());
        for (int i = start; i <= end; ++i) {
            m_list.insert(i, m_mirror->data(m_mirror->index(i, 0)).toString());
        }
    }

    void rowsRemoved(const QModelIndex &parent, int start, int end)
    {
        QVERIFY(!parent.isValid());
        for (int i = end; i >= start; --i) {
            m_list.removeAt(i);
        }
    }

    void dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight)
    {
        QVERIFY(topLeft.isValid());
        QVERIFY(bottomRight.isValid());
        QVERIFY(!topLeft.parent().isValid());
        QVERIFY(!bottomRight.parent().isValid());
        for (int i = topLeft.row(); i <= bottomRight.row(); ++i) {
            m_list[i] = m_mirror->data(m_mirror->index(i, 0)).toString();
        }
    }


private:
    QStringList m_list;
    QAbstractItemModel *m_mirror;
};

class QLimitProxyModelTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:

    void initTestCase() {
        qRegisterMetaType<QModelIndex>("QModelIndex");
    }

    void testRoleNamesSetAfter()
    {
        QLimitProxyModelQML proxy;
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
        QLimitProxyModelQML proxy;
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
        QLimitProxyModelQML proxy;
        MockListModel model;
        model.insertRows(0, 5);

        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        proxy.setModel(&model);
        QCOMPARE(proxy.rowCount(), 5);
        QVERIFY(spyOnCountChanged.count() >= 1);
    }

    void testCountInsert()
    {
        QLimitProxyModelQML proxy;
        MockListModel model;

        proxy.setModel(&model);

        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        model.insertRows(0, 5);
        QCOMPARE(proxy.rowCount(), 5);
        QCOMPARE(spyOnCountChanged.count(), 1);
    }

    void testCountRemove()
    {
        QLimitProxyModelQML proxy;
        MockListModel model;
        model.insertRows(0, 5);

        proxy.setModel(&model);

        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        model.removeRows(0, 3);
        QCOMPARE(proxy.rowCount(), 2);
        QCOMPARE(spyOnCountChanged.count(), 1);
    }

    void testLimitCount()
    {
        QLimitProxyModelQML proxy;
        MockListModel model;

        proxy.setModel(&model);
        proxy.setLimit(3);

        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        model.insertRows(0, 5);
        QCOMPARE(proxy.rowCount(), 3);
        QCOMPARE(spyOnCountChanged.count(), 1);
    }

    void testLimitLesserThanCount()
    {
        QLimitProxyModelQML proxy;
        MockListModel model;
        QList<QVariant> arguments;
        model.insertRows(0, 10);

        proxy.setModel(&model);

        QSignalSpy spyOnRowsRemoved(&proxy, &QLimitProxyModelQML::rowsRemoved);
        QSignalSpy spyOnRowsInserted(&proxy, &QLimitProxyModelQML::rowsInserted);
        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        proxy.setLimit(5);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 1);
        QCOMPARE(spyOnRowsRemoved.count(), 1);
        arguments = spyOnRowsRemoved.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 5);
        QCOMPARE(arguments.at(2).toInt(), 9);
        QCOMPARE(proxy.rowCount(), 5);
        spyOnRowsRemoved.clear();
        spyOnCountChanged.clear();

        proxy.setLimit(7);
        QCOMPARE(spyOnRowsInserted.count(), 1);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsInserted.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 5);
        QCOMPARE(arguments.at(2).toInt(), 6);
        QCOMPARE(proxy.rowCount(), 7);
        spyOnRowsInserted.clear();
        spyOnCountChanged.clear();

        proxy.setLimit(3);
        QCOMPARE(spyOnRowsRemoved.count(), 1);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsRemoved.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 3);
        QCOMPARE(arguments.at(2).toInt(), 6);
        QCOMPARE(proxy.rowCount(), 3);
        spyOnRowsRemoved.clear();
        spyOnCountChanged.clear();
    }

    void testLimitGreaterThanCount()
    {
        QLimitProxyModelQML proxy;
        MockListModel model;
        QList<QVariant> arguments;
        model.insertRows(0, 5);

        proxy.setModel(&model);

        QSignalSpy spyOnRowsRemoved(&proxy, &QLimitProxyModelQML::rowsRemoved);
        QSignalSpy spyOnRowsInserted(&proxy, &QLimitProxyModelQML::rowsInserted);
        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        proxy.setLimit(7);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 0);
        QCOMPARE(proxy.rowCount(), 5);

        proxy.setLimit(5);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 0);
        QCOMPARE(proxy.rowCount(), 5);

        proxy.setLimit(3);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnRowsRemoved.count(), 1);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsRemoved.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 3);
        QCOMPARE(arguments.at(2).toInt(), 4);
        QCOMPARE(proxy.rowCount(), 3);
        spyOnRowsRemoved.clear();
        spyOnCountChanged.clear();

        proxy.setLimit(4);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 1);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsInserted.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 3);
        QCOMPARE(arguments.at(2).toInt(), 3);
        QCOMPARE(proxy.rowCount(), 4);
        spyOnRowsInserted.clear();
        spyOnCountChanged.clear();

        proxy.setLimit(7);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 1);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsInserted.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 4);
        QCOMPARE(arguments.at(2).toInt(), 4);
        QCOMPARE(proxy.rowCount(), 5);
        spyOnRowsInserted.clear();
        spyOnCountChanged.clear();
    }

    void testLimitMinusOne()
    {
        QLimitProxyModelQML proxy;
        MockListModel model;
        QList<QVariant> arguments;
        model.insertRows(0, 5);

        proxy.setModel(&model);

        QSignalSpy spyOnRowsRemoved(&proxy, &QLimitProxyModelQML::rowsRemoved);
        QSignalSpy spyOnRowsInserted(&proxy, &QLimitProxyModelQML::rowsInserted);
        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        proxy.setLimit(7);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 0);
        QCOMPARE(proxy.rowCount(), 5);

        proxy.setLimit(-1);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 0);
        QCOMPARE(proxy.rowCount(), 5);

        proxy.setLimit(3);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnRowsRemoved.count(), 1);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsRemoved.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 3);
        QCOMPARE(arguments.at(2).toInt(), 4);
        QCOMPARE(proxy.rowCount(), 3);
        spyOnRowsRemoved.clear();
        spyOnCountChanged.clear();

        proxy.setLimit(-1);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 1);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsInserted.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 3);
        QCOMPARE(arguments.at(2).toInt(), 4);
        QCOMPARE(proxy.rowCount(), 5);
        spyOnRowsInserted.clear();
        spyOnCountChanged.clear();
    }

    void testLimitInsert() {
        QLimitProxyModelQML proxy;
        MockListModel model;
        QList<QVariant> arguments;

        proxy.setModel(&model);
        proxy.setLimit(7);

        QSignalSpy spyOnRowsRemoved(&proxy, &QLimitProxyModelQML::rowsRemoved);
        QSignalSpy spyOnRowsInserted(&proxy, &QLimitProxyModelQML::rowsInserted);
        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        model.insertRows(0, 5);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 1);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsInserted.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 0);
        QCOMPARE(arguments.at(2).toInt(), 4);
        QCOMPARE(proxy.rowCount(), 5);
        spyOnRowsInserted.clear();
        spyOnCountChanged.clear();

        model.insertRows(2, 2);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 1);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsInserted.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 2);
        QCOMPARE(arguments.at(2).toInt(), 3);
        QCOMPARE(proxy.rowCount(), 7);
        spyOnRowsInserted.clear();
        spyOnCountChanged.clear();

        model.insertRows(7, 3);
        QCOMPARE(proxy.rowCount(), 7);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 0);
    }

    void testLimitRemove() {
        QLimitProxyModelQML proxy;
        MockListModel model;
        QList<QVariant> arguments;

        proxy.setModel(&model);
        proxy.setLimit(7);

        model.insertRows(0, 12);

        QCOMPARE(proxy.rowCount(), 7);

        QSignalSpy spyOnRowsRemoved(&proxy, &QLimitProxyModelQML::rowsRemoved);
        QSignalSpy spyOnRowsInserted(&proxy, &QLimitProxyModelQML::rowsInserted);
        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        model.removeRows(7, 3);
        QCOMPARE(proxy.rowCount(), 7);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 0);

        model.removeRows(2, 2);
        QCOMPARE(spyOnRowsRemoved.count(), 0);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 0);
        QCOMPARE(proxy.rowCount(), 7);

        model.removeRows(0, 7);
        QCOMPARE(spyOnRowsRemoved.count(), 1);
        QCOMPARE(spyOnRowsInserted.count(), 0);
        QCOMPARE(spyOnCountChanged.count(), 1);
        arguments = spyOnRowsRemoved.takeFirst();
        QCOMPARE(arguments.at(1).toInt(), 0);
        QCOMPARE(arguments.at(2).toInt(), 6);
        QCOMPARE(proxy.rowCount(), 0);
    }

    void testNestedProxyRoleNames() {
        QLimitProxyModelQML proxy1, proxy2;
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
        QLimitProxyModelQML proxy;
        MockListModel model;

        proxy.setModel(&model);
        proxy.setLimit(7);

        model.insertRows(0, 12);

        ModelTest t1(&proxy);
    }

    void testModelChanged() {
        QLimitProxyModelQML proxy;
        MockListModel model, model2;

        QSignalSpy spyOnModelChanged(&proxy, &QLimitProxyModelQML::modelChanged);

        proxy.setModel(&model);
        QCOMPARE(spyOnModelChanged.count(), 1);

        proxy.setModel(&model2);
        QCOMPARE(spyOnModelChanged.count(), 2);

        proxy.setModel(&model);
        QCOMPARE(spyOnModelChanged.count(), 3);

        proxy.setModel(&model);
        QCOMPARE(spyOnModelChanged.count(), 3);
    }

    void setSameModelTwice() {
        QLimitProxyModelQML proxy;
        MockListModel model;

        proxy.setModel(&model);
        proxy.setModel(&model);

        QSignalSpy spyOnCountChanged(&proxy, &QLimitProxyModelQML::countChanged);

        model.insertRows(0, 5);
        QCOMPARE(proxy.rowCount(), 5);
        QCOMPARE(spyOnCountChanged.count(), 1);
    }

    void testMirrorModel() {
        QLimitProxyModelQML proxy;
        MockListModel model;
        MirrorModel mirror(&proxy);

        proxy.setModel(&model);
        proxy.setLimit(5);

        // Checks what happens when the model already has
        // more items than the limit and we add stuff to
        // the front
        model.insertRows(0, 7);
        mirror.check();
        model.insertRows(1, 3);
        mirror.check();
        model.clear();
        mirror.check();

        // Checks what happens when the model does
        // not has more items than limit but adding
        // stuff to its front makes it go past the limit
        model.insertRows(0, 3);
        mirror.check();
        model.insertRows(1, 3);
        mirror.check();
        model.clear();
        mirror.check();

        // Checks what happens when the model does
        // not has more items than limit and adding
        // stuff to its front makes it not go past the limit
        model.insertRows(0, 1);
        mirror.check();
        model.insertRows(1, 3);
        mirror.check();
        model.clear();
        mirror.check();

        // Checks what happens when the model already has
        // more items than the limit and we remove stuff from
        // the front but it still has more than the limit
        model.insertRows(0, 10);
        mirror.check();
        model.removeRows(1, 3);
        mirror.check();
        model.clear();
        mirror.check();

        // Checks what happens when the model already has
        // more items than the limit and we remove stuff from
        // the front but it has less than the limit
        model.insertRows(0, 6);
        mirror.check();
        model.removeRows(1, 3);
        mirror.check();
        model.clear();
        mirror.check();

        // Checks what happens when the model has
        // less items than the limit and we remove stuff from
        // the front
        model.insertRows(0, 4);
        mirror.check();
        model.removeRows(1, 3);
        mirror.check();
        model.clear();
        mirror.check();
    }
};

QTEST_GUILESS_MAIN(QLimitProxyModelTest)

#include "QLimitProxyModelTest.moc"
