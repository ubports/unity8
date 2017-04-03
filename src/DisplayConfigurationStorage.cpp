#include "DisplayConfigurationStorage.h"

#include <QFile>
#include <QStandardPaths>
#include <QJsonObject>
#include <QJsonDocument>

namespace {

inline QString stringFromEdid(const miral::Edid& edid)
{
    QString str;
    str += QString::fromStdString(edid.vendor);
    str += QString("%1%2").arg(edid.product_code).arg(edid.serial_number);

    for (int i = 0; i < 4; i++) {
        str += QString::fromStdString(edid.descriptors[i].string_value());
    }
    return str;
}

}

DisplayConfigurationStorage::DisplayConfigurationStorage()
{
}

void DisplayConfigurationStorage::save(const miral::DisplayId &displayId, const miral::DisplayConfigurationOptions &options)
{
    const QString dbPath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + QStringLiteral("/unity8/");
    QFile f(dbPath + stringFromEdid(displayId.edid) + ".edid");

    QJsonObject json;
    if (options.used.is_set()) json.insert("used", options.used.value());
    if (options.clone_output_index.is_set()) json.insert("clone_output_index", static_cast<int>(options.clone_output_index.value()));
    if (options.mode.is_set()) {
        auto const& mode = options.mode.value();

        QString sz(QString("%1x%2").arg(mode.size.width.as_int()).arg(mode.size.height.as_int()));
        QJsonObject jsonMode({
                                 {"size", sz},
                                 {"refresh_rate", mode.refresh_rate }
                             });
        json.insert("mode", jsonMode);
    }
    if (options.orientation.is_set()) json.insert("orientation", static_cast<int>(options.orientation.value()));
    if (options.form_factor.is_set()) json.insert("form_factor", static_cast<int>(options.form_factor.value()));
    if (options.scale.is_set()) json.insert("scale", options.scale.value());

    if (f.open(QIODevice::WriteOnly)) {
        QJsonDocument saveDoc(json);
        f.write(saveDoc.toJson());
    }
}

bool DisplayConfigurationStorage::load(const miral::DisplayId &displayId, miral::DisplayConfigurationOptions &options) const
{
    const QString dbPath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + QStringLiteral("/unity8/");
    QFile f(dbPath + stringFromEdid(displayId.edid) + ".edid");

    if (f.open(QIODevice::ReadOnly)) {
        QByteArray saveData = f.readAll();
        QJsonDocument loadDoc(QJsonDocument::fromJson(saveData));

        QJsonObject json(loadDoc.object());
        if (json.contains("used")) options.used = json["used"].toBool();
        if (json.contains("clone_output_index")) options.clone_output_index = json["clone_output_index"].toInt();
        if (json.contains("mode")) {
            QJsonObject jsonMode = json["mode"].toObject();

            if (jsonMode.contains("size") && jsonMode.contains("refresh_rate")) {
                QString sz(jsonMode["size"].toString());
                QStringList geo = sz.split("x", QString::SkipEmptyParts);
                if (geo.count() == 2) {
                    miral::DisplayConfigurationOptions::DisplayMode mode;
                    mode.size = mir::geometry::Size(geo[0].toInt(), geo[1].toInt());
                    mode.refresh_rate = jsonMode["refresh_rate"].toDouble();
                    options.mode = mode;
                }
            }
        }
        if (json.contains("orientation")) options.orientation = static_cast<MirOrientation>(json["orientation"].toInt());
        if (json.contains("form_factor")) options.form_factor = static_cast<MirFormFactor>(json["form_factor"].toInt());
        if (json.contains("scale")) options.scale = json["form_factor"].toDouble();

        return true;
    }

    return false;
}
