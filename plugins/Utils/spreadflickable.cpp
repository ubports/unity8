#include "spreadflickable.h"

SpreadFlickable::SpreadFlickable(QQuickItem *parent):
    QQuickItem(parent),
    m_mousePressed(false),
    m_touchPressed(false)
{
    m_flickable = new QQuickFlickable(this);
    m_flickable->installEventFilter(this);
    connect(m_flickable, &QQuickFlickable::contentWidthChanged, this, &SpreadFlickable::contentWidthChanged);
    connect(m_flickable, &QQuickFlickable::contentXChanged, this, &SpreadFlickable::contentXChanged);

    connect(this, &QQuickItem::heightChanged, this, &SpreadFlickable::slotHeightChanged);
    connect(this, &QQuickItem::widthChanged, this, &SpreadFlickable::slotWidthChanged);
}

qreal SpreadFlickable::contentWidth() const
{
    return m_flickable->contentWidth();
}

void SpreadFlickable::setContentWidth(qreal contentWidth)
{
    m_flickable->setContentWidth(contentWidth);
}

qreal SpreadFlickable::contentX() const
{
    return m_flickable->contentX();
}

void SpreadFlickable::setContentX(qreal contentX)
{
    m_flickable->setContentX(contentX);
}

void SpreadFlickable::slotHeightChanged()
{
    m_flickable->setHeight(height());
}

void SpreadFlickable::slotWidthChanged()
{
    m_flickable->setWidth(width());
}

bool SpreadFlickable::eventFilter(QObject* /*watched*/, QEvent *event)
{
    //m_flickable->eventFilter(watched, event);
    switch (event->type()) {
    case QEvent::TouchBegin:
        break;
    case QEvent::TouchEnd:
        break;
    case QEvent::MouseButtonPress:
        break;
    case QEvent::MouseButtonRelease:
        break;
    default:
        // Not interested
        break;
    }

    // We never filter them out. We are just watching.
    return false;
}
