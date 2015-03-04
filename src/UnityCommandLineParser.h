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

#ifndef UNITY_COMMAND_LINE_PARSER_H
#define UNITY_COMMAND_LINE_PARSER_H

#include <QCommandLineParser>
#include <QSize>
#include <QString>

class UnityCommandLineParser {
public:
    UnityCommandLineParser(const QCoreApplication &app);

    QSize windowGeometry() const { return m_windowGeometry; }
    bool hasTestability() const { return m_hasTestability; }
    bool hasFrameless() const { return m_hasFrameless; }
    bool hasMouseToTouch() const { return m_hasMouseToTouch; }
    bool hasFullscreen() const { return m_hasFullscreen; }
    QString deviceName() const { return m_deviceName; }
private:

    int parsePixelsValue(const QString &str);
    static float getenvFloat(const char* name, float defaultValue);

    float m_gridUnit;

    QSize m_windowGeometry;
    bool m_hasTestability;
    bool m_hasFrameless;
    bool m_hasMouseToTouch;
    bool m_hasFullscreen;
    QString m_deviceName;
};

#endif // UNITY_COMMAND_LINE_PARSER_H
