# There are a lot of similarly-built modules in isce2
# so we add some helpers here to avoid code duplication.
# TODO maybe these helpers should have a unique prefix, e.g. "isce2_"

# Compute a prefix based on the current project subdir
# This disambiguates tests with similar names and
# allows better pattern matching using `ctest -R`
macro(isce2_get_dir_prefix)
    file(RELATIVE_PATH dir_prefix ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_LIST_DIR})
    string(REPLACE "/" "." dir_prefix ${dir_prefix})
endmacro()

# Usage:
# add_exe_test(main.cpp helpers.F [additional_source.c ...] )
# or
# add_exe_test(target_from_add_executable)
# The latter form is useful when you need to add dependencies,
# since the former mangles the name via dir_prefix.
function(add_exe_test testfile)
    isce2_get_dir_prefix()
    if(TARGET ${testfile})
        set(target ${testfile})
        set(testname ${dir_prefix}.${testfile})
    else()
        set(target ${dir_prefix}.${testfile})
        add_executable(${target} ${testfile} ${ARGN})
        set(testname ${target})
    endif()
    add_test(NAME ${testname} COMMAND ${target})
endfunction()

# Usage:
# add_python_test(mytest.py)
# This is simpler than add_exe_test since there is no compilation step.
# The python file is esecuted directly, using the exit status as the result.
function(add_python_test testfile)
    isce2_get_dir_prefix()
    set(testname ${dir_prefix}.${testfile})
    add_test(NAME ${testname} COMMAND
        ${Python_EXECUTABLE} ${CMAKE_CURRENT_LIST_DIR}/${testfile})
    set_tests_properties(${testname} PROPERTIES
        ENVIRONMENT PYTHONPATH=${CMAKE_INSTALL_PREFIX}/${PYTHON_MODULE_DIR})
endfunction()

# Computes the relative path from the current binary dir to the base binary
# dir, and installs the given files/targets using this relative path with
# respect to the python package dir.
# This greatly simplifies installation since the source dir structure
# primarily mimics the python package directory structure.
# Note that it first checks if a provided file is a target,
# and if so, installs it as a TARGET instead. Make sure your
# filenames and target names don't have any overlap!
function(InstallSameDir)
    foreach(name ${ARGN})
        if(TARGET ${name})
            set(installtype TARGETS)
        else()
            set(installtype FILES)
        endif()
        file(RELATIVE_PATH path ${isce2_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR})
        install(${installtype} ${name}
                DESTINATION ${ISCE2_PKG}/${path}
                )
    endforeach()
endfunction()
