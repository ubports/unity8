/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
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

#include "MirSurfaceItem.h"

#include <paths.h>

#include <QGuiApplication>
#include <QQuickView>
#include <QQmlProperty>
#include <QQmlEngine>
#include <QString>

#include <QDebug>

using namespace unity::shell::application;

MirSurfaceItem::MirSurfaceItem(QQuickItem *parent)
    : MirSurfaceItemInterface(parent)
    , m_qmlSurface(nullptr)
    , m_qmlItem(nullptr)
    , m_consumesInput(false)
    , m_surfaceWidth(0)
    , m_surfaceHeight(0)
    , m_touchPressCount(0)
    , m_touchReleaseCount(0)
    , m_mousePressCount(0)
    , m_mouseReleaseCount(0)
{
//    qDebug() << "MirSurfaceItem::MirSurfaceItem() " << (void*)(this) << name();
    setAcceptedMouseButtons(Qt::LeftButton | Qt::MiddleButton | Qt::RightButton |
        Qt::ExtraButton1 | Qt::ExtraButton2 | Qt::ExtraButton3 | Qt::ExtraButton4 |
        Qt::ExtraButton5 | Qt::ExtraButton6 | Qt::ExtraButton7 | Qt::ExtraButton8 |
        Qt::ExtraButton9 | Qt::ExtraButton10 | Qt::ExtraButton11 |
        Qt::ExtraButton12 | Qt::ExtraButton13);

    connect(this, &QQuickItem::visibleChanged, this, &MirSurfaceItem::updateMirSurfaceVisibility);
}

MirSurfaceItem::~MirSurfaceItem()
{
//    qDebug() << "MirSurfaceItem::~MirSurfaceItem() " << (void*)(this) << name();
    setSurface(nullptr);
}

void MirSurfaceItem::printComponentErrors()
{
    QList<QQmlError> errors = m_qmlContentComponent->errors();
    for (int i = 0; i < errors.count(); ++i) {
        qDebug() << errors[i];
    }
}

Mir::Type MirSurfaceItem::type() const
{
    if (m_qmlSurface) {
        return m_qmlSurface->type();
    } else {
        return Mir::UnknownType;
    }
}

Mir::State MirSurfaceItem::surfaceState() const
{
    if (m_qmlSurface) {
        return m_qmlSurface->state();
    } else {
        return Mir::UnknownState;
    }
}

QString MirSurfaceItem::name() const
{
    if (m_qmlSurface) {
        return m_qmlSurface->name();
    } else {
        return QString();
    }
}

bool MirSurfaceItem::live() const
{
    if (m_qmlSurface) {
        return m_qmlSurface->live();
    } else {
        return false;
    }
}

Mir::ShellChrome MirSurfaceItem::shellChrome() const
{
    if (m_qmlSurface) {
        return m_qmlSurface->shellChrome();
    } else {
        return Mir::NormalChrome;
    }
}

Mir::OrientationAngle MirSurfaceItem::orientationAngle() const
{
    if (m_qmlSurface) {
        return m_qmlSurface->orientationAngle();
    } else {
        return Mir::Angle0;
    }
}

void MirSurfaceItem::setOrientationAngle(Mir::OrientationAngle angle)
{
    if (!m_qmlSurface)
        return;

    if (m_qmlSurface->orientationAngle() == angle)
        return;

    m_qmlSurface->setOrientationAngle(angle);

    QQmlProperty orientationProp(m_qmlItem, "orientationAngle");
    orientationProp.write(QVariant::fromValue(m_qmlSurface->orientationAngle()));
}

void MirSurfaceItem::updateScreenshot(QUrl screenshotUrl)
{
    if (m_qmlItem) {
        QQmlProperty screenshotSource(m_qmlItem, "screenshotSource");
        screenshotSource.write(QVariant::fromValue(screenshotUrl));
    }
}

void MirSurfaceItem::onComponentStatusChanged(QQmlComponent::Status status)
{
    if (status == QQmlComponent::Ready) {
        createQmlContentItem();
    }
}

void MirSurfaceItem::createQmlContentItem()
{
//    qDebug() << "MirSurfaceItem::createQmlContentItem()";

    m_qmlItem = qobject_cast<QQuickItem*>(m_qmlContentComponent->create());
    m_qmlItem->setParentItem(this);

    setImplicitWidth(m_qmlItem->implicitWidth());
    setImplicitHeight(m_qmlItem->implicitHeight());

    {
        QQmlProperty screenshotSource(m_qmlItem, "screenshotSource");
        screenshotSource.write(QVariant::fromValue(m_qmlSurface->screenshotUrl()));
    }
}

void MirSurfaceItem::touchEvent(QTouchEvent * event)
{
    if (event->type() == QEvent::TouchBegin) {
        m_touchTrail.clear();
    }

    if (event->touchPointStates() & Qt::TouchPointPressed) {
        ++m_touchPressCount;
        Q_EMIT touchPressCountChanged(m_touchPressCount);
    } else if (event->touchPointStates() & Qt::TouchPointReleased) {
        ++m_touchReleaseCount;
        Q_EMIT touchReleaseCountChanged(m_touchReleaseCount);
    }

    Q_FOREACH(QTouchEvent::TouchPoint touchPoint, event->touchPoints()) {
        QString id(touchPoint.id());
        QVariantList list =  m_touchTrail[id].toList();
        list.append(QVariant::fromValue(touchPoint.pos()));
        if (list.count() > 100) list.pop_front();
        m_touchTrail[id] = list;
    }

    if (m_qmlItem) {
        QQmlProperty touchTrail(m_qmlItem, "touchTrail");
        touchTrail.write(m_touchTrail);
    }
}

