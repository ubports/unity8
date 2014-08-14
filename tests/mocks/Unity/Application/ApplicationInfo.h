/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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

#ifndef APPLICATION_H
#define APPLICATION_H

#include "SurfaceManager.h"

#include <QObject>
#include <QQmlComponent>

class QQuickItem;
class MirSurfaceItem;
class MirSurfaceItemModel;

// unity-api
#include <unity/shell/application/ApplicationInfoInterface.h>

// A pretty dumb file. Just a container for properties.
// Implemented in C++ instead of QML just because of the enumerations
// See QTBUG-14861

using namespace unity::shell::application;

class ApplicationInfo : public ApplicationInfoInterface {
    Q_OBJECT

    Q_PROPERTY(bool fullscreen READ fullscreen WRITE setFullscreen NOTIFY fullscreenChanged)
    Q_PROPERTY(Stage stage READ stage WRITE setStage NOTIFY stageChanged)
    Q_PROPERTY(MirSurfaceItem* surface READ surface NOTIFY surfaceChanged)
    Q_PROPERTY(MirSurfaceItemModel* promptSurfaces READ promptSurfaces DESIGNABLE false CONSTANT)

    // Only exists in this fake implementation

    // QML component used to represent its image/screenhot
    Q_PROPERTY(QString imageQml READ imageQml WRITE setImageQml NOTIFY imageQmlChanged)

    // QML component used to represent the application window
    Q_PROPERTY(QString windowQml READ windowQml WRITE setWindowQml NOTIFY windowQmlChanged)

public:
    ApplicationInfo(QObject *parent = NULL);
    ApplicationInfo(const QString &appId, QObject *parent = NULL);
    ~ApplicationInfo();

    #define IMPLEMENT_PROPERTY(name, Name, type) \
    public: \
    type name() const { return m_##name; } \
    void set##Name(const type& value) \
    { \
        if (m_##name != value) { \
            m_##name = value; \
            Q_EMIT name##Changed(value); \
        } \
    } \
    Q_SIGNALS: \
    void name##Changed(const type&); \
    private: \
    type m_##name;

    IMPLEMENT_PROPERTY(appId, AppId, QString)
    IMPLEMENT_PROPERTY(name, Name, QString)
    IMPLEMENT_PROPERTY(comment, Comment, QString)
    IMPLEMENT_PROPERTY(icon, Icon, QUrl)
    IMPLEMENT_PROPERTY(stage, Stage, Stage)
    IMPLEMENT_PROPERTY(state, State, State)
    IMPLEMENT_PROPERTY(focused, Focused, bool)
    IMPLEMENT_PROPERTY(fullscreen, Fullscreen, bool)
    IMPLEMENT_PROPERTY(imageQml, ImageQml, QString)
    IMPLEMENT_PROPERTY(windowQml, WindowQml, QString)
    IMPLEMENT_PROPERTY(screenshot, Screenshot, QUrl)

    #undef IMPLEMENT_PROPERTY

public:
    void setSurface(MirSurfaceItem* surface);
    MirSurfaceItem* surface() const { return m_surface; }

    void removeSurface(MirSurfaceItem* surface);

    void addPromptSurface(MirSurfaceItem* surface);
    void insertPromptSurface(uint index, MirSurfaceItem* surface);
    MirSurfaceItemModel* promptSurfaces() const;

Q_SIGNALS:
    void surfaceChanged(MirSurfaceItem*);

private Q_SLOTS:
    void onStateChanged(State state);

    void createSurface();

private:
    QQuickItem *m_parentItem;
    MirSurfaceItem* m_surface;
    MirSurfaceItemModel* m_promptSurfaces;
};

Q_DECLARE_METATYPE(ApplicationInfo*)
Q_DECLARE_METATYPE(QQmlListProperty<MirSurfaceItem>)

#endif  // APPLICATION_H
