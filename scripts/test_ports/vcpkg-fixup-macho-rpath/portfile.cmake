set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# Test for empty string
set(macho_dir "${CURRENT_PACKAGES_DIR}/lib")
set(test_rpath "")
set(expected "@loader_path")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# Test for empty string in the tools directory
set(macho_dir "${CURRENT_PACKAGES_DIR}/tools/hdf5")
set(test_rpath "")
set(expected "@loader_path/../../lib")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# macho dir in subdir
set(macho_dir "${CURRENT_PACKAGES_DIR}/lib/somesubdir")
set(test_rpath "")
set(expected "@loader_path/..")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath for '${macho_dir}' does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# Getting more complex
set(macho_dir "${CURRENT_PACKAGES_DIR}/plugins/notlib/extrasubdir")
set(test_rpath "")
set(expected "@loader_path/../../../lib")

z_vcpkg_calculate_corrected_macho_rpath(
  MACHO_FILE_DIR "${macho_dir}"
  OUT_NEW_RPATH_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in packages/lib
set(dependency "${CURRENT_PACKAGES_DIR}/lib/libdep.so")
set(expected "@rpath/libdep.so")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in packages/lib/subdir
set(dependency "${CURRENT_PACKAGES_DIR}/lib/plugins/libdep.dylib")
set(expected "@rpath/plugins/libdep.dylib")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in packages/debug/lib/subdir
set(dependency "${CURRENT_PACKAGES_DIR}/debug/lib/libdep.so")
set(expected "@rpath/libdep.so")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in packages/debug/lib/subdir
set(dependency "${CURRENT_PACKAGES_DIR}/debug/lib/plugins/libdep.so")
set(expected "@rpath/plugins/libdep.so")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in installed/lib
set(dependency "${CURRENT_INSTALLED_DIR}/lib/libdep.so")
set(expected "@rpath/libdep.so")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in packages/lib/subdir
set(dependency "${CURRENT_INSTALLED_DIR}/lib/plugins/libdep.so")
set(expected "@rpath/plugins/libdep.so")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in packages/debug/lib/subdir
set(dependency "${CURRENT_INSTALLED_DIR}/debug/lib/libdep.so")
set(expected "@rpath/libdep.so")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in packages/debug/lib/subdir
set(dependency "${CURRENT_INSTALLED_DIR}/debug/lib/plugins/libdep.so")
set(expected "@rpath/plugins/libdep.so")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()

# dependency in system
set(dependency "/usr/lib/libc++.1.dylib")
set(expected "/usr/lib/libc++.1.dylib")

z_vcpkg_calculate_corrected_macho_install_name(
  MACHO_FILE "${dependency}"
  OUT_NEW_INSTALL_NAME_VAR new_rpath
)

if(NOT "x${new_rpath}x" STREQUAL "x${expected}x")
  message(FATAL_ERROR "--- Calculated rpath does not match expected rpath: '${new_rpath}' != '${expected}' ")
else()
  message(STATUS "--- Calculated rpath matches expected rpath: '${new_rpath}' ")
endif()