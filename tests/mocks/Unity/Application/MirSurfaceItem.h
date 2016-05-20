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

    Q_PROPERTY(int mousePressCount READ mousePressCount WRITE setMousePressCount
                                   NOTIFY mousePressCountChanged)
    Q_PROPERTY(int mouseReleaseCount READ mouseReleaseCount WRITE setMouseReleaseCount
                                   NOTIFY mouseReleaseCountChanged)
public:
    explicit MirSurfaceItem(QQuickItem *parent = 0);
    ~MirSurfaceItem();

    Mir::Type type() const override;
    QString name() const override;
    bool live() const override;
    Mir::ShellChrome shellChrome() const override;

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

    FillMode fillMode() const override { return m_fillMode; }
    void setFillMode(FillMode value) override;

    /////
    // For use in qml tests

    void setLive(bool live);

    int touchPressCount() const { return m_touchPressCount; }
    void setTouchPressCount(int count) { m_touchPressCount = count; Q_EMIT touchPressCountChanged(count); }

    int touchReleaseCount() const { return m_touchReleaseCount; }
    void setTouchReleaseCount(int count) { m_touchReleaseCount = count; Q_EMIT touchReleaseCountChanged(count); }

    int mousePressCount() const { return m_mousePressCount; }
    void setMousePressCount(int count) { m_mousePressCount = count; Q_EMIT mousePressCountChanged(count); }

    int mouseReleaseCount() const { return m_mouseReleaseCount; }
    void setMouseReleaseCount(int count) { m_mouseReleaseCount = count; Q_EMIT mouseReleaseCountChanged(count); }

Q_SIGNALS:
    void touchPressCountChanged(int count);
    void touchReleaseCountChanged(int count);
    void mousePressCountChanged(int count);
    void mouseReleaseCountChanged(int count);

protected:
    void touchEvent(QTouchEvent * event) override;
    void mousePressEvent(QMouseEvent * event) override;
    void mouseMoveEvent(QMouseEvent * event) override;
    void mouseReleaseEvent(QMouseEvent * event) override;

private Q_SLOTS:
    void onComponentStatusChanged(QQmlComponent::Status status);
    void updateScreenshot(QUrl screenshot);
    void updateMirSurfaceVisibility();
    void updateMirSurfaceActiveFocus(bool focused);

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
    int m_mousePressCount;
    int m_mouseReleaseCount;
    QVariantMap m_touchTrail;

    FillMode m_fillMode{Stretch};

    friend class SurfaceManager;
};

Q_DECLARE_METATYPE(MirSurfaceItem*)
Q_DECLARE_METATYPE(QList<MirSurfaceItem*>)

#endif // MIRSURFACEITEM_H
