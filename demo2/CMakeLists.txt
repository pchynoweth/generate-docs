project(demo2)

file(GLOB PYTHON_FILES *.py)

generate_docs(${PROJECT_NAME}
    PYTHON_SOURCES ${PYTHON_FILES})
