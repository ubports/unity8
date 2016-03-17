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
 */

#include "listviewwithpageheader.h"

#include <QAbstractItemModel>
#include <QQmlEngine>
#include <QQuickView>
#include <QSignalSpy>
#include <QSortFilterProxyModel>
#include <QtTestGui>
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-pedantic"
#include <private/qqmllistmodel_p.h>
#include <private/qquickanimation_p.h>
#include <private/qquickitem_p.h>
#pragma GCC diagnostic pop

class StringListModel : public QAbstractListModel
{
public:
    StringListModel()
    {
        list << "A" << "B" << "C" << "D" << "E" << "F" << "G" << "H";
    }

    int rowCount(const QModelIndex &parent) const override
    {
        if (parent.isValid())
            return 0;
        else
            return list.count();
    }

    QVariant data(const QModelIndex &index, int role) const override
    {
        if (role == Qt::SizeHintRole) return 50;
        else if (role == Qt::DisplayRole) return list[index.row()];
        return QVariant();
    }

    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> hash;
        hash.insert(Qt::DisplayRole, "type");
        hash.insert(Qt::SizeHintRole, "size");
        return hash;
    }

    void moveLastToFirst()
    {
        const int last = list.count() - 1;
        beginMoveRows(QModelIndex(), last, last, QModelIndex(), 0);
        list.move(last, 0);
        endMoveRows();
    }

    QStringList list;
};

class ListViewWithPageHeaderTestSection : public QObject
{
    Q_OBJECT

private:
    void verifyItem(int visibleIndex, qreal pos, qreal height, bool culled, const QString &sectionHeader, bool sectionHeaderCulled)
    {
        QTRY_VERIFY(visibleIndex < lvwph->m_visibleItems.count());
        QTRY_COMPARE(lvwph->m_visibleItems[visibleIndex]->y(), pos);
        QTRY_COMPARE(lvwph->m_visibleItems[visibleIndex]->height(), height);
        QCOMPARE(QQuickItemPrivate::get(lvwph->m_visibleItems[visibleIndex]->m_item)->culled, culled);
        QCOMPARE(section(lvwph->m_visibleItems[visibleIndex]->sectionItem()), sectionHeader);
        if (!sectionHeader.isNull()) {
            QCOMPARE(QQuickItemPrivate::get(lvwph->m_visibleItems[visibleIndex]->sectionItem())->culled, sectionHeaderCulled);
            QCOMPARE(sectionDelegateIndex(lvwph->m_visibleItems[visibleIndex]->sectionItem()), lvwph->m_firstVisibleIndex + visibleIndex);
        }
    }

    void changeContentY(qreal change)
    {
        const qreal dest = lvwph->contentY() + change;
        if (dest > lvwph->contentY()) {
            const qreal jump = 25;
            while (lvwph->contentY() + jump < dest) {
                lvwph->setContentY(lvwph->contentY() + jump);
                QTest::qWait(1);
            }
        } else {
            const qreal jump = -25;
            while (lvwph->contentY() + jump > dest) {
                lvwph->setContentY(lvwph->contentY() + jump);
                QTest::qWait(1);
            }
        }
        lvwph->setContentY(dest);
        QTest::qWait(1);
    }

    void scrollToTop()
    {
        const qreal jump = -25;
        while (!lvwph->isAtYBeginning()) {
            if (lvwph->contentY() + jump > -lvwph->minYExtent()) {
                lvwph->setContentY(lvwph->contentY() + jump);
            } else {
                lvwph->setContentY(lvwph->contentY() - 1);
            }
            QTest::qWait(1);
        }
    }

    void scrollToBottom()
    {
        const qreal jump = 25;
        while (!lvwph->isAtYEnd()) {
            if (lvwph->contentY() + lvwph->height() + jump < lvwph->contentHeight()) {
                lvwph->setContentY(lvwph->contentY() + jump);
            } else {
                lvwph->setContentY(lvwph->contentY() + 1);
            }
            QTest::qWait(1);
        }
    }

    void verifyInitialTopPosition()
    {
        QTRY_COMPARE(lvwph->m_visibleItems.count(), 0);
        QCOMPARE(lvwph->m_firstVisibleIndex, -1);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

    QString section(QQuickItem *item)
    {
        return item ? item->property("text").toString() : QString();
    }

    int sectionDelegateIndex(QQuickItem *item)
    {
        return item ? item->property("delegateIndex").toInt() : -1;
    }

private Q_SLOTS:

    void initTestCase()
    {
    }

    void init()
    {
        view = new QQuickView();
        view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/listviewwithpageheadertestsectionexternalmodel.qml"));
        lvwph = dynamic_cast<ListViewWithPageHeader*>(view->rootObject()->findChild<QQuickFlickable*>());
        QVERIFY(lvwph);
        view->show();
        QTest::qWaitForWindowExposed(view);

        verifyInitialTopPosition();
    }

    void cleanup()
    {
        delete view;
    }

    void testCreationDeletion()
    {
        // Nothing, init/cleanup already tests this
    }

    void testMoveWithProxy()
    {
        StringListModel m;
        QSortFilterProxyModel proxy;
        proxy.setSourceModel(&m);

        lvwph->setModel(&proxy);

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 8);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 90., false, "A", false);
        verifyItem(1, 140., 90., false, "B", false);
        verifyItem(2, 230., 90., false, "C", false);
        verifyItem(3, 320., 90., false, "D", false);
        verifyItem(4, 410., 90., false, "E", false);
        verifyItem(5, 500., 90., false, "F", false);
        verifyItem(6, 590., 90., true, "G", true);
        verifyItem(7, 680., 90., true, "H", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);

        m.moveLastToFirst();

        QTRY_COMPARE(lvwph->m_visibleItems.count(), 8);
        QCOMPARE(lvwph->m_firstVisibleIndex, 0);
        verifyItem(0, 50., 90., false, "H", false);
        verifyItem(1, 140., 90., false, "A", false);
        verifyItem(2, 230., 90., false, "B", false);
        verifyItem(3, 320., 90., false, "C", false);
        verifyItem(4, 410., 90., false, "D", false);
        verifyItem(5, 500., 90., false, "E", false);
        verifyItem(6, 590., 90., true, "F", true);
        verifyItem(7, 680., 90., true, "G", true);
        QCOMPARE(lvwph->m_minYExtent, 0.);
        QCOMPARE(lvwph->m_clipItem->y(), 0.);
        QCOMPARE(lvwph->m_clipItem->clip(), false);
        QCOMPARE(lvwph->m_headerItem->y(), 0.);
        QCOMPARE(lvwph->m_headerItem->height(), 50.);
        QCOMPARE(lvwph->contentY(), 0.);
        QCOMPARE(lvwph->m_headerItemShownHeight, 0.);
        QVERIFY(QQuickItemPrivate::get(lvwph->m_topSectionItem)->culled);
    }

private:
    QQuickView *view;
    ListViewWithPageHeader *lvwph;
};

QTEST_MAIN(ListViewWithPageHeaderTestSection)

#include "listviewwithpageheadersectionexternalmodeltest.moc"
