cmake_minimum_required(VERSION 2.8.9)
find_package(Gettext REQUIRED)

SET(POT_FILE
  unity8.pot
)

FILE(GLOB PO_FILES
  *.po
)

SET(MO_FILE unity8.mo)

FOREACH(_file ${PO_FILES})
  GET_FILENAME_COMPONENT(_lang ${_file} NAME_WE)
  SET(_gmoFile ${CMAKE_CURRENT_BINARY_DIR}/${_lang}.gmo)
  ADD_CUSTOM_COMMAND(OUTPUT ${_gmoFile}
    COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} -o ${_gmoFile} ${_file}
    COMMAND install -D ${_gmoFile} ${CMAKE_CURRENT_BINARY_DIR}/locale/${_lang}/LC_MESSAGES/${MO_FILE}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS ${_file}
  )
  INSTALL (FILES ${CMAKE_CURRENT_BINARY_DIR}/${_lang}.gmo DESTINATION ${CMAKE_INSTALL_PREFIX}/share/locale/${_lang}/LC_MESSAGES/ RENAME ${MO_FILE})
  _GETTEXT_GET_UNIQUE_TARGET_NAME( pofiles uniqueTargetName)
  ADD_CUSTOM_TARGET(${uniqueTargetName} ALL DEPENDS ${_gmoFile})
ENDFOREACH(_file)

ADD_CUSTOM_COMMAND(OUTPUT ${POT_FILE}
  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/update-unity-pot
)
ADD_CUSTOM_TARGET(pot_file
  DEPENDS ${POT_FILE}
)
