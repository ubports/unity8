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
class QQuickNumberAnimation;
class QQmlChangeSet;
class QQmlDelegateModel;


/**
    Note for users of this class

    ListViewWithPageHeader already loads delegates async when appropiate so if
    your delegate uses a Loader you should not enable the asynchronous feature since
    that will need to introduce sizing problems

    With the double async it may happen what while we are scrolling down
    we reach to a point where given the size of the just created delegate with loader not yet loaded (which will be very close to 0)
    we are already "at the end" of the list, but then a few milliseconds later the loader finishes loading and we could
    have kept scrolling. This is specially visible at the end of the list where you realize
    that scrolling ended a bit before the end of the list but the speed of the flicking was good
    to reach the end

    By not having the second async we get a better sizing when the delegate is created and things work better
*/

class ListViewWithPageHeader : public QQuickFlickable, public QQuickItemChangeListener
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel *model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(QQmlComponent *delegate READ delegate WRITE setDelegate NOTIFY delegateChanged)
    Q_PROPERTY(QQuickItem *pageHeader READ header WRITE setHeader NOTIFY headerChanged)
    Q_PROPERTY(QQmlComponent *sectionDelegate READ sectionDelegate WRITE setSectionDelegate NOTIFY sectionDelegateChanged)
    Q_PROPERTY(QString sectionProperty READ sectionProperty WRITE setSectionProperty NOTIFY sectionPropertyChanged)
    Q_PROPERTY(bool forceNoClip READ forceNoClip WRITE setForceNoClip NOTIFY forceNoClipChanged)
    Q_PROPERTY(int stickyHeaderHeight READ stickyHeaderHeight NOTIFY stickyHeaderHeightChanged)
    Q_PROPERTY(qreal headerItemShownHeight READ headerItemShownHeight NOTIFY headerItemShownHeightChanged)
    Q_PROPERTY(int cacheBuffer READ cacheBuffer WRITE setCacheBuffer NOTIFY cacheBufferChanged)

    friend class ListViewWithPageHeaderTest;
    friend class ListViewWithPageHeaderTestSection;
    friend class ListViewWithPageHeaderTestExternalModel;

public:
    ListViewWithPageHeader();
    ~ListViewWithPageHeader();

    QAbstractItemModel *model() const;
    void setModel(QAbstractItemModel *model);

    QQmlComponent *delegate() const;
    void setDelegate(QQmlComponent *delegate);

    QQuickItem *header() const;
    void setHeader(QQuickItem *header);

    QQmlComponent *sectionDelegate() const;
    void setSectionDelegate(QQmlComponent *delegate);

    QString sectionProperty() const;
    void setSectionProperty(const QString &property);

    bool forceNoClip() const;
    void setForceNoClip(bool noClip);

    int stickyHeaderHeight() const;
    qreal headerItemShownHeight() const;

    int cacheBuffer() const;
    void setCacheBuffer(int cacheBuffer);

    Q_INVOKABLE void positionAtBeginning();
    Q_INVOKABLE void showHeader();
    Q_INVOKABLE int firstCreatedIndex() const;
    Q_INVOKABLE int createdItemCount() const;
    Q_INVOKABLE QQuickItem *item(int modelIndex) const;

    // The index has to be created for this to try to do something
    // Created items are those visible and the precached ones
    // Returns if the item existed or not
    Q_INVOKABLE bool maximizeVisibleArea(int modelIndex);
    Q_INVOKABLE bool maximizeVisibleArea(int modelIndex, int itemHeight);

Q_SIGNALS:
    void modelChanged();
    void delegateChanged();
    void headerChanged();
    void sectionDelegateChanged();
    void sectionPropertyChanged();
    void forceNoClipChanged();
    void stickyHeaderHeightChanged();
    void headerItemShownHeightChanged();
    void cacheBufferChanged();

protected:
    void componentComplete() override;
    void viewportMoved(Qt::Orientations orient) override;
    qreal minYExtent() const override;
    qreal maxYExtent() const override;
    void itemGeometryChanged(QQuickItem *item, const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemImplicitHeightChanged(QQuickItem *item) override;
    void updatePolish() override;

private Q_SLOTS:
    void itemCreated(int modelIndex, QObject *object);
    void onContentHeightChanged();
    void onContentWidthChanged();
    void onHeightChanged();
    void onModelUpdated(const QQmlChangeSet &changeSet, bool reset);
    void contentYAnimationRunningChanged(bool running);

private:
    class ListItem
    {
        public:
            qreal height() const;

            qreal y() const;
            void setY(qreal newY);

            bool culled() const;
            void setCulled(bool culled);

            QQuickItem *sectionItem() const { return m_sectionItem; }
            void setSectionItem(QQuickItem *sectionItem);

            QQuickItem *m_item;
        private:
            QQuickItem *m_sectionItem;
    };

    bool maximizeVisibleArea(ListItem *listItem, int listItemHeight);

    void createDelegateModel();

    void layout();
    void refill();
    bool addVisibleItems(qreal fillFrom, qreal fillTo, bool asynchronous);
    bool removeNonVisibleItems(qreal bufferFrom, qreal bufferTo);
    ListItem *createItem(int modelIndex, bool asynchronous);

    void adjustHeader(qreal diff);
    void adjustMinYExtent();
    void updateClipItem();
    void headerHeightChanged(qreal newHeaderHeight, qreal oldHeaderHeight, qreal oldHeaderY);
    ListItem *itemAtIndex(int modelIndex) const; // Returns the item at modelIndex if has been created
    void releaseItem(ListItem *item);
    void reallyReleaseItem(ListItem *item);
    void updateWatchedRoles();
    QQuickItem *getSectionItem(int modelIndex, bool alreadyInserted);
    QQuickItem *getSectionItem(const QString &sectionText, bool watchGeometry = true);
    void updateSectionItem(int modelIndex);
    void initializeValuesForEmptyList();

    QQmlDelegateModel *m_delegateModel;

    // Index we are waiting because we requested it asynchronously
    int m_asyncRequestedIndex;

    // Used to only give a warning once if the delegate does not return objects
    bool m_delegateValidated;

    // Visible indexes, [0] is m_firstValidIndex, [0+1] is m_firstValidIndex +1, ...
    QList<ListItem *> m_visibleItems;
    int m_firstVisibleIndex;

    qreal m_minYExtent;

    QQuickItem *m_clipItem;

    // If any of the heights has changed
    // or new items have been added/removed
    bool m_contentHeightDirty;

    QQuickItem *m_headerItem;
    qreal m_previousContentY;
    qreal m_previousHeaderImplicitHeight;
    qreal m_headerItemShownHeight; // The height of header shown when the header is shown outside its topmost position
                                   // i.e. it's being shown after dragging down in the middle of the list
    enum ContentYAnimationType { ContentYAnimationShowHeader, ContentYAnimationMaximizeVisibleArea };
    ContentYAnimationType contentYAnimationType;
    QQuickNumberAnimation *m_contentYAnimation;

    QQmlComponent *m_sectionDelegate;
    QString m_sectionProperty;
    QQuickItem *m_topSectionItem;

    bool m_forceNoClip;
    bool m_inLayout;
    bool m_inContentHeightKeepHeaderShown;
    int m_cacheBuffer;

    // Qt 5.0 doesn't like releasing the items just after itemCreated
    // so we delay the releasing until the next updatePolish
    QList<ListItem *> m_itemsToRelease;
};


#endif
