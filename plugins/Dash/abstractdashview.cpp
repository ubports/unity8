/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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

#include "abstractdashview.h"

#include <private/qquickitem_p.h>

AbstractDashView::AbstractDashView()
 : m_delegateModel(nullptr)
 , m_asyncRequestedIndex(-1)
 , m_columnSpacing(0)
 , m_rowSpacing(0)
 , m_buffer(320) // Same value used in qquickitemview.cpp in Qt 5.4
 , m_displayMarginBeginning(0)
 , m_displayMarginEnd(0)
 , m_needsRelayout(false)
 , m_delegateValidated(false)
 , m_implicitHeightDirty(false)
{
    connect(this, &AbstractDashView::widthChanged, this, &AbstractDashView::relayout);
    connect(this, &AbstractDashView::heightChanged, this, &AbstractDashView::onHeightChanged);
}

QAbstractItemModel *AbstractDashView::model() const
{
    return m_delegateModel ? m_delegateModel->model().value<QAbstractItemModel *>() : nullptr;
}

void AbstractDashView::setModel(QAbstractItemModel *model)
{
    if (model != this->model()) {
        if (!m_delegateModel) {
            createDelegateModel();
        } else {
            disconnect(m_delegateModel, &QQmlDelegateModel::modelUpdated, this, &AbstractDashView::onModelUpdated);
        }
        m_delegateModel->setModel(QVariant::fromValue<QAbstractItemModel *>(model));
        connect(m_delegateModel, &QQmlDelegateModel::modelUpdated, this, &AbstractDashView::onModelUpdated);

        cleanupExistingItems();

        Q_EMIT modelChanged();
        polish();
    }
}

QQmlComponent *AbstractDashView::delegate() const
{
    return m_delegateModel ? m_delegateModel->delegate() : nullptr;
}

void AbstractDashView::setDelegate(QQmlComponent *delegate)
{
    if (delegate != this->delegate()) {
        if (!m_delegateModel) {
            createDelegateModel();
        }

        cleanupExistingItems();

        m_delegateModel->setDelegate(delegate);

        Q_EMIT delegateChanged();
        m_delegateValidated = false;
        polish();
    }
}

qreal AbstractDashView::columnSpacing() const
{
    return m_columnSpacing;
}

