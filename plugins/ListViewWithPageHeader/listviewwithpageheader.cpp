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

#include <QDebug>
#include <qqmlinfo.h>
#include <private/qquickvisualdatamodel_p.h>
#include <private/qqmlglobal_p.h>
#include <private/qquickitem_p.h>
// #include <private/qquickrectangle_p.h>

ListViewWithPageHeader::ListViewWithPageHeader()
 : m_delegateModel(nullptr)
 , m_delegateValidated(false)
 , m_firstVisibleIndex(-1)
 , m_minYExtent(0)
 , m_contentHeightDirty(false)
 , m_headerItem(nullptr)
 , m_previousContentY(0)
 , m_headerItemShownHeight(0)
{
    m_clipItem = new QQuickItem(contentItem());
//     m_clipItem = new QQuickRectangle(contentItem());
//     ((QQuickRectangle*)m_clipItem)->setColor(Qt::gray);

    connect(this, SIGNAL(contentWidthChanged()), this, SLOT(onContentWidthChanged()));
    connect(this, SIGNAL(contentHeightChanged()), this, SLOT(onContentHeightChanged()));
}

ListViewWithPageHeader::~ListViewWithPageHeader()
{
}

QAbstractItemModel *ListViewWithPageHeader::model() const
{
    return m_delegateModel ? m_delegateModel->model().value<QAbstractItemModel *>() : nullptr;
}

void ListViewWithPageHeader::setModel(QAbstractItemModel *model)
{
    if (model != this->model()) {
        if (!m_delegateModel) {
            createDelegateModel();
        } else {
            disconnect(m_delegateModel, SIGNAL(modelUpdated(QQuickChangeSet,bool)), this, SLOT(onModelUpdated(QQuickChangeSet,bool)));
        }
        m_delegateModel->setModel(QVariant::fromValue<QAbstractItemModel *>(model));
        connect(m_delegateModel, SIGNAL(modelUpdated(QQuickChangeSet,bool)), this, SLOT(onModelUpdated(QQuickChangeSet,bool)));
        Q_EMIT modelChanged();
        // TODO?
//         Q_EMIT contentHeightChanged();
//         Q_EMIT contentYChanged();
    }
}

QQmlComponent *ListViewWithPageHeader::delegate() const
{
    return m_delegateModel ? m_delegateModel->delegate() : nullptr;
}

void ListViewWithPageHeader::setDelegate(QQmlComponent *delegate)
{
    if (delegate != this->delegate()) {
        if (!m_delegateModel) {
            createDelegateModel();
        }

        // Cleanup the existing items
        foreach(QQuickItem *item, m_visibleItems)
            releaseItem(item);
        m_visibleItems.clear();
        m_firstVisibleIndex = -1;
        QQuickFlickable::setContentY(0);
        m_clipItem->setY(0);

        m_delegateModel->setDelegate(delegate);

        Q_EMIT delegateChanged();
        m_delegateValidated = false;
        m_contentHeightDirty = true;
        polish();
    }
}

QQuickItem *ListViewWithPageHeader::header() const
{
    return m_headerItem;
}

void ListViewWithPageHeader::setHeader(QQuickItem *headerItem)
{
    if (m_headerItem != headerItem) {
        qreal oldHeaderHeight = 0;
        qreal oldHeaderY = 0;
        if (m_headerItem) {
            oldHeaderHeight = m_headerItem->height();
            oldHeaderY = m_headerItem->y();
            QQuickItemPrivate::get(m_headerItem)->removeItemChangeListener(this, QQuickItemPrivate::Geometry);
        }
        m_headerItem = headerItem;
        if (m_headerItem) {
            m_headerItem->setParentItem(contentItem());
            m_headerItem->setZ(1);
            QQuickItemPrivate::get(m_headerItem)->addItemChangeListener(this, QQuickItemPrivate::Geometry);
        }
        qreal newHeaderHeight = m_headerItem ? m_headerItem->height() : 0;
        if (!m_visibleItems.isEmpty() && newHeaderHeight != oldHeaderHeight) {
            headerHeightChanged(newHeaderHeight, oldHeaderHeight, oldHeaderY);
            polish();
            m_contentHeightDirty = true;
        }
        Q_EMIT headerChanged();
    }
}

