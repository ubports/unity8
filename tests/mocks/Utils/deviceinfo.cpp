/*
 * Copyright (C) 2022 UBports Foundation
 * Author(s): Marius Gripsgard <marius@ubports.com>
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "deviceinfo.h"

#include <map>

static std::map<std::string, std::string> data;

void DeviceInfo::setTestData(std::string prop, std::string val){
    data[prop] = val;
}

void DeviceInfo::resetTestData() {
    data = {
        {"name", "test"},
        {"prettyName", "Test device"},
        {"deviceType", "desktop"},
        {"driverType", "linux"},
        {"gridUnit", "8"},
        {"primaryOrientation", "Landscape"},
        {"portraitOrientation", "Portrait"},
        {"invertedPortraitOrientation", "InvertedPortrait"},
        {"landscapeOrientation", "Landscape"},
        {"invertedLandscapeOrientation", "InvertedLandscape"},
    };
}

DeviceInfo::DeviceInfo(PrintMode) {
    resetTestData();
}

   // Props with auto detections
std::string DeviceInfo::name() {
    return data["name"];
}

std::string DeviceInfo::prettyName() {
    return data["prettyName"];
}

DeviceInfo::DeviceType DeviceInfo::deviceType() {
    return deviceTypeFromString(data["deviceType"]);
}

DeviceInfo::DriverType DeviceInfo::driverType() {
    return driverTypeFromString(data["driverType"]);
}

int DeviceInfo::gridUnit() {
    return std::stoi(data["gridUnit"]);
}

std::string DeviceInfo::get(std::string prop, std::string defaultValue) {
    return contains(prop) ? data[prop] : defaultValue;
}

bool DeviceInfo::contains(std::string prop) {
    return data.find(prop) != data.end();
}

std::string DeviceInfo::deviceTypeToString(DeviceInfo::DeviceType type) {
    switch(type) {
        case DeviceInfo::DeviceType::Phone:
            return "phone";
        case DeviceInfo::DeviceType::Tablet:
            return "tablet";
        case DeviceInfo::DeviceType::Desktop:
        default:
            return "desktop";
    }
}

DeviceInfo::DeviceType DeviceInfo::deviceTypeFromString(std::string str) {
    if (str == "phone")
        return DeviceInfo::DeviceType::Phone;
    if (str == "tablet")
        return DeviceInfo::DeviceType::Tablet;
    return DeviceInfo::DeviceType::Desktop;
}

std::string DeviceInfo::driverTypeToString(DeviceInfo::DriverType type) {
    switch(type) {
        case DeviceInfo::DriverType::Halium:
            return "halium";
        case DeviceInfo::DriverType::Linux:
        default:
            return "linux";
    }
}

DeviceInfo::DriverType DeviceInfo::driverTypeFromString(std::string str) {
    if (str == "halium")
        return DeviceInfo::DriverType::Halium;
    return DeviceInfo::DriverType::Linux;
}
