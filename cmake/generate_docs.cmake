file(GLOB TRANSFORM_SCRIPT ./scripts/transform.py)

set(CONFLUENCE_COOKIE ${CMAKE_BINARY_DIR}/confluence.cookie)
message(STATUS ${CONFLUENCE_COOKIE})

add_custom_target(create_confluence_cookie
    COMMAND markdown-to-confluence --space CD --user admin --save-cookie ${CONFLUENCE_COOKIE}
    BYPRODUCTS ${CONFLUENCE_COOKIE}
    USES_TERMINAL
)

function(upload_docs PROJECT)
    cmake_parse_arguments(UPLOAD "" "" "SOURCES" ${ARGN})

    add_custom_target(${PROJECT}_upload_docs
        COMMAND markdown-to-confluence --force --space CD --cookie-file ${CONFLUENCE_COOKIE} ${UPLOAD_SOURCES}
        DEPENDS ${UPLOAD_SOURCES} ${CONFLUENCE_COOKIE})
endfunction()

function(generate_docs PROJECT)
    cmake_parse_arguments(GEN "" "" "SOURCES" ${ARGN})

    set(PYTHON_SOURCES ${GEN_SOURCES})
    list(FILTER PYTHON_SOURCES INCLUDE REGEX "\.py$")
    list(FILTER GEN_SOURCES EXCLUDE REGEX "\.py$")

    file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/docs/)

    foreach(FILE_PATH ${PYTHON_SOURCES})
        get_filename_component(PYTHON_FILE ${FILE_PATH} NAME)

        # remove .py extension
        string(REGEX REPLACE "\\.[^.]*$" "" OUTPUT_FILE ${PYTHON_FILE})

        string(PREPEND OUTPUT_FILE ${PROJECT_BINARY_DIR}/docs/)

        list(APPEND OUTPUT_FILES ${OUTPUT_FILE})

        add_custom_command(OUTPUT ${OUTPUT_FILE}
            COMMAND ${PYTHON} ${TRANSFORM_SCRIPT} -i ${FILE_PATH} -o ${OUTPUT_FILE}
            DEPENDS ${FILE_PATH} ${PROJECT_BINARY_DIR}/docs/)
    endforeach()

    # non-python sources
    foreach(FILE_PATH ${GEN_SOURCES})
        get_filename_component(OUTPUT_FILE ${FILE_PATH} NAME)
        string(PREPEND OUTPUT_FILE ${PROJECT_BINARY_DIR}/docs/)

        list(APPEND OUTPUT_FILES ${OUTPUT_FILE})
        configure_file(${FILE_PATH} ${OUTPUT_FILE} COPYONLY)
    endforeach()

    add_custom_target(${PROJECT}_generate_docs
        ALL
        DEPENDS ${OUTPUT_FILES})

    upload_docs(${PROJECT}
        SOURCES ${OUTPUT_FILES})
endfunction()
