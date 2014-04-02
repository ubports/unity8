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

#ifndef APPLICATION_H
#define APPLICATION_H

#include <QObject>
#include <QQmlComponent>

class QQuickItem;

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

    // Only exists in this fake implementation

    // QML component used to represent its image/screenhot
    Q_PROPERTY(QString imageQml READ imageQml WRITE setImageQml NOTIFY imageQmlChanged)

    // QML component used to represent the application window
    Q_PROPERTY(QString windowQml READ windowQml WRITE setWindowQml NOTIFY windowQmlChanged)

 public:
    ApplicationInfo(QObject *parent = NULL);
    ApplicationInfo(const QString &appId, QObject *parent = NULL);

    #define IMPLEMENT_PROPERTY(name, Name, type) \
    public: \
    type name() const { return m_##name; } \
    void set##Name(const type& value) \
    { \
        if (m_##name != value) { \
            m_##name = value; \
            Q_EMIT name##Changed(); \
        } \
    } \
    Q_SIGNALS: \
    void name##Changed(); \
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
    void showWindow(QQuickItem *parent);
    void hideWindow();

 private Q_SLOTS:
    void onWindowComponentStatusChanged(QQmlComponent::Status status);
    void setRunning();

 private:
    void createWindowItem();
    void doCreateWindowItem();
    void createWindowComponent();
    QQuickItem *m_windowItem;
    QQmlComponent *m_windowComponent;
    QQuickItem *m_parentItem;
};

Q_DECLARE_METATYPE(ApplicationInfo*)

#endif  // APPLICATION_H
