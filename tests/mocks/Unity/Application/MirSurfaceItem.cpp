/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
#include <QQmlContext>
#include <QQmlProperty>
#include <QQmlEngine>
#include <QString>

#include <QDebug>

using namespace unity::shell::application;

#define MIRSURFACEITEM_DEBUG 0

#if MIRSURFACEITEM_DEBUG
#define DEBUG_MSG(params) qDebug().nospace() << "MirSurfaceItem::" << __func__  << " " << params
#else
#define DEBUG_MSG(params) ((void)0)
#endif

MirSurfaceItem::MirSurfaceItem(QQuickItem *parent)
    : MirSurfaceItemInterface(parent)
    , m_qmlSurface(nullptr)
    , m_qmlContentComponent(nullptr)
    , m_qmlItem(nullptr)
    , m_consumesInput(false)
    , m_orientationAngle(nullptr)
    , m_surfaceWidth(0)
    , m_surfaceHeight(0)
    , m_touchPressCount(0)
    , m_touchReleaseCount(0)
    , m_mousePressCount(0)
    , m_mouseReleaseCount(0)
{
    DEBUG_MSG((void*)(this) << name());
    setAcceptedMouseButtons(Qt::LeftButton | Qt::MiddleButton | Qt::RightButton |
        Qt::ExtraButton1 | Qt::ExtraButton2 | Qt::ExtraButton3 | Qt::ExtraButton4 |
        Qt::ExtraButton5 | Qt::ExtraButton6 | Qt::ExtraButton7 | Qt::ExtraButton8 |
        Qt::ExtraButton9 | Qt::ExtraButton10 | Qt::ExtraButton11 |
        Qt::ExtraButton12 | Qt::ExtraButton13);

    connect(this, &QQuickItem::activeFocusChanged, this, &MirSurfaceItem::updateMirSurfaceActiveFocus);
    connect(this, &QQuickItem::visibleChanged, this, &MirSurfaceItem::updateMirSurfaceExposure);

    connect(this, &MirSurfaceItem::consumesInputChanged, this, [this]() {
        updateMirSurfaceActiveFocus(hasActiveFocus());
    });

    // We're just clipping contents in the mock. The real QtMir would copy only relevant buffer instead
    setClip(true);
}

MirSurfaceItem::~MirSurfaceItem()
{
    DEBUG_MSG((void*)(this) << name());
    setSurface(nullptr);
    delete m_orientationAngle;
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
    if (m_orientationAngle) {
        Q_ASSERT(!m_qmlSurface);
        return *m_orientationAngle;
    } else if (m_qmlSurface) {
        return m_qmlSurface->orientationAngle();
    } else {
        return Mir::Angle0;
    }
}

void MirSurfaceItem::setOrientationAngle(Mir::OrientationAngle angle)
{
    DEBUG_MSG(angle);

    if (m_qmlSurface) {
        Q_ASSERT(!m_orientationAngle);
        m_qmlSurface->setOrientationAngle(angle);
    } else if (!m_orientationAngle) {
        m_orientationAngle = new Mir::OrientationAngle;
        *m_orientationAngle = angle;
        Q_EMIT orientationAngleChanged(angle);
    } else if (*m_orientationAngle != angle) {
        *m_orientationAngle = angle;
        Q_EMIT orientationAngleChanged(angle);
    }

    if (m_qmlItem) {
        QQmlProperty orientationProp(m_qmlItem, "orientationAngle");
        if (orientationProp.isValid()) {
            orientationProp.write(QVariant::fromValue(orientationAngle()));
        }
    }
}

