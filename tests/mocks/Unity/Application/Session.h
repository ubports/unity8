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

#ifndef SESSION_H
#define SESSION_H

#include "SessionModel.h"

#include <QQuickItem>

class ApplicationInfo;

class Session : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(MirSurfaceItem* surface READ surface NOTIFY surfaceChanged)
    Q_PROPERTY(Session* parentSession READ parentSession NOTIFY parentSessionChanged DESIGNABLE false)
    Q_PROPERTY(SessionModel* childSessions READ childSessions DESIGNABLE false CONSTANT)

public:
    explicit Session(const QString &name,
                     const QUrl& screenshot,
                     QObject *parent = 0);
    ~Session();

    Q_INVOKABLE void release();

    //getters
    QString name() const { return m_name; }
    ApplicationInfo* application() const { return m_application; }
    MirSurfaceItem* surface() const { return m_surface; }
    Session* parentSession() const { return m_parentSession; }

    void setApplication(ApplicationInfo* item);
    void setSurface(MirSurfaceItem* surface);
    void setScreenshot(const QUrl& m_screenshot);

    Q_INVOKABLE void addChildSession(Session* session);
    void insertChildSession(uint index, Session* session);
    void removeChildSession(Session* session);

Q_SIGNALS:
    void surfaceChanged(MirSurfaceItem*);
    void parentSessionChanged(Session*);
    void removed();
    // internal mock use
    void deregister();

public Q_SLOTS:
    Q_INVOKABLE void createSurface();

private:
    SessionModel* childSessions() const;
    void setParentSession(Session* session);

    QString m_name;
    QUrl m_screenshot;
    ApplicationInfo* m_application;
    MirSurfaceItem* m_surface;
    Session* m_parentSession;
    SessionModel* m_children;

    friend class ApplicationTestInterface;
};

Q_DECLARE_METATYPE(Session*)

#endif // SESSION_H
