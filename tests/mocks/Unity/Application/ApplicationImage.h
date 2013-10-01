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

#ifndef APPLICATION_IMAGE_H
#define APPLICATION_IMAGE_H

#include <QQuickItem>

class ApplicationInfo;

/* Fake implementation of ApplicationImage

   That fake implementation is not made in QML just because we can only declare
   enumerations in C++. We can't even make readonly properties to mimic an enum
   because properties must begin with a lower case letter.
*/
class ApplicationImage : public QQuickItem {
    Q_OBJECT
    Q_ENUMS(FillMode)
    Q_PROPERTY(ApplicationInfo* source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(FillMode fillMode READ fillMode WRITE setFillMode NOTIFY fillModeChanged)
    Q_PROPERTY(bool ready READ ready WRITE setReady NOTIFY readyChanged)

public:
    explicit ApplicationImage(QQuickItem* parent = 0);
    virtual ~ApplicationImage() {}

    enum FillMode { Stretch, PreserveAspectCrop };

    ApplicationInfo* source() const { return m_source; }
    void setSource(ApplicationInfo* source);

    FillMode fillMode() const  { return m_fillMode; }
    void setFillMode(FillMode);

    void setReady(bool value);
    bool ready() const { return m_ready; }

    Q_INVOKABLE void scheduleUpdate() {}
    Q_INVOKABLE void updateFromCache() {}

Q_SIGNALS:
    void sourceChanged();
    void fillModeChanged();
    void readyChanged();

private Q_SLOTS:
    void updateImage();
    void onImageComponentStatusChanged(QQmlComponent::Status status);

private:
    void createImageItem();
    void createImageComponent();
    void doCreateImageItem();
    void destroyImage();

    ApplicationInfo* m_source;
    FillMode m_fillMode;
    bool m_ready;
    QQmlComponent *m_imageComponent;
    QQuickItem* m_imageItem;
    // the QML script used to create the current m_imageItem
    QString m_qmlUsed;
};

#endif // APPLICATION_IMAGE_H
