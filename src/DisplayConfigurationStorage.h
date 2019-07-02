#ifndef UNITY_DISPLAYCONFIGURATIONSTORAGE_H
#define UNITY_DISPLAYCONFIGURATIONSTORAGE_H

#include <qtmir/miral/display_configuration_storage.h>

class DisplayConfigurationStorage : public miral::DisplayConfigurationStorage
{
public:
    DisplayConfigurationStorage();

    void save(const miral::DisplayId& displayId, const miral::DisplayConfigurationOptions& options) override;
    bool load(const miral::DisplayId& displayId, miral::DisplayConfigurationOptions& options) const override;
};

#endif // UNITY_DISPLAYCONFIGURATIONSTORAGE_H
