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

#ifndef MIRSURFACEITEM_H
#define MIRSURFACEITEM_H

#include "MirSurface.h"

#include <QQuickItem>
#include <QUrl>

// unity-api
#include <unity/shell/application/MirSurfaceItemInterface.h>

class MirSurfaceItem : public unity::shell::application::MirSurfaceItemInterface
{
    Q_OBJECT

    ////
    // for use in qml tests
    Q_PROPERTY(int touchPressCount READ touchPressCount WRITE setTouchPressCount
                                   NOTIFY touchPressCountChanged DESIGNABLE false)
    Q_PROPERTY(int touchReleaseCount READ touchReleaseCount WRITE setTouchReleaseCount
                                     NOTIFY touchReleaseCountChanged DESIGNABLE false)

public:
    explicit MirSurfaceItem(QQuickItem *parent = 0);
    ~MirSurfaceItem();

    Mir::Type type() const override;
    QString name() const override;
    bool live() const override;

    Mir::State surfaceState() const override;
    void setSurfaceState(Mir::State) override {}

    Mir::OrientationAngle orientationAngle() const override;
    void setOrientationAngle(Mir::OrientationAngle angle) override;

    unity::shell::application::MirSurfaceInterface* surface() const override { return m_qmlSurface; }
    void setSurface(unity::shell::application::MirSurfaceInterface*) override;

    bool consumesInput() const override { return m_consumesInput; }
    void setConsumesInput(bool value) override;

    int surfaceWidth() const override;
    void setSurfaceWidth(int value) override;

    int surfaceHeight() const override;
    void setSurfaceHeight(int value) override;

    /////
    // For use in qml tests

    void setLive(bool live);

    int touchPressCount() const { return m_touchPressCount; }
    void setTouchPressCount(int count) { m_touchPressCount = count; Q_EMIT touchPressCountChanged(count); }

    int touchReleaseCount() const { return m_touchReleaseCount; }
    void setTouchReleaseCount(int count) { m_touchReleaseCount = count; Q_EMIT touchReleaseCountChanged(count); }

Q_SIGNALS:
    void touchPressCountChanged(int count);
    void touchReleaseCountChanged(int count);

protected:
    void touchEvent(QTouchEvent * event) override;
    void mousePressEvent(QMouseEvent * event) override;
    void mouseMoveEvent(QMouseEvent * event) override;
    void mouseReleaseEvent(QMouseEvent * event) override;
    void itemChange(ItemChange change, const ItemChangeData & value) override;

private Q_SLOTS:
    void onComponentStatusChanged(QQmlComponent::Status status);
    void updateScreenshot(QUrl screenshot);

private:
    void createQmlContentItem();
    void printComponentErrors();
    void updateSurfaceSize();

    MirSurface* m_qmlSurface;

    QQmlComponent *m_qmlContentComponent;
    QQuickItem *m_qmlItem;

    bool m_consumesInput;

    int m_surfaceWidth;
    int m_surfaceHeight;

    int m_touchPressCount;
    int m_touchReleaseCount;

    friend class SurfaceManager;
};

Q_DECLARE_METATYPE(MirSurfaceItem*)
Q_DECLARE_METATYPE(QList<MirSurfaceItem*>)

#endif // MIRSURFACEITEM_H