void ListViewWithPageHeader::positionAtBeginning()
{
    qreal headerHeight = (m_headerItem ? m_headerItem->height() : 0);
    if (m_firstVisibleIndex != 0) {
        // This could be optimized by trying to reuse the interesection
        // of items that may end up intersecting between the existing
        // m_visibleItems and the items we are creating in the next loop
        foreach(QQuickItem *item, m_visibleItems)
            releaseItem(item);
        m_visibleItems.clear();
        m_firstVisibleIndex = -1;

        // Create the item 0, it will be already correctly positioned at createItem()
        m_clipItem->setY(0);
        QQuickItem *item = createItem(0, false);
        // Create the subsequent items
        int modelIndex = 1;
        qreal pos = item->y() + item->height();
        const qreal buffer = height() / 2;
        const qreal bufferTo = height() + buffer;
        while (modelIndex < m_delegateModel->count() && pos <= bufferTo) {
            if (!(item = createItem(modelIndex, false)))
                break;
            pos += item->height();
            ++modelIndex;
        }

        m_previousContentY = m_visibleItems.first()->y() - headerHeight;
    }
    QQuickFlickable::setContentY(m_visibleItems.first()->y() + m_clipItem->y() - headerHeight);
}

void ListViewWithPageHeader::showHeader()
{
    // TODO
}

qreal ListViewWithPageHeader::minYExtent() const
{
//     qDebug() << "ListViewWithPageHeader::minYExtent" << m_minYExtent;
    return m_minYExtent;
}

void ListViewWithPageHeader::componentComplete()
{
    if (m_delegateModel)
        m_delegateModel->componentComplete();

    QQuickFlickable::componentComplete();

    polish();
}

void ListViewWithPageHeader::viewportMoved(Qt::Orientations orient)
{
    QQuickFlickable::viewportMoved(orient);
//     qDebug() << "ListViewWithPageHeader::viewportMoved" << contentY();
    qreal diff = m_previousContentY - contentY();
    if (m_headerItem) {
        auto oldHeaderItemShownHeight = m_headerItemShownHeight;
        if (contentY() < -m_minYExtent) {
            // Stick the header item to the top when dragging down
            m_headerItem->setY(contentY());
        } else {
            // We are going down (but it's not because of the rebound at the end)
            // (but the header was not shown by it's own position)
            // or the header is partially shown
            const bool scrolledUp = m_previousContentY > contentY();
            const bool notRebounding = contentY() + height() < contentHeight();
            const bool notShownByItsOwn = contentY() + diff > m_headerItem->y() + m_headerItem->height();

            if (!scrolledUp && contentY() == -m_minYExtent) {
                m_headerItemShownHeight = 0;
                m_headerItem->setY(contentY());
            } else if ((scrolledUp && notRebounding && notShownByItsOwn) || (m_headerItemShownHeight > 0)) {
                m_headerItemShownHeight += diff;
                if (contentY() == -m_minYExtent) {
                    m_headerItemShownHeight = 0;
                } else {
                    m_headerItemShownHeight = qBound(static_cast<qreal>(0.), m_headerItemShownHeight, m_headerItem->height());
                }
                if (m_headerItemShownHeight > 0) {
                    m_headerItem->setY(contentY() - m_headerItem->height() + m_headerItemShownHeight);
                } else {
                    m_headerItem->setY(-m_minYExtent);
                }
            }
        }
        // We will be changing the clip item, need to accomadate for it
        // otherwise we move the firstItem down/up twice
        diff += oldHeaderItemShownHeight - m_headerItemShownHeight;
    }
    if (!m_visibleItems.isEmpty()) {
        updateClipItem();
        QQuickItem *firstItem = m_visibleItems.first();
        firstItem->setY(firstItem->y() + diff);
    }
    m_previousContentY = contentY();
    polish();
}

