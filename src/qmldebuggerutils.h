/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef QMLDEBUGGERUTILS_H
#define QMLDEBUGGERUTILS_H

bool enableQmlDebugger(int argc, const char *argv[])
{
    for (int i = 1; i < argc; ++i) {
        QByteArray arg = argv[i];
        if (arg.startsWith("--"))
            arg.remove(0, 1);
        if (arg.startsWith("-qmljsdebugger=") || (arg == "-qmljsdebugger" && i < argc - 1)) {
            return true;
        }
    }
    return false;
}

#endif
