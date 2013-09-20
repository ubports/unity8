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

#include "ApplicationImage.h"
#include "ApplicationInfo.h"

#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>

ApplicationImage::ApplicationImage(QQuickItem* parent)
    : QQuickItem(parent),
    m_source(NULL),
    m_fillMode(Stretch),
    m_ready(false),
    m_imageComponent(0),
    m_imageItem(0)
{
}

void ApplicationImage::setSource(ApplicationInfo* source)
{
    if (m_source != source) {
        if (m_source)
            disconnect(m_source, &ApplicationInfo::imageQmlChanged,
                       this, &ApplicationImage::updateImage);

        m_source = source;

        if (m_source) {
            connect(m_source, &ApplicationInfo::imageQmlChanged,
                   this, &ApplicationImage::updateImage);
        }
        updateImage();

        Q_EMIT sourceChanged();
    }
}

void ApplicationImage::setFillMode(FillMode newFillMode)
{
    if (m_fillMode != newFillMode) {
        m_fillMode = newFillMode;
        Q_EMIT fillModeChanged();
    }
}

void ApplicationImage::setReady(bool value)
{
    if (value != m_ready) {
        m_ready = value;
        Q_EMIT readyChanged();
    }
}

void ApplicationImage::destroyImage()
{
    delete m_imageItem;
    m_imageItem = 0;
    delete m_imageComponent;
    m_imageComponent = 0;
    m_qmlUsed.clear();
    setReady(false);
}

void ApplicationImage::updateImage()
{
    if (!m_source || m_source->imageQml().isEmpty()) {
        destroyImage();
    } else if (m_source->imageQml() != m_qmlUsed) {
        destroyImage();
        createImageItem();
    }
}

void ApplicationImage::createImageItem()
{

    if (!m_imageComponent)
        createImageComponent();

    // only create the windowItem one the component is ready
    if (!m_imageComponent->isReady()) {
        connect(m_imageComponent, &QQmlComponent::statusChanged,
                this, &ApplicationImage::onImageComponentStatusChanged);
    } else {
        doCreateImageItem();
    }

}

void ApplicationImage::createImageComponent()
{
    QQmlEngine *engine = QQmlEngine::contextForObject(this)->engine();
    m_imageComponent = new QQmlComponent(engine, this);
    m_imageComponent->setData(m_source->imageQml().toLatin1(), QUrl());
}

void ApplicationImage::doCreateImageItem()
{
    m_imageItem = qobject_cast<QQuickItem *>(m_imageComponent->create());
    m_imageItem->setParentItem(this);
    setReady(true);
}

void ApplicationImage::onImageComponentStatusChanged(QQmlComponent::Status status)
{
    if (status == QQmlComponent::Ready && !m_imageItem)
        doCreateImageItem();
}
