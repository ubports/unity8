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

#ifndef GENERICAPP_H
#define GENERICAPP_H

#include "MirSurfaceItemModel.h"
#include "MirSurfaceItem.h"

#include <QUrl>

class GenericApp : public MirSurfaceItem
{
    Q_OBJECT

    Q_PROPERTY(int touchPressCount READ touchPressCount WRITE setTouchPressCount NOTIFY touchPressCountChanged
                                   DESIGNABLE false)
    Q_PROPERTY(int touchReleaseCount READ touchReleaseCount WRITE setTouchReleaseCount NOTIFY touchReleaseCountChanged
                                     DESIGNABLE false)

public:
    ~GenericApp();

    int touchPressCount() const { return m_touchPressCount; }
    void setTouchPressCount(int count) { m_touchPressCount = count; Q_EMIT touchPressCountChanged(count); }

    int touchReleaseCount() const { return m_touchReleaseCount; }
    void setTouchReleaseCount(int count) { m_touchReleaseCount = count; Q_EMIT touchReleaseCountChanged(count); }

Q_SIGNALS:
    void touchPressCountChanged(int count);
    void touchReleaseCountChanged(int count);

    void inputMethodRequested();
    void inputMethodDismissed();

    // internal mock use
    void deregister();

protected:
    void touchEvent(QTouchEvent * event) override;

private Q_SLOTS:
    void onActiveFocusChanged();

private:
    explicit GenericApp(const QString& name,
                            Type type,
                            State state,
                            const QUrl& screenshot,
                            const QString &qmlFilePath = QString(),
                            QQuickItem *parent = 0);

    void createQmlContentItem();
    void printComponentErrors();

    int m_touchPressCount;
    int m_touchReleaseCount;

    QQmlComponent *m_qmlContentComponent;
    QQuickItem *m_qmlItem;
    QUrl m_screenshotUrl;

    bool m_requestedInputMethod;

    friend class SurfaceManager;
};

Q_DECLARE_METATYPE(GenericApp*)
Q_DECLARE_METATYPE(QList<GenericApp*>)

#endif // GENERICAPP_H