void ListViewWithPageHeader::setContentY(qreal /*pos*/)
{
    qWarning() << "ListViewWithPageHeader::setContentY unsupported feature";
}

void ListViewWithPageHeader::createDelegateModel()
{
    m_delegateModel = new QQuickVisualDataModel(qmlContext(this), this);
    connect(m_delegateModel, SIGNAL(createdItem(int,QQuickItem*)), this, SLOT(itemCreated(int,QQuickItem*)));
    if (isComponentComplete())
        m_delegateModel->componentComplete();
}

void ListViewWithPageHeader::refill()
{
    if (!isComponentComplete()) {
        qWarning() << "Incomplete ListViewWithPageHeader::refill";
        return;
    }

    const qreal buffer = height() / 2;
    const qreal from = contentY();
    const qreal to = from + height();
    const qreal bufferFrom = from - buffer;
    const qreal bufferTo = to + buffer;

    bool added = addVisibleItems(from, to, false);
    bool removed = removeNonVisibleItems(bufferFrom, bufferTo);
    added |= addVisibleItems(bufferFrom, bufferTo, true);

    if (added || removed) {
        m_contentHeightDirty = true;
    }
}

bool ListViewWithPageHeader::addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous)
{
    if (!delegate())
        return false;

    if (m_delegateModel->count() == 0)
        return false;

    QQuickItem *item;
//     qDebug() << "ListViewWithPageHeader::addVisibleItems" << fillFrom << fillTo << asynchronous;

    int modelIndex = 0;
    qreal pos = 0;
    if (!m_visibleItems.isEmpty()) {
        modelIndex = m_firstVisibleIndex + m_visibleItems.count();
        item = m_visibleItems.last();
        pos = item->y() + item->height() + m_clipItem->y();
    }
    bool changed = false;
//     qDebug() << (modelIndex < m_delegateModel->count()) << pos << fillTo;
    while (modelIndex < m_delegateModel->count() && pos <= fillTo) {
//         qDebug() << "refill: append item" << modelIndex << "pos" << pos << "asynchronous" << asynchronous;
        if (!(item = createItem(modelIndex, asynchronous)))
            break;
        pos += item->height();
        ++modelIndex;
        changed = true;
    }

    modelIndex = 0;
    pos = 0;
    if (!m_visibleItems.isEmpty()) {
        modelIndex = m_firstVisibleIndex - 1;
        item = m_visibleItems.first();
        pos = item->y() + m_clipItem->y();
    }
    while (modelIndex >= 0 && pos > fillFrom) {
//         qDebug() << "refill: prepend item" << modelIndex << "pos" << pos << "fillFrom" << fillFrom << "asynchronous" << asynchronous;
        if (!(item = createItem(modelIndex, asynchronous)))
            break;
        pos -= item->height();
        --modelIndex;
        changed = true;
    }

    return changed;
}

void ListViewWithPageHeader::releaseItem(QQuickItem *item)
{
    QQuickItemPrivate *itemPrivate = QQuickItemPrivate::get(item);
    itemPrivate->removeItemChangeListener(this, QQuickItemPrivate::Geometry);
    QQuickVisualModel::ReleaseFlags flags = m_delegateModel->release(item);
    if (flags & QQuickVisualModel::Destroyed) {
        item->setParentItem(nullptr);
    }
}

