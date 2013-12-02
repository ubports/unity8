add_subdirectory(AccountsService)
add_subdirectory(GSettings.1.0)
add_subdirectory(HudClient)
add_subdirectory(libusermetrics)
add_subdirectory(LightDM)
add_subdirectory(Powerd)
add_subdirectory(QMenuModel)
add_subdirectory(Ubuntu)
add_subdirectory(Unity)
add_subdirectory(QtMultimedia)

install(
  DIRECTORY data
  DESTINATION ${SHELL_APP_DIR}/mocks
)
