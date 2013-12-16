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

#ifndef HORIZONTALJOURNAL_H
#define HORIZONTALJOURNAL_H

#include <QQuickItem>

class QAbstractItemModel;
class QQmlComponent;
#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
class QQuickVisualDataModel;
#else
class QQmlDelegateModel;
#endif

 /** A horizontal journal is a view that creates delegates
   * based on a model and layouts them one after the other
   * in the same row until there is no more free space for the next item
   * and so that item is layouted in the next row
   *
   * All delegates are forced to rowHeight if they don't have it.
   */
 class HorizontalJournal : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QQmlComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged)
    Q_PROPERTY(qreal rowHeight READ rowHeight WRITE setRowHeight NOTIFY rowHeightChanged)
    Q_PROPERTY(qreal horizontalSpacing READ horizontalSpacing WRITE setHorizontalSpacing NOTIFY horizontalSpacingChanged)
    Q_PROPERTY(qreal verticalSpacing READ verticalSpacing WRITE setVerticalSpacing NOTIFY verticalSpacingChanged)
    Q_PROPERTY(qreal delegateCreationBegin READ delegateCreationBegin WRITE setDelegateCreationBegin NOTIFY delegateCreationBeginChanged RESET resetDelegateCreationBegin)
    Q_PROPERTY(qreal delegateCreationEnd READ delegateCreationEnd WRITE setDelegateCreationEnd NOTIFY delegateCreationEndChanged RESET resetDelegateCreationEnd)

friend class HorizontalJournalTest;

public:
    HorizontalJournal();

    QAbstractItemModel *model() const;
    void setModel(QAbstractItemModel *model);

    QQmlComponent *delegate() const;
    void setDelegate(QQmlComponent *delegate);

    qreal rowHeight() const;
    void setRowHeight(qreal rowHeight);

    qreal horizontalSpacing() const;
    void setHorizontalSpacing(qreal horizontalSpacing);

    qreal verticalSpacing() const;
    void setVerticalSpacing(qreal verticalSpacing);

    qreal delegateCreationBegin() const;
    void setDelegateCreationBegin(qreal);
    void resetDelegateCreationBegin();

    qreal delegateCreationEnd() const;
    void setDelegateCreationEnd(qreal);
    void resetDelegateCreationEnd();

Q_SIGNALS:
    void modelChanged();
    void delegateChanged();
    void rowHeightChanged();
    void horizontalSpacingChanged();
    void verticalSpacingChanged();
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
    void createDelegateModel();
    void refill();
    void findBottomModelIndexToAdd(int *modelIndex, double *yPos);
    void findTopModelIndexToAdd(int *modelIndex, double *yPos);
    bool addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous);
    bool removeNonVisibleItems(qreal bufferFrom, qreal bufferTo);
    QQuickItem *createItem(int modelIndex, bool asynchronous);
    void positionItem(int modelIndex, QQuickItem *item);
    void doRelayout();

    void releaseItem(QQuickItem *item);

#if (QT_VERSION < QT_VERSION_CHECK(5, 1, 0))
    QQuickVisualDataModel *m_delegateModel;
#else
    QQmlDelegateModel *m_delegateModel;
#endif

    // Index we are waiting because we requested it asynchronously
    int m_asyncRequestedIndex;

    int m_firstVisibleIndex;
    QList<QQuickItem*> m_visibleItems;
    QMap<int, double> m_lastInRowIndexPosition;
    int m_rowHeight;
    int m_horizontalSpacing;
    int m_verticalSpacing;
    qreal m_delegateCreationBegin;
    qreal m_delegateCreationEnd;
    bool m_delegateCreationBeginValid;
    bool m_delegateCreationEndValid;
    bool m_needsRelayout;
    bool m_delegateValidated;
    bool m_implicitHeightDirty;
};

#endif
