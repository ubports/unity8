/*
 * Copyright (C) 2013,2015 Canonical, Ltd.
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
 *
 */


#ifndef APPLICATION_ARGUMENTS_H
#define APPLICATION_ARGUMENTS_H

#include <QObject>
#include <QSize>
#include <QString>

#include "UnityCommandLineParser.h"

class ApplicationArguments : public QObject,
                             public UnityCommandLineParser
{
    Q_OBJECT
    Q_PROPERTY(QString deviceName READ deviceName NOTIFY deviceNameChanged)
    Q_PROPERTY(QString mode READ mode CONSTANT)

    Q_PROPERTY(bool hasGeometry READ hasGeometry CONSTANT)
    Q_PROPERTY(QSize windowGeometry READ windowGeometry CONSTANT)
    Q_PROPERTY(bool hasTestability READ hasTestability CONSTANT)
    Q_PROPERTY(bool hasFrameless READ hasFrameless CONSTANT)
#ifdef UNITY8_ENABLE_TOUCH_EMULATION
    Q_PROPERTY(bool hasMouseToTouch READ hasMouseToTouch CONSTANT)
#endif

public:
    ApplicationArguments(QCoreApplication *app);

    void setDeviceName(const QString &deviceName);

    bool hasGeometry() const { return m_windowGeometry.isValid(); }

Q_SIGNALS:
    void deviceNameChanged(const QString&);
};

#endif // APPLICATION_ARGUMENTS_H