bool ListViewWithPageHeader::removeNonVisibleItems(qreal bufferFrom, qreal bufferTo)
{
//     qDebug() << "ListViewWithPageHeader::removeNonVisibleItems" << bufferFrom << bufferTo;
    bool changed = false;

    bool foundVisible = false;
    int i = 0;
    int removedItems = 0;
    while (i < m_visibleItems.count()) {
        QQuickItem *item = m_visibleItems[i];
        const qreal pos = item->y() + m_clipItem->y();
//         qDebug() << i << pos << (pos + item->height()) << bufferFrom << bufferTo;
        if (pos + item->height() < bufferFrom || pos > bufferTo) {
//             qDebug() << "Releasing" << i << (pos + item->height() < bufferFrom) << pos + item->height() << bufferFrom << (pos > bufferTo) << pos << bufferTo;
            releaseItem(item);
            m_visibleItems.removeAt(i);
            changed = true;
            ++removedItems;
        } else {
            if (!foundVisible) {
                foundVisible = true;
                const int itemIndex = m_firstVisibleIndex + removedItems + i;
                m_firstVisibleIndex = itemIndex;
            }
            ++i;
        }
    }

    return changed;
}

QQuickItem *ListViewWithPageHeader::createItem(int modelIndex, bool asynchronous)
{
//     qDebug() << "CREATE ITEM" << modelIndex;
    if (asynchronous && m_asyncRequestedIndexes.contains(modelIndex))
        return nullptr;

    m_asyncRequestedIndexes.remove(modelIndex);
    QQuickItem *item = m_delegateModel->item(modelIndex, asynchronous);
    if (!item) {
        m_asyncRequestedIndexes << modelIndex;
        return 0;
    } else {
//         qDebug() << "ListViewWithPageHeader::createItem::We have the item" << modelIndex << item;
        QQuickItemPrivate::get(item)->addItemChangeListener(this, QQuickItemPrivate::Geometry);
        QQuickItem *prevItem = itemAtIndex(modelIndex - 1);
        if (prevItem) {
            item->setY(prevItem->y() + prevItem->height());
        } else {
            QQuickItem *nextItem = itemAtIndex(modelIndex + 1);
            if (nextItem) {
                item->setY(nextItem->y() - item->height());
            } else if (modelIndex == 0 && m_headerItem) {
                item->setY(m_headerItem->height());
            }
        }
        QQuickItemPrivate::get(item)->setCulled(item->y() + item->height() + m_clipItem->y() < contentY() || item->y() + m_clipItem->y() >= contentY() + height());
        if (m_visibleItems.isEmpty()) {
            m_visibleItems << item;
        } else {
            m_visibleItems.insert(modelIndex - m_firstVisibleIndex, item);
        }
        if (m_firstVisibleIndex < 0 || modelIndex < m_firstVisibleIndex) {
            m_firstVisibleIndex = modelIndex;
            adjustMinYExtent();
        }
        return item;
    }
}

void ListViewWithPageHeader::itemCreated(int modelIndex, QQuickItem *item)
{
//     qDebug() << "ListViewWithPageHeader::itemCreated" << modelIndex << item;

    item->setParentItem(m_clipItem);
    if (m_asyncRequestedIndexes.remove(modelIndex)) {
        createItem(modelIndex, false);
    }
}

void ListViewWithPageHeader::updateClipItem()
{
    m_clipItem->setHeight(height() - m_headerItemShownHeight);
    m_clipItem->setY(contentY() + m_headerItemShownHeight);
    m_clipItem->setClip(m_headerItemShownHeight > 0);
}

void ListViewWithPageHeader::onContentHeightChanged()
{
    updateClipItem();
}

void ListViewWithPageHeader::onContentWidthChanged()
{
    m_clipItem->setWidth(contentItem()->width());
}

