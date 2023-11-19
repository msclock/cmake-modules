#[[
Default to configuration.
]]

# Put the include dirs which are in the source or build tree before all other
# include dirs, so the headers in the sources are preferred over the already
# installed ones since cmake 2.4.1
set(CMAKE_INCLUDE_DIRECTORIES_PROJECT_BEFORE ON)

# Open FetchContent fetching logs.
set(FETCHCONTENT_QUIET ON)
