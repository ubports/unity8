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

/*
 * Some documentation on how this thing works:
 *
 * A flickable has two very important concepts that define the top and
 * height of the flickable area.
 * The top is returned in minYExtent()
 * The height is set using setContentHeight()
 * By changing those two values we can make the list grow up or down
 * as needed. e.g. if we are in the middle of the list
 * and something that is above the viewport grows, since we do not
 * want to change the viewport because of that we just adjust the
 * minYExtent so that the list grows up.
 *
 * The implementation on the list relies on the delegateModel doing
 * most of the instantiation work. You call createItem() when you
 * need to create an item asking for it async or not. If returns null
 * it means the item will be created async and the model will call the
 * itemCreated slot with the item.
 *
 * updatePolish is the central point of dispatch for the work of the
 * class. It is called by the scene graph just before drawing the class.
 * In it we:
 *  * Make sure all items are positioned correctly
 *  * Add/Remove items if needed
 *  * Update the content height if it was dirty
 *
 * m_visibleItems contains all the items we have created at the moment.
 * Actually not all of them are visible since it includes the ones
 * in the cache area we create asynchronously to help performance.
 * The first item in m_visibleItems has the m_firstVisibleIndex in
 * the model. If you actually want to know what is the first
 * item in the viewport you have to find the first non culled element
 * in m_visibleItems
 *
 * All the items (except the header) are childs of m_clipItem which
 * is a child of the contentItem() of the flickable (The contentItem()
 * is what actually 'moves' in a a flickable). This way
 * we can implement the clipping needed so we can have the header
 * shown in the middle of the list over the items without the items
 * leaking under the header in case it is transparent.
 *
 * The first item of m_visibleItems is the one that defines the
 * positions of all the rest of items (see updatePolish()) and
 * this is why sometimes we move it even if it's not the item
 * that has triggered the function (i.e. in itemGeometryChanged())
 *
 * m_visibleItems is a list of ListItem. Each ListItem
 * will contain a item and potentially a sectionItem. The sectionItem
 * is only there when the list is using sectionDelegate+sectionProperty
 * and this is the first item of the section. Each ListItem is vertically
 * layouted with the sectionItem first and then the item.
 *
 * For sectioning we also have a section item alone (m_topSectionItem)
 * that is used for the cases we need to show the sticky section item at
 * the top of the view.
 *
 * Each delegate item has a context property called heightToClip that is
 * used to communicate to the delegate implementation in case it has to
 * clip itself because of overlapping with the top sticky section item.
 * This is an implementation decision since it has been agreed it
 * is easier to implement the clipping in QML with this info than to
 * do it at the C++ level.
 *
 * Note that minYExtent and height are not always totally accurate, since
 * we don't have the items created we can't guess their heights
 * so we can only guarantee the values are correct when the first/last
 * items of the list are visible, otherwise we just live with good enough
 * values that make the list scrollable
 *
 * There are a few things that are not really implemented or tested properly
 * which we don't use at the moment like changing the model, changing
 * the section delegate, having a section delegate that changes its size, etc.
 * The known missing features are marked with TODOs along the code.
 */

#include "listviewwithpageheader.h"

#include <QCoreApplication>
#include <QDebug>
#include <qqmlinfo.h>
#include <qqmlengine.h>
#include <private/qqmlcontext_p.h>
#include <private/qqmldelegatemodel_p.h>
#include <private/qqmlglobal_p.h>
#include <private/qquickitem_p.h>
#include <private/qquickanimation_p.h>
// #include <private/qquickrectangle_p.h>

qreal ListViewWithPageHeader::ListItem::height() const
{
    return m_item->height() + (m_sectionItem ? m_sectionItem->height() : 0);
}

qreal ListViewWithPageHeader::ListItem::y() const
{
    return m_item->y() - (m_sectionItem ? m_sectionItem->height() : 0);
}

void ListViewWithPageHeader::ListItem::setY(qreal newY)
{
    if (m_sectionItem) {
        m_sectionItem->setY(newY);
        m_item->setY(newY + m_sectionItem->height());
    } else {
        m_item->setY(newY);
    }
}

bool ListViewWithPageHeader::ListItem::culled() const
{
    return QQuickItemPrivate::get(m_item)->culled;
}

void ListViewWithPageHeader::ListItem::setCulled(bool culled)
{
    QQuickItemPrivate::get(m_item)->setCulled(culled);
    if (m_sectionItem)
        QQuickItemPrivate::get(m_sectionItem)->setCulled(culled);
}

void ListViewWithPageHeader::ListItem::setSectionItem(QQuickItem *sectionItem)
{
    m_sectionItem = sectionItem;
}