void ListViewWithPageHeader::onModelUpdated(const QQuickChangeSet &changeSet, bool /*reset*/)
{
    // TODO Do something with reset
//     qDebug() << "ListViewWithPageHeader::onModelUpdated" << changeSet << reset;
    foreach(const QQuickChangeSet::Remove &remove, changeSet.removes()) {
//         qDebug() << "ListViewWithPageHeader::onModelUpdated Remove" << remove;
        if (remove.index + remove.count > m_firstVisibleIndex && remove.index < m_firstVisibleIndex + m_visibleItems.count()) {
            const qreal oldFirstValidIndexPos = m_visibleItems.first()->y();
            // If all the items we are removing are either not created or culled
            // we have to grow down to avoid viewport changing
            bool growDown = true;
            for (int i = 0; growDown && i < remove.count; ++i) {
                const int modelIndex = remove.index + i;
                QQuickItem *item = itemAtIndex(modelIndex);
                if (item && !QQuickItemPrivate::get(item)->culled) {
                    growDown = false;
                }
            }
            for (int i = remove.count - 1; i >= 0; --i) {
                const int visibleIndex = remove.index + i - m_firstVisibleIndex;
                if (visibleIndex >= 0 && visibleIndex < m_visibleItems.count()) {
                    QQuickItem *item = m_visibleItems[visibleIndex];
                    releaseItem(item);
                    m_visibleItems.removeAt(visibleIndex);
                }
            }
            if (growDown) {
                adjustMinYExtent();
            } else if (remove.index <= m_firstVisibleIndex && !m_visibleItems.isEmpty()) {
                // We removed the first item that is the one that positions the rest
                // position the new first item correctly
                m_visibleItems.first()->setY(oldFirstValidIndexPos);
            }
        } else if (remove.index + remove.count <= m_firstVisibleIndex) {
            m_firstVisibleIndex -= remove.count;
        }
    }

    foreach(const QQuickChangeSet::Insert &insert, changeSet.inserts()) {
//         qDebug() << "ListViewWithPageHeader::onModelUpdated Insert" << insert;
        const bool insertingInValidIndexes = insert.index > m_firstVisibleIndex && insert.index < m_firstVisibleIndex + m_visibleItems.count();
        const bool firstItemWithViewOnTop = insert.index == 0 && m_firstVisibleIndex == 0 && m_visibleItems.first()->y() + m_clipItem->y() > contentY();
        if (insertingInValidIndexes || firstItemWithViewOnTop)
        {
            // If the items we are adding won't be really visible
            // we grow up instead of down to not change the viewport
            bool growUp = false;
            if (!firstItemWithViewOnTop) {
                for (int i = 0; i < m_visibleItems.count(); ++i) {
                    if (!QQuickItemPrivate::get(m_visibleItems[i])->culled) {
                        if (insert.index <= m_firstVisibleIndex + i) {
                            growUp = true;
                        }
                        break;
                    }
                }
            }

            const qreal oldFirstValidIndexPos = m_visibleItems.first()->y();
            for (int i = insert.count - 1; i >= 0; --i) {
                const int modelIndex = insert.index + i;
                QQuickItem *item = createItem(modelIndex, false);
                if (growUp) {
                    QQuickItem *firstItem = m_visibleItems.first();
                    firstItem->setY(firstItem->y() - item->height());
                    adjustMinYExtent();
                }
            }
            if (firstItemWithViewOnTop) {
                QQuickItem *firstItem = m_visibleItems.first();
                firstItem->setY(oldFirstValidIndexPos);
            }
        } else if (insert.index <= m_firstVisibleIndex) {
            m_firstVisibleIndex += insert.count;
        }
    }

    polish();
    m_contentHeightDirty = true;
}

void ListViewWithPageHeader::itemGeometryChanged(QQuickItem *item, const QRectF &newGeometry, const QRectF &oldGeometry)
{
    const qreal heightDiff = newGeometry.height() - oldGeometry.height();
    if (heightDiff != 0) {
        if (item == m_headerItem) {
            headerHeightChanged(newGeometry.height(), oldGeometry.height(), oldGeometry.y());
        } else {
            if (oldGeometry.y() + oldGeometry.height() + m_clipItem->y() < contentY() && !m_visibleItems.isEmpty()) {
                item->setY(item->y() - heightDiff);
                if (m_visibleItems.first() == item) {
                    adjustMinYExtent();
                }
            }
        }
        polish();
        m_contentHeightDirty = true;
    }
}

