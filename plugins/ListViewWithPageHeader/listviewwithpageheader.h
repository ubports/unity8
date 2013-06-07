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

#ifndef LISTVIEWWITHPAGEHEADER_H
#define LISTVIEWWITHPAGEHEADER_H

#include <private/qquickitemchangelistener_p.h>
#include <private/qquickflickable_p.h>

class QAbstractItemModel;
class QQuickChangeSet;
class QQuickVisualDataModel;

class ListViewWithPageHeader : public QQuickFlickable, public QQuickItemChangeListener
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QQmlComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged)
    Q_PROPERTY(QQuickItem *pageHeader READ header WRITE setHeader NOTIFY headerChanged)

    friend class ListViewWithPageHeaderTest;

public:
    ListViewWithPageHeader();
    ~ListViewWithPageHeader();

    QAbstractItemModel *model() const;
    void setModel(QAbstractItemModel *model);

    QQmlComponent *delegate() const;
    void setDelegate(QQmlComponent *delegate);

    QQuickItem *header() const;
    void setHeader(QQuickItem *header);

    Q_INVOKABLE void positionAtBeginning();
    Q_INVOKABLE void showHeader();

Q_SIGNALS:
    void modelChanged();
    void delegateChanged();
    void headerChanged();

protected:
    void componentComplete();
    void viewportMoved(Qt::Orientations orient);
    qreal minYExtent() const;
    void itemGeometryChanged(QQuickItem *item, const QRectF &newGeometry, const QRectF &oldGeometry);
    void updatePolish();

private Q_SLOTS:
    void itemCreated(int modelIndex, QQuickItem *item);
    void onContentHeightChanged();
    void onContentWidthChanged();
    void onModelUpdated(const QQuickChangeSet &changeSet, bool reset);

private:
    void setContentY(qreal pos);

    void createDelegateModel();

    void refill();
    bool addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous);
    bool removeNonVisibleItems(qreal bufferFrom, qreal bufferTo);
    QQuickItem *createItem(int modelIndex, bool asynchronous);

    void adjustMinYExtent();
    void updateClipItem();
    void headerHeightChanged(qreal newHeaderHeight, qreal oldHeaderHeight, qreal oldHeaderY);
    QQuickItem *itemAtIndex(int modelIndex) const; // Returns the item at modelIndex if has been created
    void releaseItem(QQuickItem *item);

    QQuickVisualDataModel *m_delegateModel;

    // List of indexes we are still waiting because we requested them asynchronously
    QSet<int> m_asyncRequestedIndexes;

    // Used to only give a warning once if the delegate does not return objects
    bool m_delegateValidated;

    // Visible indexes, [0] is m_firstValidIndex, [0+1] is m_firstValidIndex +1, ...
    QList<QQuickItem *> m_visibleItems;
    int m_firstVisibleIndex;

    qreal m_minYExtent;

    QQuickItem *m_clipItem;

    // If any of the heights has changed
    // or new items have been added/removed
    bool m_contentHeightDirty;

    QQuickItem *m_headerItem;
    qreal m_previousContentY;
    qreal m_headerItemShownHeight; // The height of header shown when the header is shown outside its topmost position
                                   // i.e. it's being shown after dragging down in the middle of the list
};


#endif
