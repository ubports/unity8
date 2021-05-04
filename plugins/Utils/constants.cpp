/*
 * Copyright 2015-2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include "constants.h"

#include <QFile>

Constants::Constants(QObject *parent)
   : QObject(parent)
{
    if (qEnvironmentVariableIsEmpty("QT_LOAD_TESTABILITY")) {
        m_indicatorValueTimeout = 30000;
    } else {
        m_indicatorValueTimeout = 5000;
    }

    QString snapRoot = QFile::decodeName(qgetenv("SNAP"));
    m_defaultWallpaper = snapRoot + "/usr/share/backgrounds/warty-final-ubuntu.png";
}