void MirSurfaceItem::updateScreenshot(QUrl screenshotUrl)
{
    if (m_qmlItem) {
        QQmlProperty screenshotSource(m_qmlItem, "screenshotSource");
        if (screenshotSource.isValid()) {
            screenshotSource.write(QVariant::fromValue(screenshotUrl));
        }
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
    DEBUG_MSG("");

    m_qmlItem = qobject_cast<QQuickItem*>(m_qmlContentComponent->create());
    m_qmlItem->setParentItem(this);

    if (m_fillMode == FillMode::Stretch && width() != 0 && height() != 0) {
        m_qmlItem->setSize(QSize(this->width(), this->height()));
    } else {
        m_qmlItem->setSize(m_qmlSurface->size());
    }
    setImplicitWidth(m_qmlItem->width());
    setImplicitHeight(m_qmlItem->height());

    {
        QQmlProperty screenshotSource(m_qmlItem, "screenshotSource");
        if (screenshotSource.isValid()) {
            screenshotSource.write(QVariant::fromValue(m_qmlSurface->screenshotUrl()));
        }
    }

    {
        QQmlProperty orientationProp(m_qmlItem, "orientationAngle");
        if (orientationProp.isValid()) {
            orientationProp.write(QVariant::fromValue(orientationAngle()));
        }
    }

    {
        QQmlProperty surfaceProperty(m_qmlItem, "surface");
        if (surfaceProperty.isValid()) {
            surfaceProperty.write(QVariant::fromValue(m_qmlSurface));
        }
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

    Q_FOREACH(const QTouchEvent::TouchPoint &touchPoint, event->touchPoints()) {
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
    DEBUG_MSG("this=" << (void*)(this) << " name=" << name() << " surface=" << surface);

    if (m_qmlSurface == surface) {
        return;
    }

    if (m_qmlSurface) {
        delete m_qmlItem;
        m_qmlItem = nullptr;

        delete m_qmlContentComponent;
        m_qmlContentComponent = nullptr;

        if (hasActiveFocus() && m_consumesInput && m_qmlSurface->live()) {
            m_qmlSurface->setActiveFocus(false);
        }

        disconnect(m_qmlSurface, nullptr, this, nullptr);
        m_qmlSurface->unregisterView((qintptr)this);
    }

    m_qmlSurface = static_cast<MirSurface*>(surface);

    if (m_qmlSurface) {
        m_qmlSurface->registerView((qintptr)this);

        updateSurfaceSize();
        updateMirSurfaceExposure();

        if (m_orientationAngle) {
            m_qmlSurface->setOrientationAngle(*m_orientationAngle);
            connect(m_qmlSurface, &MirSurfaceInterface::orientationAngleChanged, this, &MirSurfaceItem::orientationAngleChanged);
            delete m_orientationAngle;
            m_orientationAngle = nullptr;
        } else {
            connect(m_qmlSurface, &MirSurfaceInterface::orientationAngleChanged, this, &MirSurfaceItem::orientationAngleChanged);
            Q_EMIT orientationAngleChanged(m_qmlSurface->orientationAngle());
        }

        connect(m_qmlSurface, &MirSurface::screenshotUrlChanged, this, &MirSurfaceItem::updateScreenshot);
        connect(m_qmlSurface, &MirSurface::liveChanged, this, [this] (bool live) {
            if (!live) {
                setSurface(nullptr);
            }
            Q_EMIT liveChanged(live);
        });
        connect(m_qmlSurface, &MirSurface::stateChanged, this, &MirSurfaceItem::surfaceStateChanged);
        connect(m_qmlSurface, &MirSurface::sizeChanged, this, [this] () {
            setImplicitSize(m_qmlSurface->width(), m_qmlSurface->height());
            if (m_fillMode == FillMode::Stretch) {
                m_qmlItem->setSize(QSize(this->width(), this->height()));
            } else {
                m_qmlItem->setSize(m_qmlSurface->size());
            }
        });
        m_surfaceWidth = surface->size().width();
        m_surfaceHeight = surface->size().height();

        QUrl qmlComponentFilePath;
        if (!m_qmlSurface->qmlFilePath().isEmpty()) {
            qmlComponentFilePath = m_qmlSurface->qmlFilePath();
        } else {
            qmlComponentFilePath = QUrl("qrc:///Unity/Application/MirSurfaceItem.qml");
        }

        m_qmlContentComponent = new QQmlComponent(QQmlEngine::contextForObject(parent())->engine(), qmlComponentFilePath);

        switch (m_qmlContentComponent->status()) {
            case QQmlComponent::Ready:
                createQmlContentItem();
                qDebug() << "content created" << m_surfaceWidth << implicitWidth() << width();
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

        if (m_consumesInput) {
            m_qmlSurface->setActiveFocus(hasActiveFocus());
        }
    }

    Q_EMIT surfaceChanged(m_qmlSurface);
}


void MirSurfaceItem::updateMirSurfaceActiveFocus(bool focused)
{
    if (m_qmlSurface && m_consumesInput && m_qmlSurface->live()) {
        m_qmlSurface->setActiveFocus(focused);
    }
}

void MirSurfaceItem::updateMirSurfaceExposure()
{
    if (!m_qmlSurface) return;

    m_qmlSurface->setViewExposure((qintptr)this, isVisible());
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
//    qDebug() << "setSurfaceWidth called" << value;
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
        if (m_qmlItem) {
            if (m_fillMode == FillMode::Stretch) {
                m_qmlItem->setWidth(width());
                m_qmlItem->setHeight(height());
            } else {
                m_qmlItem->setWidth(m_surfaceWidth);
                m_qmlItem->setHeight(m_surfaceHeight);
            }
        }
        qDebug() << this << "setting implicitsize" << m_surfaceWidth << m_surfaceHeight;
        setImplicitSize(m_surfaceWidth, m_surfaceHeight);
    }
}

void MirSurfaceItem::setFillMode(FillMode value)
{
    if (value != m_fillMode) {
        m_fillMode = value;
        Q_EMIT fillModeChanged(m_fillMode);
    }
}