ListViewWithPageHeader::ListViewWithPageHeader()
 : m_delegateModel(nullptr)
 , m_asyncRequestedIndex(-1)
 , m_delegateValidated(false)
 , m_firstVisibleIndex(-1)
 , m_minYExtent(0)
 , m_contentHeightDirty(false)
 , m_headerItem(nullptr)
 , m_previousContentY(0)
 , m_headerItemShownHeight(0)
 , m_sectionDelegate(nullptr)
 , m_topSectionItem(nullptr)
 , m_forceNoClip(false)
 , m_inLayout(false)
 , m_inContentHeightKeepHeaderShown(false)
 , m_cacheBuffer(0)
{
    m_clipItem = new QQuickItem(contentItem());
//     m_clipItem = new QQuickRectangle(contentItem());
//     ((QQuickRectangle*)m_clipItem)->setColor(Qt::gray);

    m_contentYAnimation = new QQuickNumberAnimation(this);
    m_contentYAnimation->setEasing(QEasingCurve::OutQuad);
    m_contentYAnimation->setProperty(QStringLiteral("contentY"));
    m_contentYAnimation->setDuration(200);
    m_contentYAnimation->setTargetObject(this);

    connect(contentItem(), &QQuickItem::widthChanged, this, &ListViewWithPageHeader::onContentWidthChanged);
    connect(this, &ListViewWithPageHeader::contentHeightChanged, this, &ListViewWithPageHeader::onContentHeightChanged);
    connect(this, &ListViewWithPageHeader::heightChanged, this, &ListViewWithPageHeader::onHeightChanged);
    connect(m_contentYAnimation, &QQuickNumberAnimation::runningChanged, this, &ListViewWithPageHeader::contentYAnimationRunningChanged);

    setFlickableDirection(VerticalFlick);
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
            disconnect(m_delegateModel, &QQmlDelegateModel::modelUpdated, this, &ListViewWithPageHeader::onModelUpdated);
        }
        m_delegateModel->setModel(QVariant::fromValue<QAbstractItemModel *>(model));
        connect(m_delegateModel, &QQmlDelegateModel::modelUpdated, this, &ListViewWithPageHeader::onModelUpdated);
        Q_EMIT modelChanged();
        polish();
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
        Q_FOREACH(ListItem *item, m_visibleItems)
            releaseItem(item);
        m_visibleItems.clear();
        initializeValuesForEmptyList();

        m_delegateModel->setDelegate(delegate);

        Q_EMIT delegateChanged();
        m_delegateValidated = false;
        m_contentHeightDirty = true;
        polish();
    }
}

