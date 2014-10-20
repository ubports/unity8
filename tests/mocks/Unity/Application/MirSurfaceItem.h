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

#ifndef MIRSURFACEITEM_H
#define MIRSURFACEITEM_H

#include "MirSurfaceItemModel.h"

#include <QQuickItem>
#include <QUrl>

class Session;

class MirSurfaceItem : public QQuickItem
{
    Q_OBJECT
    Q_ENUMS(Type)
    Q_ENUMS(State)

    Q_PROPERTY(Type type READ type NOTIFY typeChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(bool live READ live NOTIFY liveChanged)
    Q_PROPERTY(Qt::ScreenOrientation orientation READ orientation WRITE setOrientation NOTIFY orientationChanged DESIGNABLE false)

    Q_PROPERTY(int touchPressCount READ touchPressCount WRITE setTouchPressCount NOTIFY touchPressCountChanged
                                   DESIGNABLE false)
    Q_PROPERTY(int touchReleaseCount READ touchReleaseCount WRITE setTouchReleaseCount NOTIFY touchReleaseCountChanged
                                     DESIGNABLE false)

public:
    enum Type {
        Normal,
        Utility,
        Dialog,
        Overlay,
        Freestyle,
        Popover,
        InputMethod,
    };

    enum State {
        Unknown,
        Restored,
        Minimized,
        Maximized,
        VertMaximized,
        /* SemiMaximized, */
        Fullscreen,
    };

    ~MirSurfaceItem();

    //getters
    Session* session() const { return m_session; }
    Type type() const { return m_type; }
    State state() const { return m_state; }
    QString name() const { return m_name; }
    bool live() const { return m_live; }
    Qt::ScreenOrientation orientation() const { return m_orientation; }

    void setOrientation(const Qt::ScreenOrientation orientation);

    void setSession(Session* item);
    void setScreenshot(const QUrl& screenshot);
    void setLive(bool live);

    int touchPressCount() const { return m_touchPressCount; }
    void setTouchPressCount(int count) { m_touchPressCount = count; Q_EMIT touchPressCountChanged(count); }

    int touchReleaseCount() const { return m_touchReleaseCount; }
    void setTouchReleaseCount(int count) { m_touchReleaseCount = count; Q_EMIT touchReleaseCountChanged(count); }

    Q_INVOKABLE void setState(State newState);
    Q_INVOKABLE void release();

Q_SIGNALS:
    void typeChanged(Type);
    void stateChanged(State);
    void liveChanged(bool live);
    void orientationChanged();
    void touchPressCountChanged(int count);
    void touchReleaseCountChanged(int count);

    void inputMethodRequested();
    void inputMethodDismissed();

    // internal mock use
    void deregister();

protected:
    void touchEvent(QTouchEvent * event) override;

private Q_SLOTS:
    void onFocusChanged();
    void onComponentStatusChanged(QQmlComponent::Status status);

private:
    explicit MirSurfaceItem(const QString& name,
                            Type type,
                            State state,
                            const QUrl& screenshot,
                            const QString &qmlFilePath = QString(),
                            QQuickItem *parent = 0);

    void createQmlContentItem();
    void printComponentErrors();

    Session* m_session;
    const QString m_name;
    const Type m_type;
    State m_state;
    bool m_live;
    Qt::ScreenOrientation m_orientation;
    int m_touchPressCount;
    int m_touchReleaseCount;

    QQmlComponent *m_qmlContentComponent;
    QQuickItem *m_qmlItem;
    QUrl m_screenshotUrl;

    friend class SurfaceManager;
};

Q_DECLARE_METATYPE(MirSurfaceItem*)
Q_DECLARE_METATYPE(QList<MirSurfaceItem*>)
Q_DECLARE_METATYPE(Qt::ScreenOrientation)

#endif // MIRSURFACEITEM_H