void MirSurfaceItem::mousePressEvent(QMouseEvent * event)
{
    m_mousePressCount++;
    Q_EMIT mousePressCountChanged(m_mousePressCount);
    event->accept();
}

void MirSurfaceItem::mouseMoveEvent(QMouseEvent * event)
{
    event->accept();
}

void MirSurfaceItem::mouseReleaseEvent(QMouseEvent * event)
{
    m_mouseReleaseCount++;
    Q_EMIT mouseReleaseCountChanged(m_mouseReleaseCount);
    event->accept();
}

void MirSurfaceItem::setSurface(MirSurfaceInterface* surface)
{
//    qDebug().nospace() << "MirSurfaceItem::setSurface() this=" << (void*)(this)
//                                                   << " name=" << name()
//                                                   << " surface=" << surface;

    if (m_qmlSurface == surface) {
        return;
    }

    if (m_qmlSurface) {
        delete m_qmlItem;
        m_qmlItem = nullptr;

        delete m_qmlContentComponent;
        m_qmlContentComponent = nullptr;

        disconnect(m_qmlSurface, nullptr, this, nullptr);
        m_qmlSurface->unregisterView((qintptr)this);
    }

    m_qmlSurface = static_cast<MirSurface*>(surface);

    if (m_qmlSurface) {
        m_qmlSurface->registerView((qintptr)this);

        m_qmlSurface->setActiveFocus(hasActiveFocus());

        updateSurfaceSize();
        updateMirSurfaceVisibility();

        connect(m_qmlSurface, &MirSurface::orientationAngleChanged, this, &MirSurfaceItem::orientationAngleChanged);
        connect(m_qmlSurface, &MirSurface::screenshotUrlChanged, this, &MirSurfaceItem::updateScreenshot);
        connect(m_qmlSurface, &MirSurface::liveChanged, this, &MirSurfaceItem::liveChanged);
        connect(m_qmlSurface, &MirSurface::stateChanged, this, &MirSurfaceItem::surfaceStateChanged);

        // The assumptions I make here really should hold.
        QQuickView *quickView =
            qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

        QUrl qmlComponentFilePath;
        if (!m_qmlSurface->qmlFilePath().isEmpty()) {
            qmlComponentFilePath = m_qmlSurface->qmlFilePath();
        } else {
            qmlComponentFilePath = QUrl("qrc:///Unity/Application/MirSurfaceItem.qml");
        }

        m_qmlContentComponent = new QQmlComponent(quickView->engine(), qmlComponentFilePath);

        switch (m_qmlContentComponent->status()) {
            case QQmlComponent::Ready:
                createQmlContentItem();
                break;
            case QQmlComponent::Loading:
                connect(m_qmlContentComponent, &QQmlComponent::statusChanged,
                        this, &MirSurfaceItem::onComponentStatusChanged);
                break;
            case QQmlComponent::Error:
                printComponentErrors();
                qFatal("MirSurfaceItem: failed to create content component.");
                break;
            default:
                qFatal("MirSurfaceItem: Unhandled component status");
        }
    }

    Q_EMIT surfaceChanged(m_qmlSurface);
}

void MirSurfaceItem::itemChange(ItemChange change, const ItemChangeData & value)
{
    if (change == QQuickItem::ItemActiveFocusHasChanged) {
        if (m_qmlSurface) {
            m_qmlSurface->setActiveFocus(value.boolValue);
        }
    }
}

void MirSurfaceItem::updateMirSurfaceVisibility()
{
    if (!m_qmlSurface) return;

    m_qmlSurface->setViewVisibility((qintptr)this, isVisible());
}

void MirSurfaceItem::setConsumesInput(bool value)
{
    if (m_consumesInput != value) {
        m_consumesInput = value;
        Q_EMIT consumesInputChanged(value);
    }
}

int MirSurfaceItem::surfaceWidth() const
{
    return m_surfaceWidth;
}

void MirSurfaceItem::setSurfaceWidth(int value)
{
    if (value != -1 && m_surfaceWidth != value) {
        m_surfaceWidth = value;
        Q_EMIT surfaceWidthChanged(m_surfaceWidth);
        updateSurfaceSize();
    }
}

int MirSurfaceItem::surfaceHeight() const
{
    return m_surfaceHeight;
}

void MirSurfaceItem::setSurfaceHeight(int value)
{
    if (value != -1 && m_surfaceHeight != value) {
        m_surfaceHeight = value;
        Q_EMIT surfaceHeightChanged(m_surfaceHeight);
        updateSurfaceSize();
    }
}

void MirSurfaceItem::updateSurfaceSize()
{
    if (m_qmlSurface && m_surfaceWidth > 0 && m_surfaceHeight > 0) {
        m_qmlSurface->resize(m_surfaceWidth, m_surfaceHeight);
    }
}

void MirSurfaceItem::setFillMode(FillMode value)
{
    if (value != m_fillMode) {
        m_fillMode = value;
        Q_EMIT fillModeChanged(m_fillMode);
    }
}