void AbstractDashView::setColumnSpacing(qreal columnSpacing)
{
    if (columnSpacing != m_columnSpacing) {
        m_columnSpacing = columnSpacing;
        Q_EMIT columnSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

qreal AbstractDashView::rowSpacing() const
{
    return m_rowSpacing;
}

void AbstractDashView::setRowSpacing(qreal rowSpacing)
{
    if (rowSpacing != m_rowSpacing) {
        m_rowSpacing = rowSpacing;
        Q_EMIT rowSpacingChanged();

        if (isComponentComplete()) {
            relayout();
        }
    }
}

int AbstractDashView::cacheBuffer() const
{
    return m_buffer;
}

void AbstractDashView::setCacheBuffer(int buffer)
{
    if (buffer < 0) {
        qmlInfo(this) << "Cannot set a negative cache buffer";
        return;
    }

    if (m_buffer != buffer) {
        m_buffer = buffer;
        if (isComponentComplete()) {
            polish();
        }
        emit cacheBufferChanged();
    }
}

qreal AbstractDashView::displayMarginBeginning() const
{
    return m_displayMarginBeginning;
}

void AbstractDashView::setDisplayMarginBeginning(qreal begin)
{
    if (m_displayMarginBeginning == begin)
        return;
    m_displayMarginBeginning = begin;
    if (isComponentComplete()) {
        polish();
    }
    emit displayMarginBeginningChanged();
}

qreal AbstractDashView::displayMarginEnd() const
{
    return m_displayMarginEnd;
}

void AbstractDashView::setDisplayMarginEnd(qreal end)
{
    if (m_displayMarginEnd == end)
        return;
    m_displayMarginEnd = end;
    if (isComponentComplete()) {
        polish();
    }
    emit displayMarginEndChanged();
}

void AbstractDashView::createDelegateModel()
{
    m_delegateModel = new QQmlDelegateModel(qmlContext(this), this);
    connect(m_delegateModel, &QQmlDelegateModel::createdItem, this, &AbstractDashView::itemCreated);
    if (isComponentComplete())
        m_delegateModel->componentComplete();
}

void AbstractDashView::refill()
{
    if (!isComponentComplete() || height() < 0) {
        return;
    }

    const qreal from = -m_displayMarginBeginning;
    const qreal to = height() + m_displayMarginEnd;
    const qreal bufferFrom = from - m_buffer;
    const qreal bufferTo = to + m_buffer;

    bool added = addVisibleItems(from, to, false);
    bool removed = removeNonVisibleItems(bufferFrom, bufferTo);
    added |= addVisibleItems(bufferFrom, bufferTo, true);

    if (added || removed) {
        m_implicitHeightDirty = true;
        polish();
    }
}

bool AbstractDashView::addVisibleItems(qreal fillFromY, qreal fillToY, bool asynchronous)
{
    if (fillToY <= fillFromY)
        return false;

    if (!delegate())
        return false;

    if (m_delegateModel->count() == 0)
        return false;

    int modelIndex;
    qreal yPos;
    findBottomModelIndexToAdd(&modelIndex, &yPos);
    bool changed = false;
    while (modelIndex < m_delegateModel->count() && yPos <= fillToY) {
        if (!createItem(modelIndex, asynchronous))
            break;

        changed = true;
        findBottomModelIndexToAdd(&modelIndex, &yPos);
    }

    findTopModelIndexToAdd(&modelIndex, &yPos);
    while (modelIndex >= 0 && yPos > fillFromY) {
        if (!createItem(modelIndex, asynchronous))
            break;

        changed = true;
        findTopModelIndexToAdd(&modelIndex, &yPos);
    }

    return changed;
}

QQuickItem *AbstractDashView::createItem(int modelIndex, bool asynchronous)
{
    if (asynchronous && m_asyncRequestedIndex != -1)
        return nullptr;

    m_asyncRequestedIndex = -1;
    QObject* object = m_delegateModel->object(modelIndex, asynchronous);
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
    if (!item) {
        if (object) {
            m_delegateModel->release(object);
            if (!m_delegateValidated) {
                m_delegateValidated = true;
                QObject* delegateObj = delegate();
                qmlInfo(delegateObj ? delegateObj : this) << "Delegate must be of Item type";
            }
        } else {
            m_asyncRequestedIndex = modelIndex;
        }
        return nullptr;
    } else {
        QQuickItemPrivate::get(item)->addItemChangeListener(this, QQuickItemPrivate::Geometry);
        addItemToView(modelIndex, item);
        return item;
    }
}

void AbstractDashView::releaseItem(QQuickItem *item)
{
    QQuickItemPrivate::get(item)->removeItemChangeListener(this, QQuickItemPrivate::Geometry);
    QQmlDelegateModel::ReleaseFlags flags = m_delegateModel->release(item);
    if (flags & QQmlDelegateModel::Destroyed) {
        item->setParentItem(nullptr);
    }
}

void AbstractDashView::setImplicitHeightDirty()
{
    m_implicitHeightDirty = true;
}

void AbstractDashView::itemCreated(int modelIndex, QObject *object)
{
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
    if (!item) {
        qWarning() << "AbstractDashView::itemCreated got a non item for index" << modelIndex;
        return;
    }
    item->setParentItem(this);

    // We only need to call createItem if we are here because of an asynchronous generation
    // otherwise we are in this slot because createItem is creating the item sync
    // and thus we don't need to call createItem again, nor need to set m_implicitHeightDirty
    // and call polish because the sync createItem was called from addVisibleItems that
    // is called from refill that will already do those if an item was added
    if (modelIndex == m_asyncRequestedIndex) {
        createItem(modelIndex, false);
        m_implicitHeightDirty = true;
        polish();
    }
}

void AbstractDashView::onModelUpdated(const QQmlChangeSet &changeSet, bool reset)
{
    if (reset) {
        cleanupExistingItems();
    } else {
        processModelRemoves(changeSet.removes());

        // The current AbstractDashViews do not support insertions that are not at the end
        // so reset if that happens
        Q_FOREACH(const QQmlChangeSet::Change insert, changeSet.inserts()) {
            if (insert.index < m_delegateModel->count() - 1) {
                cleanupExistingItems();
                break;
            }
        }
    }
    polish();
}


void AbstractDashView::relayout()
{
    m_needsRelayout = true;
    polish();
}

void AbstractDashView::onHeightChanged()
{
    polish();
}

void AbstractDashView::updatePolish()
{
    if (!model())
        return;

    if (m_needsRelayout) {
        doRelayout();
        m_needsRelayout = false;
        m_implicitHeightDirty = true;
    }

    refill();

    const qreal from = -m_displayMarginBeginning;
    const qreal to = height() + m_displayMarginEnd;
    updateItemCulling(from, to);

    if (m_implicitHeightDirty) {
        calculateImplicitHeight();
        m_implicitHeightDirty = false;
    }
}

void AbstractDashView::componentComplete()
{
    if (m_delegateModel)
        m_delegateModel->componentComplete();

    QQuickItem::componentComplete();

    m_needsRelayout = true;

    polish();
}