void ListViewWithPageHeader::initializeValuesForEmptyList()
{
    m_firstVisibleIndex = -1;
    adjustMinYExtent();
    setContentY(0);
    m_clipItem->setY(0);
    if (m_topSectionItem) {
        QQuickItemPrivate::get(m_topSectionItem)->setCulled(true);
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
            m_headerItem->setParentItem(nullptr);
            QQuickItemPrivate::get(m_headerItem)->removeItemChangeListener(this, QQuickItemPrivate::ImplicitHeight);
        }
        m_headerItem = headerItem;
        if (m_headerItem) {
            m_headerItem->setParentItem(contentItem());
            m_headerItem->setZ(1);
            m_previousHeaderImplicitHeight = m_headerItem->implicitHeight();
            QQuickItemPrivate::get(m_headerItem)->addItemChangeListener(this, QQuickItemPrivate::ImplicitHeight);
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

QQmlComponent *ListViewWithPageHeader::sectionDelegate() const
{
    return m_sectionDelegate;
}

void ListViewWithPageHeader::setSectionDelegate(QQmlComponent *delegate)
{
    if (delegate != m_sectionDelegate) {
        // TODO clean existing sections

        m_sectionDelegate = delegate;

        m_topSectionItem = getSectionItem(QString(), false /*watchGeometry*/);
        if (m_topSectionItem) {
            m_topSectionItem->setZ(3);
            QQuickItemPrivate::get(m_topSectionItem)->setCulled(true);
            connect(m_topSectionItem, &QQuickItem::heightChanged, this, &ListViewWithPageHeader::stickyHeaderHeightChanged);
        }

        // TODO create sections for existing items

        Q_EMIT sectionDelegateChanged();
        Q_EMIT stickyHeaderHeightChanged();
    }
}

QString ListViewWithPageHeader::sectionProperty() const
{
    return m_sectionProperty;
}

void ListViewWithPageHeader::setSectionProperty(const QString &property)
{
    if (property != m_sectionProperty) {
        m_sectionProperty = property;

        updateWatchedRoles();

        // TODO recreate sections

        Q_EMIT sectionPropertyChanged();
    }
}

bool ListViewWithPageHeader::forceNoClip() const
{
    return m_forceNoClip;
}

void ListViewWithPageHeader::setForceNoClip(bool noClip)
{
    if (noClip != m_forceNoClip) {
        m_forceNoClip = noClip;
        updateClipItem();
        Q_EMIT forceNoClipChanged();
    }
}

int ListViewWithPageHeader::stickyHeaderHeight() const
{
    return m_topSectionItem ? m_topSectionItem->height() : 0;
}

qreal ListViewWithPageHeader::headerItemShownHeight() const
{
    return m_headerItemShownHeight;
}

int ListViewWithPageHeader::cacheBuffer() const
{
    return m_cacheBuffer;
}

void ListViewWithPageHeader::setCacheBuffer(int cacheBuffer)
{
    if (cacheBuffer < 0) {
        qmlInfo(this) << "Cannot set a negative cache buffer";
        return;
    }

    if (cacheBuffer != m_cacheBuffer) {
        m_cacheBuffer = cacheBuffer;
        Q_EMIT cacheBufferChanged();
        polish();
    }
}

void ListViewWithPageHeader::positionAtBeginning()
{
    if (m_delegateModel->count() <= 0)
        return;

    qreal headerHeight = (m_headerItem ? m_headerItem->height() : 0);
    if (m_firstVisibleIndex != 0) {
        // TODO This could be optimized by trying to reuse the interesection
        // of items that may end up intersecting between the existing
        // m_visibleItems and the items we are creating in the next loop
        Q_FOREACH(ListItem *item, m_visibleItems)
            releaseItem(item);
        m_visibleItems.clear();
        m_firstVisibleIndex = -1;

        // Create the item 0, it will be already correctly positioned at createItem()
        m_clipItem->setY(0);
        ListItem *item = createItem(0, false);
        // Create the subsequent items
        int modelIndex = 1;
        qreal pos = item->y() + item->height();
        const qreal bufferTo = height() + m_cacheBuffer;
        while (modelIndex < m_delegateModel->count() && pos <= bufferTo) {
            if (!(item = createItem(modelIndex, false)))
                break;
            pos += item->height();
            ++modelIndex;
        }

        m_previousContentY = m_visibleItems.first()->y() - headerHeight;
    }
    setContentY(m_visibleItems.first()->y() + m_clipItem->y() - headerHeight);
    if (m_headerItem) {
        // TODO This should not be needed and the code that adjust the m_headerItem position
        // in viewportMoved() should be enough but in some cases we have not found a way to reproduce
        // yet the code of viewportMoved() fails so here we make sure that at least if we are calling
        // positionAtBeginning the header item will be correctly positioned
        m_headerItem->setY(-m_minYExtent);
    }
}

static inline bool uFuzzyCompare(qreal r1, qreal r2)
{
    return qFuzzyCompare(r1, r2) || (qFuzzyIsNull(r1) && qFuzzyIsNull(r2));
}

void ListViewWithPageHeader::showHeader()
{
    if (!m_headerItem)
        return;

    const auto to = qMax(-minYExtent(), contentY() - m_headerItem->height() + m_headerItemShownHeight);
    if (!uFuzzyCompare(to, contentY())) {
        const bool headerShownByItsOwn = contentY() < m_headerItem->y() + m_headerItem->height();
        if (headerShownByItsOwn && m_headerItemShownHeight == 0) {
            // We are not clipping since we are just at the top of the viewport
            // but because of the showHeader animation we will need to, so
            // enable the clipping without logically moving the items
            m_headerItemShownHeight = m_headerItem->y() + m_headerItem->height() - contentY();
            if (!m_visibleItems.isEmpty()) {
                updateClipItem();
                ListItem *firstItem = m_visibleItems.first();
                firstItem->setY(firstItem->y() - m_headerItemShownHeight);
                layout();
            }
            Q_EMIT headerItemShownHeightChanged();
        }
        m_contentYAnimation->setTo(to);
        contentYAnimationType = ContentYAnimationShowHeader;
        m_contentYAnimation->start();
    }
}

int ListViewWithPageHeader::firstCreatedIndex() const
{
    return m_firstVisibleIndex;
}

int ListViewWithPageHeader::createdItemCount() const
{
    return m_visibleItems.count();
}

QQuickItem *ListViewWithPageHeader::item(int modelIndex) const
{
    ListItem *item = itemAtIndex(modelIndex);
    if (item)
        return item->m_item;
    else
        return nullptr;
}

bool ListViewWithPageHeader::maximizeVisibleArea(int modelIndex)
{
    ListItem *listItem = itemAtIndex(modelIndex);
    if (listItem) {
        return maximizeVisibleArea(listItem, listItem->height());
    }

    return false;
}

bool ListViewWithPageHeader::maximizeVisibleArea(int modelIndex, int itemHeight)
{
    if (itemHeight < 0)
        return false;

    ListItem *listItem = itemAtIndex(modelIndex);
    if (listItem) {
        return maximizeVisibleArea(listItem, itemHeight + (listItem->sectionItem() ? listItem->sectionItem()->height() : 0));
    }

    return false;
}

bool ListViewWithPageHeader::maximizeVisibleArea(ListItem *listItem, int listItemHeight)
{
    if (listItem) {
        layout();
        const auto listItemY = m_clipItem->y() + listItem->y();
        if (listItemY > contentY() && listItemY + listItemHeight > contentY() + height()) {
            // we can scroll the list up to show more stuff
            const auto to = qMin(listItemY, listItemY + listItemHeight - height());
            m_contentYAnimation->setTo(to);
            contentYAnimationType = ContentYAnimationMaximizeVisibleArea;
            m_contentYAnimation->start();
        } else if ((listItemY < contentY() && listItemY + listItemHeight < contentY() + height()) ||
                   (m_topSectionItem && !listItem->sectionItem() && listItemY - m_topSectionItem->height() < contentY() && listItemY + listItemHeight < contentY() + height()))
        {
            // we can scroll the list down to show more stuff
            auto realVisibleListItemY = listItemY;
            if (m_topSectionItem) {
                // If we are showing the top section sticky item and this item doesn't have a section
                // item we have to make sure to scroll it a bit more so that it is not underlapping
                // the top section sticky item
                bool topSectionShown = !QQuickItemPrivate::get(m_topSectionItem)->culled;
                if (topSectionShown && !listItem->sectionItem()) {
                    realVisibleListItemY -= m_topSectionItem->height();
                }
            }
            const auto to = qMax(realVisibleListItemY, listItemY + listItemHeight - height());
            m_contentYAnimation->setTo(to);
            contentYAnimationType = ContentYAnimationMaximizeVisibleArea;
            m_contentYAnimation->start();
        }
        return true;
    }
    return false;
}

qreal ListViewWithPageHeader::minYExtent() const
{
//     qDebug() << "ListViewWithPageHeader::minYExtent" << m_minYExtent;
    return m_minYExtent;
}

qreal ListViewWithPageHeader::maxYExtent() const
{
    return height() - contentHeight();
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
    // Check we are not being taken down and don't paint anything
    // TODO Check if we still need this in 5.2
    // For reproduction just inifnite loop testDash or testDashContent
    if (!QQmlEngine::contextForObject(this)->parentContext())
        return;

    QQuickFlickable::viewportMoved(orient);
//     qDebug() << "ListViewWithPageHeader::viewportMoved" << contentY();
    const qreal diff = m_previousContentY - contentY();
    adjustHeader(diff);
    m_previousContentY = contentY();
    layout();
    polish();
}

void ListViewWithPageHeader::adjustHeader(qreal diff)
{
    const bool showHeaderAnimationRunning = m_contentYAnimation->isRunning() && contentYAnimationType == ContentYAnimationShowHeader;
    if (m_headerItem) {
        const auto oldHeaderItemShownHeight = m_headerItemShownHeight;
        if (uFuzzyCompare(contentY(), -m_minYExtent) || contentY() > -m_minYExtent) {
            m_headerItem->setHeight(m_headerItem->implicitHeight());
            // We are going down (but it's not because of the rebound at the end)
            // (but the header was not shown by it's own position)
            // or the header is partially shown and we are not doing a maximizeVisibleArea either
            const bool scrolledUp = m_previousContentY > contentY();
            const bool notRebounding = qRound(contentY() + height()) < qRound(contentHeight());
            const bool notShownByItsOwn = contentY() + diff >= m_headerItem->y() + m_headerItem->height();
            const bool maximizeVisibleAreaRunning = m_contentYAnimation->isRunning() && contentYAnimationType == ContentYAnimationMaximizeVisibleArea;

            if (!scrolledUp && (contentY() == -m_minYExtent || (m_headerItemShownHeight == 0 && m_previousContentY == m_headerItem->y()))) {
                m_headerItemShownHeight = 0;
                m_headerItem->setY(-m_minYExtent);
            } else if ((scrolledUp && notRebounding && notShownByItsOwn && !maximizeVisibleAreaRunning) || (m_headerItemShownHeight > 0) || m_inContentHeightKeepHeaderShown) {
                if (maximizeVisibleAreaRunning && diff > 0) {
                    // If we are maximizing and the header was shown, make sure we hide it
                    m_headerItemShownHeight -= diff;
                } else {
                    m_headerItemShownHeight += diff;
                }
                if (uFuzzyCompare(contentY(), -m_minYExtent)) {
                    m_headerItemShownHeight = 0;
                } else {
                    m_headerItemShownHeight = qBound(static_cast<qreal>(0.), m_headerItemShownHeight, m_headerItem->height());
                }
                if (m_headerItemShownHeight > 0) {
                    if (uFuzzyCompare(m_headerItem->height(), m_headerItemShownHeight)) {
                        m_headerItem->setY(contentY());
                        m_headerItemShownHeight = m_headerItem->height();
                    } else {
                        m_headerItem->setY(contentY() - m_headerItem->height() + m_headerItemShownHeight);
                    }
                } else {
                    m_headerItem->setY(-m_minYExtent);
                }
            }
            Q_EMIT headerItemShownHeightChanged();
        } else {
            // Stick the header item to the top when dragging down
            m_headerItem->setY(contentY());
            m_headerItem->setHeight(m_headerItem->implicitHeight() + (-m_minYExtent - contentY()));
        }
        // We will be changing the clip item, need to accomadate for it
        // otherwise we move the firstItem down/up twice (unless the
        // show header animation is running, where we want to keep the viewport stable)
        if (!showHeaderAnimationRunning) {
            diff += oldHeaderItemShownHeight - m_headerItemShownHeight;
        } else {
            diff = -diff;
        }
    }
    if (!m_visibleItems.isEmpty()) {
        updateClipItem();
        ListItem *firstItem = m_visibleItems.first();
        firstItem->setY(firstItem->y() + diff);
        if (showHeaderAnimationRunning) {
            adjustMinYExtent();
        }
    }
}

void ListViewWithPageHeader::createDelegateModel()
{
    m_delegateModel = new QQmlDelegateModel(qmlContext(this), this);
    connect(m_delegateModel, &QQmlDelegateModel::createdItem, this, &ListViewWithPageHeader::itemCreated);
    if (isComponentComplete())
        m_delegateModel->componentComplete();
    updateWatchedRoles();
}

void ListViewWithPageHeader::refill()
{
    if (m_inLayout) {
        return;
    }
    if (!isComponentComplete()) {
        return;
    }

    const qreal from = contentY();
    const qreal to = from + height();
    const qreal bufferFrom = from - m_cacheBuffer;
    const qreal bufferTo = to + m_cacheBuffer;

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

    ListItem *item;
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

void ListViewWithPageHeader::reallyReleaseItem(ListItem *listItem)
{
    QQuickItem *item = listItem->m_item;
    QQmlDelegateModel::ReleaseFlags flags = m_delegateModel->release(item);
    if (flags & QQmlDelegateModel::Destroyed) {
        item->setParentItem(nullptr);
    }
    if (listItem->sectionItem()) {
        listItem->sectionItem()->deleteLater();
    }
    delete listItem;
}

void ListViewWithPageHeader::releaseItem(ListItem *listItem)
{
    QQuickItemPrivate::get(listItem->m_item)->removeItemChangeListener(this, QQuickItemPrivate::Geometry);
    if (listItem->sectionItem()) {
        QQuickItemPrivate::get(listItem->sectionItem())->removeItemChangeListener(this, QQuickItemPrivate::Geometry);
    }
    m_itemsToRelease << listItem;
}

void ListViewWithPageHeader::updateWatchedRoles()
{
    if (m_delegateModel) {
        QList<QByteArray> roles;
        if (!m_sectionProperty.isEmpty())
            roles << m_sectionProperty.toUtf8();
        m_delegateModel->setWatchedRoles(roles);
    }
}

QQuickItem *ListViewWithPageHeader::getSectionItem(int modelIndex, bool alreadyInserted)
{
    if (!m_sectionDelegate)
        return nullptr;

    const QString section = m_delegateModel->stringValue(modelIndex, m_sectionProperty);

    if (modelIndex > 0) {
        const QString prevSection = m_delegateModel->stringValue(modelIndex - 1, m_sectionProperty);
        if (section == prevSection)
            return nullptr;
    }
    if (modelIndex + 1 < model()->rowCount() && !alreadyInserted) {
        // Already inserted items can't steal next section header
        const QString nextSection = m_delegateModel->stringValue(modelIndex + 1, m_sectionProperty);
        if (section == nextSection) {
            // Steal the section header
            ListItem *nextItem = itemAtIndex(modelIndex); // Not +1 since not yet inserted into m_visibleItems
            if (nextItem) {
                QQuickItem *sectionItem = nextItem->sectionItem();
                nextItem->setSectionItem(nullptr);
                return sectionItem;
            }
        }
    }

    return getSectionItem(section);
}

QQuickItem *ListViewWithPageHeader::getSectionItem(const QString &sectionText, bool watchGeometry)
{
    QQuickItem *sectionItem = nullptr;

    QQmlContext *creationContext = m_sectionDelegate->creationContext();
    QQmlContext *context = new QQmlContext(creationContext ? creationContext : qmlContext(this));
    QObject *nobj = m_sectionDelegate->beginCreate(context);
    if (nobj) {
        QQml_setParent_noEvent(context, nobj);
        sectionItem = qobject_cast<QQuickItem *>(nobj);
        if (!sectionItem) {
            delete nobj;
        } else {
            sectionItem->setProperty("text", sectionText);
            sectionItem->setProperty("delegateIndex", -1);
            sectionItem->setZ(2);
            QQml_setParent_noEvent(sectionItem, m_clipItem);
            sectionItem->setParentItem(m_clipItem);
        }
    } else {
        delete context;
    }
    m_sectionDelegate->completeCreate();

    if (watchGeometry && sectionItem) {
        QQuickItemPrivate::get(sectionItem)->addItemChangeListener(this, QQuickItemPrivate::Geometry);
    }

    return sectionItem;
}

void ListViewWithPageHeader::updateSectionItem(int modelIndex)
{
    ListItem *item = itemAtIndex(modelIndex);
    if (item) {
        const QString sectionText = m_delegateModel->stringValue(modelIndex, m_sectionProperty);

        bool needSectionHeader = true;
        // if it is the same section as the previous item need to drop the section
        if (modelIndex > 0) {
            const QString prevSection = m_delegateModel->stringValue(modelIndex - 1, m_sectionProperty);
            if (sectionText == prevSection) {
                needSectionHeader = false;
            }
        }

        if (needSectionHeader) {
            if (!item->sectionItem()) {
                item->setSectionItem(getSectionItem(sectionText));
            } else {
                item->sectionItem()->setProperty("text", sectionText);
            }
        } else {
            if (item->sectionItem()) {
                item->sectionItem()->deleteLater();
                item->setSectionItem(nullptr);
            }
        }
    }
}

bool ListViewWithPageHeader::removeNonVisibleItems(qreal bufferFrom, qreal bufferTo)
{
//     qDebug() << "ListViewWithPageHeader::removeNonVisibleItems" << bufferFrom << bufferTo;
    // Do not remove items if we are overshooting up or down, since we'll come back
    // to the "stable" position and delete/create items without any reason
    if (contentY() < -m_minYExtent) {
        return false;
    } else if (contentY() + height() > contentHeight()) {
        return false;
    }
    bool changed = false;

    bool foundVisible = false;
    int i = 0;
    int removedItems = 0;
    const auto oldFirstVisibleIndex = m_firstVisibleIndex;
    while (i < m_visibleItems.count()) {
        ListItem *item = m_visibleItems[i];
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
    if (!foundVisible) {
        initializeValuesForEmptyList();
    }
    if (m_firstVisibleIndex != oldFirstVisibleIndex) {
        adjustMinYExtent();
    }

    return changed;
}

ListViewWithPageHeader::ListItem *ListViewWithPageHeader::createItem(int modelIndex, bool asynchronous)
{
//     qDebug() << "CREATE ITEM" << modelIndex;
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
        return 0;
    } else {
//         qDebug() << "ListViewWithPageHeader::createItem::We have the item" << modelIndex << item;
        ListItem *listItem = new ListItem;
        listItem->m_item = item;
        listItem->setSectionItem(getSectionItem(modelIndex, false /*Not yet inserted into m_visibleItems*/));
        QQuickItemPrivate::get(item)->addItemChangeListener(this, QQuickItemPrivate::Geometry);
        ListItem *prevItem = itemAtIndex(modelIndex - 1);
        bool lostItem = false; // Is an item that we requested async but because of model changes
                               // it is no longer attached to any of the existing items (has no prev nor next item)
                               // nor is the first item
        if (prevItem) {
            listItem->setY(prevItem->y() + prevItem->height());
        } else {
            ListItem *currItem = itemAtIndex(modelIndex);
            if (currItem) {
                // There's something already in m_visibleItems at out index, meaning this is an insert, so attach to its top
                listItem->setY(currItem->y() - listItem->height());
            } else {
                ListItem *nextItem = itemAtIndex(modelIndex + 1);
                if (nextItem) {
                    listItem->setY(nextItem->y() - listItem->height());
                } else if (modelIndex == 0) {
                    listItem->setY(-m_clipItem->y() + (m_headerItem ? m_headerItem->height() : 0));
                } else if (!m_visibleItems.isEmpty()) {
                    lostItem = true;
                }
            }
        }
        if (lostItem) {
            listItem->setCulled(true);
            releaseItem(listItem);
            listItem = nullptr;
        } else {
            listItem->setCulled(listItem->y() + listItem->height() + m_clipItem->y() <= contentY() || listItem->y() + m_clipItem->y() >= contentY() + height());
            if (m_visibleItems.isEmpty()) {
                m_visibleItems << listItem;
            } else {
                m_visibleItems.insert(modelIndex - m_firstVisibleIndex, listItem);
            }
            if (m_firstVisibleIndex < 0 || modelIndex < m_firstVisibleIndex) {
                m_firstVisibleIndex = modelIndex;
                polish();
            }
            if (listItem->sectionItem()) {
                listItem->sectionItem()->setProperty("delegateIndex", modelIndex);
            }
            adjustMinYExtent();
            m_contentHeightDirty = true;
        }
        return listItem;
    }
}

void ListViewWithPageHeader::itemCreated(int modelIndex, QObject *object)
{
    QQuickItem *item = qmlobject_cast<QQuickItem*>(object);
    if (!item) {
        qWarning() << "ListViewWithPageHeader::itemCreated got a non item for index" << modelIndex;
        return;
    }
//     qDebug() << "ListViewWithPageHeader::itemCreated" << modelIndex << item;
    // Check we are not being taken down and don't paint anything
    // TODO Check if we still need this in 5.2
    // For reproduction just inifnite loop testDash or testDashContent
    if (!QQmlEngine::contextForObject(this)->parentContext())
        return;

    item->setParentItem(m_clipItem);
    // FIXME Why do we need the refreshExpressions call?
    QQmlContext *context = QQmlEngine::contextForObject(item)->parentContext();
    QQmlContextPrivate::get(context)->data->refreshExpressions();
    item->setProperty("heightToClip", QVariant::fromValue<int>(0));
    if (modelIndex == m_asyncRequestedIndex) {
        createItem(modelIndex, false);
        refill();
    }
}

void ListViewWithPageHeader::updateClipItem()
{
    m_clipItem->setHeight(height() - m_headerItemShownHeight);
    m_clipItem->setY(contentY() + m_headerItemShownHeight);
    m_clipItem->setClip(!m_forceNoClip && m_headerItemShownHeight > 0);
}

void ListViewWithPageHeader::onContentHeightChanged()
{
    updateClipItem();
}

void ListViewWithPageHeader::onContentWidthChanged()
{
    m_clipItem->setWidth(contentItem()->width());
}

void ListViewWithPageHeader::onHeightChanged()
{
    polish();
}


void ListViewWithPageHeader::onModelUpdated(const QQmlChangeSet &changeSet, bool /*reset*/)
{
    // TODO Do something with reset
//     qDebug() << "ListViewWithPageHeader::onModelUpdated" << changeSet << reset;
    const auto oldFirstVisibleIndex = m_firstVisibleIndex;

    Q_FOREACH(const QQmlChangeSet::Change remove, changeSet.removes()) {
//         qDebug() << "ListViewWithPageHeader::onModelUpdated Remove" << remove.index << remove.count;
        if (remove.index + remove.count > m_firstVisibleIndex && remove.index < m_firstVisibleIndex + m_visibleItems.count()) {
            const qreal oldFirstValidIndexPos = m_visibleItems.first()->y();
            // If all the items we are removing are either not created or culled
            // we have to grow down to avoid viewport changing
            bool growDown = true;
            for (int i = 0; growDown && i < remove.count; ++i) {
                const int modelIndex = remove.index + i;
                ListItem *item = itemAtIndex(modelIndex);
                if (item && !item->culled()) {
                    growDown = false;
                }
            }
            for (int i = remove.count - 1; i >= 0; --i) {
                const int visibleIndex = remove.index + i - m_firstVisibleIndex;
                if (visibleIndex >= 0 && visibleIndex < m_visibleItems.count()) {
                    ListItem *item = m_visibleItems[visibleIndex];
                    // Pass the section item down if needed
                    if (item->sectionItem() && visibleIndex + 1 < m_visibleItems.count()) {
                        ListItem *nextItem = m_visibleItems[visibleIndex + 1];
                        if (!nextItem->sectionItem()) {
                            nextItem->setSectionItem(item->sectionItem());
                            item->setSectionItem(nullptr);
                        }
                    }
                    releaseItem(item);
                    m_visibleItems.removeAt(visibleIndex);
                }
            }
            if (growDown) {
                adjustMinYExtent();
            } else if (remove.index <= m_firstVisibleIndex && !m_visibleItems.isEmpty()) {
                m_visibleItems.first()->setY(oldFirstValidIndexPos);
            }
            if (m_visibleItems.isEmpty()) {
                m_firstVisibleIndex = -1;
            } else {
                m_firstVisibleIndex -= qMax(0, m_firstVisibleIndex - remove.index);
            }
        } else if (remove.index + remove.count <= m_firstVisibleIndex) {
            m_firstVisibleIndex -= remove.count;
        }
        for (int i = remove.count - 1; i >= 0; --i) {
            const int modelIndex = remove.index + i;
            if (modelIndex == m_asyncRequestedIndex) {
                m_asyncRequestedIndex = -1;
            } else if (modelIndex < m_asyncRequestedIndex) {
                m_asyncRequestedIndex--;
            }
        }
    }

    Q_FOREACH(const QQmlChangeSet::Change insert, changeSet.inserts()) {
//         qDebug() << "ListViewWithPageHeader::onModelUpdated Insert" << insert.index << insert.count;
        const bool insertingInValidIndexes = insert.index > m_firstVisibleIndex && insert.index < m_firstVisibleIndex + m_visibleItems.count();
        const bool firstItemWithViewOnTop = insert.index == 0 && m_firstVisibleIndex == 0 && m_visibleItems.first()->y() + m_clipItem->y() > contentY();
        if (insertingInValidIndexes || firstItemWithViewOnTop)
        {
            // If the items we are adding won't be really visible
            // we grow up instead of down to not change the viewport
            bool growUp = false;
            if (!firstItemWithViewOnTop) {
                for (int i = 0; i < m_visibleItems.count(); ++i) {
                    if (!m_visibleItems[i]->culled()) {
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
                ListItem *item = createItem(modelIndex, false);
                if (growUp) {
                    ListItem *firstItem = m_visibleItems.first();
                    firstItem->setY(firstItem->y() - item->height());
                }
                // Adding an item may break a "same section" chain, so check
                // if we need adding a new section item
                if (m_sectionDelegate) {
                    ListItem *nextItem = itemAtIndex(modelIndex + 1);
                    if (nextItem && !nextItem->sectionItem()) {
                        nextItem->setSectionItem(getSectionItem(modelIndex + 1, true /* alredy inserted into m_visibleItems*/));
                        if (growUp && nextItem->sectionItem()) {
                            ListItem *firstItem = m_visibleItems.first();
                            firstItem->setY(firstItem->y() - nextItem->sectionItem()->height());
                        }
                    }
                }
            }
            if (firstItemWithViewOnTop) {
                ListItem *firstItem = m_visibleItems.first();
                firstItem->setY(oldFirstValidIndexPos);
            }
            adjustMinYExtent();
        } else if (insert.index <= m_firstVisibleIndex) {
            m_firstVisibleIndex += insert.count;
        }

        for (int i = insert.count - 1; i >= 0; --i) {
            const int modelIndex = insert.index + i;
            if (modelIndex <= m_asyncRequestedIndex) {
                m_asyncRequestedIndex++;
            }
        }
    }

    Q_FOREACH(const QQmlChangeSet::Change change, changeSet.changes()) {
        for (int i = change.start(); i < change.end(); ++i) {
            updateSectionItem(i);
        }
        // Also update the section header for the next item after the change since it may be influenced
        updateSectionItem(change.end());
    }

    if (m_firstVisibleIndex != oldFirstVisibleIndex) {
        if (m_visibleItems.isEmpty()) {
            initializeValuesForEmptyList();
        } else {
            adjustMinYExtent();
        }
    }

    for (int i = 0; i < m_visibleItems.count(); ++i) {
        ListItem *item = m_visibleItems[i];
        if (item->sectionItem()) {
            item->sectionItem()->setProperty("delegateIndex", m_firstVisibleIndex + i);
        }
    }

    layout();
    polish();
    m_contentHeightDirty = true;
}

void ListViewWithPageHeader::contentYAnimationRunningChanged(bool running)
{
    setInteractive(!running);
    if (!running) {
        m_contentHeightDirty = true;
        polish();
    }
}

void ListViewWithPageHeader::itemGeometryChanged(QQuickItem *item, const QRectF &newGeometry, const QRectF &oldGeometry)
{
    const qreal heightDiff = newGeometry.height() - oldGeometry.height();
    if (heightDiff != 0) {
        if (!m_visibleItems.isEmpty()) {
            ListItem *firstItem = m_visibleItems.first();
            const auto prevFirstItemY = firstItem->y();
            if (!m_inContentHeightKeepHeaderShown && oldGeometry.y() + oldGeometry.height() + m_clipItem->y() <= contentY()) {
                firstItem->setY(firstItem->y() - heightDiff);
            } else if (item == firstItem->sectionItem()) {
                firstItem->setY(firstItem->y() + heightDiff);
            }

            if (firstItem->y() != prevFirstItemY) {
                adjustMinYExtent();
                layout();
            }
        }
        refill();
        adjustMinYExtent();
        polish();
        m_contentHeightDirty = true;
    }
}

void ListViewWithPageHeader::itemImplicitHeightChanged(QQuickItem *item)
{
    if (item == m_headerItem) {
        const qreal diff = m_headerItem->implicitHeight() - m_previousHeaderImplicitHeight;
        if (diff != 0) {
            adjustHeader(diff);
            m_previousHeaderImplicitHeight = m_headerItem->implicitHeight();
            layout();
            polish();
            m_contentHeightDirty = true;
        }
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
        Q_EMIT headerItemShownHeightChanged();
    } else {
        if (oldHeaderY + oldHeaderHeight > contentY()) {
            // If the header is shown because its position
            // Change its size
            ListItem *firstItem = m_visibleItems.first();
            firstItem->setY(firstItem->y() + heightDiff);
            layout();
        } else {
            // If the header is not on screen, just change the start of the list
            // so the viewport is not changed
            adjustMinYExtent();
        }
    }
}


void ListViewWithPageHeader::adjustMinYExtent()
{
    if (m_visibleItems.isEmpty() || (contentHeight() + m_minYExtent < height())) {
        m_minYExtent = 0;
    } else {
        qreal nonCreatedHeight = 0;
        if (m_firstVisibleIndex != 0) {
            // Calculate the average height of items to estimate the position of the list start
            const int visibleItems = m_visibleItems.count();
            qreal visibleItemsHeight = 0;
            Q_FOREACH(ListItem *item, m_visibleItems) {
                visibleItemsHeight += item->height();
            }
            nonCreatedHeight = m_firstVisibleIndex * visibleItemsHeight / visibleItems;
//             qDebug() << m_firstVisibleIndex << visibleItemsHeight << visibleItems << nonCreatedHeight;
        }
        const qreal headerHeight = (m_headerItem ? m_headerItem->implicitHeight() : 0);
        m_minYExtent = nonCreatedHeight - m_visibleItems.first()->y() - m_clipItem->y() + headerHeight;
        if (m_minYExtent != 0 && qFuzzyIsNull(m_minYExtent)) {
            m_minYExtent = 0;
            m_visibleItems.first()->setY(nonCreatedHeight - m_clipItem->y() + headerHeight);
        }
    }
}

ListViewWithPageHeader::ListItem *ListViewWithPageHeader::itemAtIndex(int modelIndex) const
{
    const int visibleIndexedModelIndex = modelIndex - m_firstVisibleIndex;
    if (visibleIndexedModelIndex >= 0 && visibleIndexedModelIndex < m_visibleItems.count())
        return m_visibleItems[visibleIndexedModelIndex];

    return nullptr;
}

void ListViewWithPageHeader::layout()
{
    if (m_inLayout)
        return;

    m_inLayout = true;
    if (!m_visibleItems.isEmpty()) {
        const qreal visibleFrom = contentY() - m_clipItem->y() + m_headerItemShownHeight;
        const qreal visibleTo = contentY() + height() - m_clipItem->y();

        qreal pos = m_visibleItems.first()->y();

//         qDebug() << "ListViewWithPageHeader::layout Updating positions and heights. contentY" << contentY() << "minYExtent" << minYExtent();
        int firstReallyVisibleItem = -1;
        int modelIndex = m_firstVisibleIndex;
        Q_FOREACH(ListItem *item, m_visibleItems) {
            const bool cull = pos + item->height() <= visibleFrom || pos >= visibleTo;
            item->setCulled(cull);
            item->setY(pos);
            if (!cull && firstReallyVisibleItem == -1) {
                firstReallyVisibleItem = modelIndex;
                if (m_topSectionItem) {
                    // Positing the top section sticky item is a two step process
                    // First we set it either we cull it (because it doesn't need to be sticked to the top)
                    // or stick it to the top
                    // Then after the loop we'll make sure that if there's another section just below it
                    // pushed the sticky section up to make it disappear
                    const qreal topSectionStickPos = m_headerItemShownHeight + contentY() - m_clipItem->y();
                    bool showStickySectionItem;
                    // We need to show the "top section sticky item" when the position at the "top" of the
                    // viewport is bigger than the start of the position of the first visible item
                    // i.e. the first visible item starts before the viewport, or when the first
                    // visible item starts just at the viewport start and it does not have its own section item
                    if (topSectionStickPos > pos) {
                        showStickySectionItem = true;
                    } else if (topSectionStickPos == pos) {
                        showStickySectionItem = !item->sectionItem();
                    } else {
                        showStickySectionItem = false;
                    }
                    if (!showStickySectionItem) {
                        QQuickItemPrivate::get(m_topSectionItem)->setCulled(true);
                        if (item->sectionItem()) {
                            // This seems it should happen since why would we cull the top section
                            // if the first visible item has no section header? This only happens briefly
                            // when increasing the height of a list that is at the bottom, the m_topSectionItem
                            // gets shown shortly in the next polish call
                            QQuickItemPrivate::get(item->sectionItem())->setCulled(false);
                        }
                    } else {
                        // Update the top sticky section header
                        const QString section = m_delegateModel->stringValue(modelIndex, m_sectionProperty);
                        m_topSectionItem->setProperty("text", section);

                        QQuickItemPrivate::get(m_topSectionItem)->setCulled(false);
                        m_topSectionItem->setY(topSectionStickPos);
                        int delegateIndex = modelIndex;
                        // Look for the first index with this section text
                        while (delegateIndex > 0) {
                            const QString prevSection = m_delegateModel->stringValue(delegateIndex - 1, m_sectionProperty);
                            if (prevSection != section)
                                break;
                            delegateIndex--;
                        }
                        m_topSectionItem->setProperty("delegateIndex", delegateIndex);
                        if (item->sectionItem()) {
                            QQuickItemPrivate::get(item->sectionItem())->setCulled(true);
                        }
                    }
                }
            }
            const qreal clipFrom = visibleFrom + (!item->sectionItem() && m_topSectionItem && !QQuickItemPrivate::get(m_topSectionItem)->culled ? m_topSectionItem->height() : 0);
            if (!cull && pos < clipFrom) {
                item->m_item->setProperty("heightToClip", clipFrom - pos);
            } else {
                item->m_item->setProperty("heightToClip", QVariant::fromValue<int>(0));
            }
//             qDebug() << "ListViewWithPageHeader::layout" << item->m_item;
            pos += item->height();
            ++modelIndex;
        }

        // Second step of section sticky item positioning
        // Look at the next section header, check if it's pushing up the sticky one
        if (m_topSectionItem) {
            if (firstReallyVisibleItem >= 0) {
                for (int i = firstReallyVisibleItem - m_firstVisibleIndex + 1; i < m_visibleItems.count(); ++i) {
                    ListItem *item = m_visibleItems[i];
                    if (item->sectionItem()) {
                        if (m_topSectionItem->y() + m_topSectionItem->height() > item->y()) {
                            m_topSectionItem->setY(item->y() - m_topSectionItem->height());
                        }
                        break;
                    }
                }
            }
        }
    }
    if (m_headerItem) {
        const bool cullHeader = m_headerItem->y() + m_headerItem->height() < contentY();
        QQuickItemPrivate::get(m_headerItem)->setCulled(cullHeader);
    }
    m_inLayout = false;
}

void ListViewWithPageHeader::updatePolish()
{
    // Check we are not being taken down and don't paint anything
    // TODO Check if we still need this in 5.2
    // For reproduction just inifnite loop testDash or testDashContent
    if (!QQmlEngine::contextForObject(this)->parentContext())
        return;

    Q_FOREACH(ListItem *item, m_itemsToRelease)
        reallyReleaseItem(item);
    m_itemsToRelease.clear();

    if (!model())
        return;

    layout();

    refill();

    if (m_contentHeightDirty) {
        qreal contentHeight;
        if (m_visibleItems.isEmpty()) {
            contentHeight = m_headerItem ? m_headerItem->height() : 0;
        } else {
            const int modelCount = model()->rowCount();
            const int visibleItems = m_visibleItems.count();
            const int lastValidIndex = m_firstVisibleIndex + visibleItems - 1;
            qreal nonCreatedHeight = 0;
            if (lastValidIndex != modelCount - 1) {
                const int visibleItems = m_visibleItems.count();
                qreal visibleItemsHeight = 0;
                Q_FOREACH(ListItem *item, m_visibleItems) {
                    visibleItemsHeight += item->height();
                }
                const int unknownSizes = modelCount - (m_firstVisibleIndex + visibleItems);
                nonCreatedHeight = unknownSizes * visibleItemsHeight / visibleItems;
            }
            ListItem *item = m_visibleItems.last();
            contentHeight = nonCreatedHeight + item->y() + item->height() + m_clipItem->y();
            if (m_firstVisibleIndex != 0) {
                // Make sure that if we are shrinking we tell the view we still fit
                m_minYExtent = qMax(m_minYExtent, -(contentHeight - height()));
            }
        }

        m_contentHeightDirty = false;
        adjustMinYExtent();
        if (contentHeight + m_minYExtent < height()) {
            // need this since in the previous call to adjustMinYExtent contentHeight is not set yet
            m_minYExtent = 0;
        }
        m_inContentHeightKeepHeaderShown = m_headerItem && m_headerItem->y() == contentY();
        setContentHeight(contentHeight);
        m_inContentHeightKeepHeaderShown = false;
    }
}

#include "moc_listviewwithpageheader.cpp"