void ListViewWithPageHeader::headerHeightChanged(qreal newHeaderHeight, qreal oldHeaderHeight, qreal oldHeaderY)
{
    const qreal heightDiff = newHeaderHeight - oldHeaderHeight;
    if (m_headerItemShownHeight > 0) {
        // If the header is shown because of the clip
        // Change its size
        m_headerItemShownHeight += heightDiff;
        m_headerItemShownHeight = qBound(static_cast<qreal>(0.), m_headerItemShownHeight, newHeaderHeight);
        updateClipItem();
        adjustMinYExtent();
    } else {
        if (oldHeaderY + oldHeaderHeight > contentY()) {
            // If the header is shown because its position
            // Change its size
            QQuickItem *firstItem = m_visibleItems.first();
            firstItem->setY(firstItem->y() + heightDiff);
        } else {
            // If the header is not on screen, just change the start of the list
            // so the viewport is not changed
            adjustMinYExtent();
        }
    }
}


void ListViewWithPageHeader::adjustMinYExtent()
{
    if (m_visibleItems.isEmpty()) {
        m_minYExtent = 0;
    } else {
        m_minYExtent = -m_visibleItems.first()->y() - m_clipItem->y() + (m_headerItem ? m_headerItem->height() : 0);
    }
}

QQuickItem *ListViewWithPageHeader::itemAtIndex(int modelIndex) const
{
    const int visibleIndexedModelIndex = modelIndex - m_firstVisibleIndex;
    if (visibleIndexedModelIndex >= 0 && visibleIndexedModelIndex < m_visibleItems.count())
        return m_visibleItems[visibleIndexedModelIndex];

    return nullptr;
}

void ListViewWithPageHeader::updatePolish()
{
    if (!model())
        return;

    if (!m_visibleItems.isEmpty()) {
        const qreal visibleFrom = contentY() - m_clipItem->y();
        const qreal visibleTo = contentY() + height() - m_clipItem->y();

        qreal pos = m_visibleItems.first()->y();

//         qDebug() << "ListViewWithPageHeader::updatePolish Updating positions and heights. contentY" << contentY() << "minYExtent" << minYExtent();
        foreach(QQuickItem *item, m_visibleItems) {
            QQuickItemPrivate::get(item)->setCulled(pos + item->height() < visibleFrom || pos >= visibleTo);
            item->setY(pos);
//             qDebug() << "ListViewWithPageHeader::updatePolish" << /*index << */pos + m_clipItem->y() << /*QQuickItemPrivate::get(item)->culled <<*/ (pos + item->height() < visibleFrom) << (pos > visibleTo);
            pos += item->height();
        }
    }

    refill();

    if (m_contentHeightDirty) {
        qreal contentHeight;
        const int modelCount = model()->rowCount();
        const int visibleItems = m_visibleItems.count();
        const int lastValidIndex = m_firstVisibleIndex + visibleItems - 1;
        if (lastValidIndex == modelCount - 1) {
            QQuickItem *item = m_visibleItems.last();
            contentHeight = item->y() + item->height() + m_clipItem->y();
            if (m_firstVisibleIndex != 0) {
                // Make sure that if we are shrinking we tell the view we still fit
                m_minYExtent = qMax(m_minYExtent, -(contentHeight - height()));
            }
        } else {
            contentHeight = m_headerItem ? m_headerItem->height() : 0;
            if (!m_visibleItems.isEmpty()) {
                foreach(QQuickItem *item, m_visibleItems) {
                    contentHeight += item->height();
                }
                const int unknownSizes = modelCount - visibleItems;
                contentHeight += unknownSizes * contentHeight / visibleItems;
            }
        }

        m_contentHeightDirty = false;
        setContentHeight(contentHeight);
    }
    
}
