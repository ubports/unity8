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
    parser.setApplicationDescription(QStringLiteral("Description: Unity 8 Shell"));
    parser.addHelpOption();

    QCommandLineOption fullscreenOption(QStringLiteral("fullscreen"),
        QStringLiteral("Run in fullscreen"));
    parser.addOption(fullscreenOption);

    QCommandLineOption framelessOption(QStringLiteral("frameless"),
        QStringLiteral("Run without window borders"));
    parser.addOption(framelessOption);

    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    QCommandLineOption mousetouchOption(QStringLiteral("mousetouch"),
        QStringLiteral("Allow the mouse to provide touch input"));
    parser.addOption(mousetouchOption);
    #endif

    QCommandLineOption windowGeometryOption(QStringList() << QStringLiteral("windowgeometry"),
            QStringLiteral("Specify the window geometry as [<width>x<height>]"), QStringLiteral("windowgeometry"), QStringLiteral("1"));
    parser.addOption(windowGeometryOption);

    QCommandLineOption testabilityOption(QStringLiteral("testability"),
        QStringLiteral("DISCOURAGED: Please set QT_LOAD_TESTABILITY instead.\nLoad the testability driver"));
    parser.addOption(testabilityOption);

    QCommandLineOption devicenameOption(QStringList() << QStringLiteral("devicename"),
            QStringLiteral("Specify the device name instead of letting Unity 8 find it out"), QStringLiteral("devicename"), QLatin1String(""));
    parser.addOption(devicenameOption);

    QCommandLineOption modeOption(QStringLiteral("mode"),
        QStringLiteral("Whether to run greeter and/or shell [full-greeter, full-shell, greeter, shell]"),
        QStringLiteral("mode"), QStringLiteral("full-greeter"));
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

    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    m_hasMouseToTouch = parser.isSet(mousetouchOption);
    #endif

    m_hasFullscreen = parser.isSet(fullscreenOption);
    m_deviceName = parser.value(devicenameOption);
    resolveMode(parser, modeOption);
}

int UnityCommandLineParser::parsePixelsValue(const QString &str)
{
    if (str.endsWith(QLatin1String("gu"), Qt::CaseInsensitive)) {
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
        (parser.value(modeOption) != QLatin1String("full-greeter") &&
         parser.value(modeOption) != QLatin1String("full-shell") &&
         parser.value(modeOption) != QLatin1String("greeter") &&
         parser.value(modeOption) != QLatin1String("shell"))) {

        const QStringList defaultValues = modeOption.defaultValues();
        if (!defaultValues.isEmpty()) {
            m_mode = defaultValues.first();
            qWarning() << "Mode argument was not provided or was set to an illegal value."
                " Using default value of --mode=" << m_mode;
        } else {
            qFatal("Shell mode argument was not provided and there is no default mode.");
        }
    } else {
        m_mode = parser.value(modeOption);
    }
}
