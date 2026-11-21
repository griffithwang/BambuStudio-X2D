if (NOT DEFINED BOOST_SOURCE_DIR OR NOT EXISTS "${BOOST_SOURCE_DIR}/libs/locale/CMakeLists.txt")
    message(FATAL_ERROR "Boost source directory is missing: '${BOOST_SOURCE_DIR}'")
endif ()

set(_locale_cmake "${BOOST_SOURCE_DIR}/libs/locale/CMakeLists.txt")
file(READ "${_locale_cmake}" _locale_contents)
set(_filter_line "list(FILTER sources_inc EXCLUDE REGEX \"^src/\")")
set(_fix_line "list(REMOVE_ITEM sources_inc \"include/boost/locale.hpp\" \"\${CMAKE_CURRENT_SOURCE_DIR}/include/boost/locale.hpp\")")

string(FIND "${_locale_contents}" "list(REMOVE_ITEM sources_inc" _existing_fix)
string(FIND "${_locale_contents}" "${_filter_line}" _filter_pos)
if (NOT _existing_fix EQUAL -1)
    message(STATUS "Boost.Locale source group fix already present")
elseif (NOT _filter_pos EQUAL -1)
    string(REPLACE "${_filter_line}" "${_filter_line}\n${_fix_line}" _locale_contents "${_locale_contents}")
    file(WRITE "${_locale_cmake}" "${_locale_contents}")
    message(STATUS "Applied Boost.Locale source group fix to ${_locale_cmake}")
else ()
    message(FATAL_ERROR "Could not locate sources_inc filter in ${_locale_cmake}")
endif ()

execute_process(
    COMMAND git apply --verbose --ignore-space-change --whitespace=fix
        "${CMAKE_CURRENT_LIST_DIR}/0001-FIX-OBS-cannot-start-streaming-on-MAC.patch"
    WORKING_DIRECTORY "${BOOST_SOURCE_DIR}"
    RESULT_VARIABLE _obs_patch_result
    OUTPUT_VARIABLE _obs_patch_output
    ERROR_VARIABLE _obs_patch_error
)
message(STATUS "Boost OBS patch result: ${_obs_patch_result}")
if (_obs_patch_output OR _obs_patch_error)
    message(STATUS "${_obs_patch_output}${_obs_patch_error}")
endif ()
