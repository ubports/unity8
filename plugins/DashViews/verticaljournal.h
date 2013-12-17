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

#ifndef VERTICALJOURNAL_H
#define VERTICALJOURNAL_H

#include <QQuickItem>

class QAbstractItemModel;
class QQmlComponent;
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
class QQuickVisualDataModel;
#else
class QQmlDelegateModel;
#endif

 /** A vertical journal is a view that creates delegates
   * based on a model and layouts them in columns following
   * a top-left most position rule.
   *
   * The number of columns is calculated using the width of
   * the view itself, the columnWidth (i.e. the width of each individual delegate)
   * and the columnSpacing between columns.
   *
   * All delegates are forced to columnWidth if they don't have it.
   *
   * The first nColumns items are layouted at row 0 from column 0
   * to column nColumns-1 in order. After that every new item
   * is positioned in the column which provides the free topmost
   * position as possible. If more than one column tie in providing
   * the topmost free position the leftmost column will be used.
   *
   * Example:
   *
   * +-----+ +-----+ +-----+
   * |     | |  2  | |     |
   * |     | |     | |     |
   * |  1  | +-----+ |  3  |
   * |     | +-----+ |     |
   * |     | |     | +-----+
   * +-----+ |  4  | +-----+
   * +-----+ |     | |  5  |
   * |  6  | +-----+ |     |
   * |     |         +-----+
   * +-----+
   *
   */
 class VerticalJournal : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QQmlComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged)
    Q_PROPERTY(qreal columnWidth READ columnWidth WRITE setColumnWidth NOTIFY columnWidthChanged)
    Q_PROPERTY(qreal columnSpacing READ columnSpacing WRITE setColumnSpacing NOTIFY columnSpacingChanged)
    Q_PROPERTY(qreal rowSpacing READ rowSpacing WRITE setRowSpacing NOTIFY rowSpacingChanged)
    Q_PROPERTY(qreal delegateCreationBegin READ delegateCreationBegin
                                           WRITE setDelegateCreationBegin
                                           NOTIFY delegateCreationBeginChanged
                                           RESET resetDelegateCreationBegin)
    Q_PROPERTY(qreal delegateCreationEnd READ delegateCreationEnd
                                         WRITE setDelegateCreationEnd
                                         NOTIFY delegateCreationEndChanged
                                         RESET resetDelegateCreationEnd)

friend class VerticalJournalTest;

public:
    VerticalJournal();

    QAbstractItemModel *model() const;
    void setModel(QAbstractItemModel *model);

    QQmlComponent *delegate() const;
    void setDelegate(QQmlComponent *delegate);

    qreal columnWidth() const;
    void setColumnWidth(qreal columnWidth);

    qreal columnSpacing() const;
    void setColumnSpacing(qreal columnSpacing);

    qreal rowSpacing() const;
    void setRowSpacing(qreal rowSpacing);

    qreal delegateCreationBegin() const;
    void setDelegateCreationBegin(qreal);
    void resetDelegateCreationBegin();

    qreal delegateCreationEnd() const;
    void setDelegateCreationEnd(qreal);
    void resetDelegateCreationEnd();

Q_SIGNALS:
    void modelChanged();
    void delegateChanged();
    void columnWidthChanged();
    void columnSpacingChanged();
    void rowSpacingChanged();
    void delegateCreationBeginChanged();
    void delegateCreationEndChanged();

protected:
    void updatePolish();
    void componentComplete();

private Q_SLOTS:
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    void itemCreated(int modelIndex, QQuickItem *item);
#else
    void itemCreated(int modelIndex, QObject *object);
#endif
    void relayout();
    void onHeightChanged();

private:
    class ViewItem
    {
        public:
            ViewItem(QQuickItem *item, int modelIndex) : m_item(item), m_modelIndex(modelIndex) {}
            qreal x() const { return m_item->x(); }
            qreal y() const { return m_item->y(); }
            qreal height() const { return m_item->height(); }
            bool operator<(const ViewItem &v) const { return m_modelIndex < v.m_modelIndex; }

            QQuickItem *m_item;
            int m_modelIndex;
    };

    void createDelegateModel();
    void refill();
    void findBottomModelIndexToAdd(int *modelIndex, qreal *yPos);
    void findTopModelIndexToAdd(int *modelIndex, qreal *yPos);
    bool addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous);
    bool removeNonVisibleItems(qreal bufferFrom, qreal bufferTo);
    QQuickItem *createItem(int modelIndex, bool asynchronous);
    void positionItem(int modelIndex, QQuickItem *item);
    void cleanupExistingItems();
    void releaseItem(const ViewItem &item);
    void calculateImplicitHeight();

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    QQuickVisualDataModel *m_delegateModel;
#else
    QQmlDelegateModel *m_delegateModel;
#endif

    // Index we are waiting because we requested it asynchronously
    int m_asyncRequestedIndex;

    QVector<QList<ViewItem>> m_columnVisibleItems;
    QHash<int, int> m_indexColumnMap;
    int m_columnWidth;
    int m_columnSpacing;
    int m_rowSpacing;
    qreal m_delegateCreationBegin;
    qreal m_delegateCreationEnd;
    bool m_delegateCreationBeginValid;
    bool m_delegateCreationEndValid;
    bool m_needsRelayout;
    bool m_delegateValidated;
    bool m_implicitHeightDirty;
};

#endif
