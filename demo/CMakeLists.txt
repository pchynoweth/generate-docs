project(demo)

file(GLOB SOURCES *.py *.txt *.md)

generate_docs(${PROJECT_NAME}
    SOURCES ${SOURCES})
