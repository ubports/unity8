/****************************************************************************
**
** Copyright (C) 2015 Jolla.
** Copyright (C) 2015 Canoncal Ltd.
** Contact: http://www.qt-project.org/legal
**
** This file is part of the QtSystems module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QDECLARATIVEINPUTDEVICEINFO_H
#define QDECLARATIVEINPUTDEVICEINFO_H

#include <QObject>
#include <QAbstractListModel>
#include "mockqinputinfo.h"

class QDeclarativeInputDeviceInfo : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(QDeclarativeInputDeviceInfo)

public:
    enum ItemRoles {
        ServiceRole = Qt::UserRole + 1
    };

    explicit QDeclarativeInputDeviceInfo(QObject *parent = 0);
    virtual ~QDeclarativeInputDeviceInfo();

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE int indexOf(const QString &devicePath) const;

    Q_INVOKABLE QInputDevice *get(int index) const;

    // For testing
    Q_INVOKABLE void addMockMouse();
    Q_INVOKABLE void addMockKeyboard();
    Q_INVOKABLE void removeMockMouse();
    Q_INVOKABLE void removeMockKeyboard();

Q_SIGNALS:
    void newDevice(const QString &devicePath);
    void deviceRemoved(const QString &devicePath);

public Q_SLOTS:
    void updateDeviceList();

private:
    QInputDeviceInfo *deviceInfo;
    QVector<QInputDevice *> inputDevices;
private Q_SLOTS:
    void addedDevice(const QString &);
    void removedDevice(const QString &path);

};

#endif // QDECLARATIVEINPUTDEVICEINFO_H
