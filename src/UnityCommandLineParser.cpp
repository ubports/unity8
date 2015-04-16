/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "UnityCommandLineParser.h"

#include <QDebug>

#define ENV_GRID_UNIT_PX "GRID_UNIT_PX"
#define DEFAULT_GRID_UNIT_PX 8

UnityCommandLineParser::UnityCommandLineParser(const QCoreApplication &app)
{
    m_gridUnit = getenvFloat(ENV_GRID_UNIT_PX, DEFAULT_GRID_UNIT_PX);

    QCommandLineParser parser;
    parser.setApplicationDescription("Description: Unity 8 Shell");
    parser.addHelpOption();

    QCommandLineOption fullscreenOption("fullscreen",
        "Run in fullscreen");
    parser.addOption(fullscreenOption);

    QCommandLineOption framelessOption("frameless",
        "Run without window borders");
    parser.addOption(framelessOption);

    QCommandLineOption mousetouchOption("mousetouch",
        "Allow the mouse to provide touch input");
    parser.addOption(mousetouchOption);

    QCommandLineOption windowGeometryOption(QStringList() << "windowgeometry",
            "Specify the window geometry as [<width>x<height>]", "windowgeometry", "1");
    parser.addOption(windowGeometryOption);

    QCommandLineOption testabilityOption("testability",
        "DISCOURAGED: Please set QT_LOAD_TESTABILITY instead.\nLoad the testability driver");
    parser.addOption(testabilityOption);

    QCommandLineOption modeOption("mode",
        "Whether to run greeter and/or shell [full-greeter, full-shell, greeter, shell]",
        "mode", "full-greeter");
    parser.addOption(modeOption);

    // Treat args with single dashes the same as arguments with two dashes
    // Ex: -fullscreen == --fullscreen
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);

    parser.process(app);

    if (parser.isSet(windowGeometryOption))
    {
        QStringList geom = parser.value(windowGeometryOption).split('x');
        if (geom.count() == 2) {
            m_windowGeometry.rwidth() = parsePixelsValue(geom[0]);
            m_windowGeometry.rheight() = parsePixelsValue(geom[1]);
        }
    }

    m_hasTestability = parser.isSet(testabilityOption);
    m_hasFrameless = parser.isSet(framelessOption);
    m_hasMouseToTouch = parser.isSet(mousetouchOption);
    m_hasFullscreen = parser.isSet(fullscreenOption);
    resolveMode(parser, modeOption);
}

int UnityCommandLineParser::parsePixelsValue(const QString &str)
{
    if (str.endsWith("gu", Qt::CaseInsensitive)) {
        QString numStr = str;
        numStr.remove(numStr.size() - 2, 2);
        return numStr.toInt() * m_gridUnit;
    } else {
        return str.toInt();
    }
}

float UnityCommandLineParser::getenvFloat(const char* name, float defaultValue)
{
    QByteArray stringValue = qgetenv(name);
    bool ok;
    float value = stringValue.toFloat(&ok);
    return ok ? value : defaultValue;
}

void UnityCommandLineParser::resolveMode(QCommandLineParser &parser, QCommandLineOption &modeOption)
{
    // If an invalid option was specified, set it to the default
    // If no default was provided in the QCommandLineOption constructor, abort.
    if (!parser.isSet(modeOption) ||
        (parser.value(modeOption) != "full-greeter" &&
         parser.value(modeOption) != "full-shell" &&
         parser.value(modeOption) != "greeter" &&
         parser.value(modeOption) != "shell")) {

        if (modeOption.defaultValues().first() != nullptr) {
            m_mode = modeOption.defaultValues().first();
            qWarning() << "Mode argument was not provided or was set to an illegal value."
                " Using default value of --mode=" << m_mode;
        } else {
            qFatal("Shell mode argument was not provided and there is no default mode.");
        }
    } else {
        m_mode = parser.value(modeOption);
    }
}
