file(GLOB TRANSFORM_SCRIPT ./scripts/transform.py)

function(generate_docs TARGET)
    cmake_parse_arguments(GEN "" "" "SOURCES;PYTHON_SOURCES" ${ARGN})

    foreach(FILE_PATH ${GEN_PYTHON_SOURCES})
        get_filename_component(PYTHON_FILE ${FILE_PATH} NAME)

        string(REGEX REPLACE "\\.[^.]*$" "" OUTPUT_FILE ${PYTHON_FILE})
        string(PREPEND OUTPUT_FILE ${PROJECT_BINARY_DIR}/docs/)

        list(APPEND OUTPUT_FILES ${OUTPUT_FILE})

        add_custom_command(OUTPUT ${OUTPUT_FILE}
            COMMAND ${PYTHON} ${TRANSFORM_SCRIPT} -i ${FILE_PATH} -o ${OUTPUT_FILE}
            DEPENDS ${FILE_PATH} ${PROJECT_BINARY_DIR}/docs/)
    endforeach()

    file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/docs/)

    add_custom_target(${TARGET}
        ALL
        DEPENDS ${OUTPUT_FILES})
endfunction()