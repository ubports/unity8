/*
 * Copyright (C) 2014 Canonical, Ltd.
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
#include "MirSessionItem.h"

#include <paths.h>

#include <QGuiApplication>
#include <QQuickView>
#include <QQmlProperty>
#include <QQmlEngine>
#include <QString>

#include <QDebug>

MirSurfaceItem::MirSurfaceItem(const QString& name,
                               MirSurfaceItem::Type type,
                               MirSurfaceItem::State state,
                               const QUrl& screenshot,
                               const QString &qmlFilePath,
                               QQuickItem *parent)
    : QQuickItem(parent)
    , m_session(nullptr)
    , m_name(name)
    , m_type(type)
    , m_state(state)
    , m_parentSurface(nullptr)
    , m_children(new MirSurfaceItemModel(this))
    , m_qmlItem(nullptr)
    , m_screenshotUrl(screenshot)
{
    qDebug() << "MirSurfaceItem::MirSurfaceItem() " << this->name();

    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    connect(this, &QQuickItem::focusChanged,
            this, &MirSurfaceItem::onFocusChanged);

    // The assumptions I make here really should hold.
    QQuickView *quickView =
        qobject_cast<QQuickView*>(QGuiApplication::topLevelWindows()[0]);

    QString qmlComponentFilePath;
    if (!qmlFilePath.isEmpty()) {
        qmlComponentFilePath.append(qmlFilePath);
    } else {
        qmlComponentFilePath = QString("%1/Unity/Application/MirSurfaceItem.qml")
            .arg(mockPluginsDir());
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

MirSurfaceItem::~MirSurfaceItem()
{
    qDebug() << "MirSurfaceItem::~MirSurfaceItem() " << name();
    Q_EMIT aboutToBeDestroyed();

    QList<MirSurfaceItem*> children(m_children->list());
    for (MirSurfaceItem* child : children) {
        delete child;
    }
    if (m_parentSurface) {
        m_parentSurface->removeChildSurface(this);
    }
    if (m_session) {
        m_session->setSurface(nullptr);
    }
    delete m_children;
}

void MirSurfaceItem::printComponentErrors()
{
    QList<QQmlError> errors = m_qmlContentComponent->errors();
    for (int i = 0; i < errors.count(); ++i) {
        qDebug() << errors[i];
    }
}

void MirSurfaceItem::release()
{
    qDebug() << "MirSurfaceItem::release " << name();

    if (m_parentSurface) {
        m_parentSurface->removeChildSurface(this);
    }
    if (m_session) {
        m_session->setSurface(nullptr);
    }
    if (!parent()) {
        deleteLater();
    }
}

void MirSurfaceItem::setSession(MirSessionItem* session)
{
    m_session = session;
}

void MirSurfaceItem::setScreenshot(const QUrl& screenshot)
{
    m_img.load(screenshot.isLocalFile() ? screenshot.toLocalFile() : screenshot.toString());
    update();
}

void MirSurfaceItem::setParentSurface(MirSurfaceItem* surface)
{
    if (m_parentSurface == surface || surface == this)
        return;

    m_parentSurface = surface;
    Q_EMIT parentSurfaceChanged(surface);
}

void MirSurfaceItem::addChildSurface(MirSurfaceItem* surface)
{
    insertChildSurface(m_children->rowCount(), surface);
}

void MirSurfaceItem::insertChildSurface(uint index, MirSurfaceItem* surface)
{
    qDebug() << "MirSurfaceItem::insertChildSurface - " << surface->name() << " to " << name() << " @  " << index;

    surface->setParentSurface(this);
    m_children->insert(index, surface);
}

void MirSurfaceItem::removeChildSurface(MirSurfaceItem* surface)
{
    qDebug() << "MirSurfaceItem::removeChildSurface - " << surface->name() << " from " << name();

    if (m_children->contains(surface)) {
        m_children->remove(surface);
        surface->setParentSurface(nullptr);
    }
}

MirSurfaceItemModel* MirSurfaceItem::childSurfaces() const
{
    return m_children;
}

void MirSurfaceItem::onQmlWantInputMethodChanged()
{
    QQmlProperty prop(m_qmlItem, "wantInputMethod");
    bool wantInputMethod = prop.read().toBool();

    if (hasFocus() && wantInputMethod) {
        Q_EMIT inputMethodRequested();
    }
}

void MirSurfaceItem::onFocusChanged()
{
    QQmlProperty prop(m_qmlItem, "wantInputMethod");
    bool wantInputMethod = prop.read().toBool();

    if (!hasFocus() && wantInputMethod) {
        Q_EMIT inputMethodDismissed();
        prop.write(QVariant::fromValue(false));
    }
}

void MirSurfaceItem::setState(MirSurfaceItem::State newState)
{
    if (newState != m_state) {
        m_state = newState;
        Q_EMIT stateChanged(newState);
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
    qDebug() << "MirSurfaceItem::createQmlContentItem()";

    m_qmlItem = qobject_cast<QQuickItem*>(m_qmlContentComponent->create());
    m_qmlItem->setParentItem(this);

    setImplicitWidth(m_qmlItem->implicitWidth());
    setImplicitHeight(m_qmlItem->implicitHeight());

    {
        QQmlProperty screenshotSource(m_qmlItem, "screenshotSource");
        screenshotSource.write(QVariant::fromValue(m_screenshotUrl));
    }

    {
        QQmlProperty prop(m_qmlItem, "wantInputMethod");
        if (prop.type() == QQmlProperty::Property) {
            bool ok = prop.connectNotifySignal(this, SLOT(onQmlWantInputMethodChanged()));
            if (!ok) qCritical("MirSurfaceItem: failed to connect to wantInputMethod notify signal");
        }
    }
}
