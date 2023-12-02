set(PORT_DEBUG ON)
vcpkg_download_distfile(ARCHIVE
    URLS "https://pypi.io/packages/source/P/PyQt5/PyQt5-${VERSION}.tar.gz"
    FILENAME "PyQt-${VERSION}.tar.gz"
    SHA512 1c07d93aefe1c24e80851eb4631b80a99e7ba06e823181325456edb90285d3d22417a9f7d4c3ff9c6195bd801e7dc2bbabf0587af844a5e4b0a410c4611d119e
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

x_vcpkg_get_python_packages(PYTHON_VERSION "3" PYTHON_EXECUTABLE "${CURRENT_INSTALLED_DIR}/tools/python3/python3.11" OUT_PYTHON_VAR "PYTHON3" PACKAGES sip pyqt-builder)

set(venv_path "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-venv")
set(ENV{VIRTUAL_ENV} ${venv_path})

message(STATUS "Running sipbuild...")

# Only -rel for now
set(short_buildtype "-rel")
set(cmake_buildtype "RELEASE")
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

set(ENV{CC} ${VCPKG_DETECTED_CMAKE_C_COMPILER})
set(ENV{CXX} ${VCPKG_DETECTED_CMAKE_CXX_COMPILER})
set(ENV{AR} ${VCPKG_DETECTED_CMAKE_AR})
set(ENV{LD} ${VCPKG_DETECTED_CMAKE_LINKER})
set(ENV{RANLIB} ${VCPKG_DETECTED_CMAKE_RANLIB})
set(ENV{STRIP} ${VCPKG_DETECTED_CMAKE_STRIP})

set(ENV{CPPFLAGS} "${CPPFLAGS_${cmake_buildtype}}")
set(ENV{CFLAGS} "${CFLAGS_${cmake_buildtype}}")
set(ENV{CXXFLAGS} "${CXXFLAGS_${cmake_buildtype}}")
set(ENV{RCFLAGS} "${VCPKG_DETECTED_CMAKE_RC_FLAGS_${cmake_buildtype}}")
set(ENV{LDFLAGS} "${LDFLAGS_${cmake_buildtype}}")

# TODO: Clear if existant?
execute_process(
    COMMAND mkdir -p "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel-make/"
)
# Compare scripts/cmake/vcpkg_build_make.cmake -> ENABLE_INSTALL
string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" Z_VCPKG_INSTALL_PREFIX "${CURRENT_INSTALLED_DIR}")
set(SIPBUILD_ARGS
  "--verbose"
  "--no-make"
  "--no-designer-plugin"
  "--qt-shared"
  "--disable" "QtDesigner"
  "--confirm-license"
  "--pep484-pyi"
  # "--debug"
  "--target-dir" "${CURRENT_PACKAGES_DIR}/lib/python3.11/site-packages"
  "--qmake" "${CURRENT_INSTALLED_DIR}/tools/qt5/bin/qmake"
  "--build-dir" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel-make"
  "--qmake-setting" "'QMAKE_LIBS=\"${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}\"'"
  "--qmake-setting" "'QMAKE_RC=\"${VCPKG_DETECTED_CMAKE_RC_FLAGS_RELEASE}\"'"
  "--qmake-setting" "'QMAKE_CFLAGS_RELEASE=\"${VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE}\"'"
  "--qmake-setting" "'QMAKE_CXXFLAGS_RELEASE=\"${VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE}\"'"
  "--qmake-setting" "'QMAKE_LFLAGS=\"${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE}\"'"
  "--qmake-setting" "'QMAKE_LFLAGS_SHLIB=\"${VCPKG_DETECTED_CMAKE_SHARED_LINKER_FLAGS_RELEASE}\"'"
  "--qmake-setting" "'QMAKE_LFLAGS_PLUGIN=\"${VCPKG_DETECTED_CMAKE_MODULE_LINKER_FLAGS_RELEASE}\"'"
  "--qmake-setting" "'QMAKE_LIBFLAGS_RELEASE=\"${VCPKG_DETECTED_CMAKE_STATIC_LINKER_FLAGS_RELEASE}\"'"
)

message(STATUS "Running sipbuild... (${PYTHON3})")
vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "-m" "sipbuild.tools.build" ${SIPBUILD_ARGS}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "sipbuild-${TARGET_TRIPLET}-0"
    )
message(STATUS "Running sipbuild...finished.")
# TODO: Can we use vcpkg_install_make here instead of duplicating code?

set(MAKEFILE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel-make/Makefile")

vcpkg_list(SET make_opts)
vcpkg_list(SET install_opts)
if (CMAKE_HOST_WIN32)
    set(path_backup "$ENV{PATH}")
    vcpkg_add_to_path(PREPEND "${SCRIPTS}/buildsystems/make_wrapper")
    if(NOT DEFINED Z_VCPKG_MAKE)
        vcpkg_acquire_msys(MSYS_ROOT)
        find_program(Z_VCPKG_MAKE make PATHS "${MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
    endif()
    set(make_command "${Z_VCPKG_MAKE}")
    vcpkg_list(SET make_opts -j ${VCPKG_CONCURRENCY} --trace -f ${MAKEFILE})

    string(REPLACE " " [[\ ]] vcpkg_package_prefix "${CURRENT_PACKAGES_DIR}")
    string(REGEX REPLACE [[([a-zA-Z]):/]] [[/\1/]] vcpkg_package_prefix "${vcpkg_package_prefix}")
    vcpkg_list(SET install_opts -j ${VCPKG_CONCURRENCY} --trace -f ${MAKEFILE} DESTDIR=${vcpkg_package_prefix}/lib/python3.11/site-packages)
    #TODO: optimize for install-data (release) and install-exec (release/debug)

else()
    if(VCPKG_HOST_IS_OPENBSD)
        find_program(Z_VCPKG_MAKE gmake REQUIRED)
    else()
        find_program(Z_VCPKG_MAKE make REQUIRED)
    endif()
    set(make_command "${Z_VCPKG_MAKE}")
    vcpkg_list(SET make_opts V=1 -j ${VCPKG_CONCURRENCY} -f ${MAKEFILE})
    vcpkg_list(SET install_opts -j ${VCPKG_CONCURRENCY} -f ${MAKEFILE} DESTDIR=${CURRENT_PACKAGES_DIR}/lib/python3.11/site-packages)
endif()

vcpkg_list(SET make_cmd_line ${make_command} ${make_opts})
vcpkg_list(SET install_cmd_line ${make_command} install ${install_opts})

message(STATUS "Running build...")
vcpkg_execute_build_process(
        COMMAND ${make_cmd_line}
	#        NO_PARALLEL_COMMAND ${no_parallel_make_cmd_line}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel-make"
        LOGNAME "build-${TARGET_TRIPLET}${short_buildtype}"
)
message(STATUS "Running build... finished.")
message(STATUS "Running install...")
vcpkg_execute_build_process(
        COMMAND ${install_cmd_line}
	#        NO_PARALLEL_COMMAND ${no_parallel_make_cmd_line}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel-make"
        LOGNAME "install-${TARGET_TRIPLET}${short_buildtype}"
)
message(STATUS "Running install... finished.")
