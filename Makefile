CC := gcc

BUILD_DIR := build
OBJECT_DIR := $(BUILD_DIR)/obj
LIBRARY_DIR := $(BUILD_DIR)/lib
BINARY_DIR := $(BUILD_DIR)/bin

LIBRARY := $(LIBRARY_DIR)/liblogger.so
APPLICATION := $(BINARY_DIR)/logger_app

LIBRARY_SOURCES := \
	logger/logger.cpp \
	messages/message_queue.cpp

APPLICATION_SOURCES := \
	main.cpp \
	argument_parser/argument_parser.cpp \
	message_parser/message_parser.cpp \
	worker/worker.cpp

LIBRARY_OBJECTS := $(patsubst %.cpp,$(OBJECT_DIR)/%.o,$(LIBRARY_SOURCES))
APPLICATION_OBJECTS := $(patsubst %.cpp,$(OBJECT_DIR)/%.o,$(APPLICATION_SOURCES))

DEPENDENCIES := \
	$(LIBRARY_OBJECTS:.o=.d) \
	$(APPLICATION_OBJECTS:.o=.d)

CPPFLAGS :=
CXXFLAGS := -std=c++17 -O2 -Wall -Wextra -Wpedantic -Wswitch -Werror -fPIC -pthread
LDFLAGS :=
LDLIBS := -lstdc++ -pthread


.PHONY: all library app test clean

all: library app


# Library

library: $(LIBRARY)

$(LIBRARY): $(LIBRARY_OBJECTS)
	@mkdir -p $(dir $@)
	$(CC) -shared $(LDFLAGS) -o $@ $^ $(LDLIBS)


# Application

app: $(APPLICATION)

$(APPLICATION): $(APPLICATION_OBJECTS) $(LIBRARY)
	@mkdir -p $(dir $@)
	$(CC) $(LDFLAGS) -o $@ $(APPLICATION_OBJECTS) \
		-L$(LIBRARY_DIR) -llogger \
		-Wl,-rpath,'$$ORIGIN/../lib' \
		$(LDLIBS)


# Tests

test:
	@echo "Tests are not implemented yet."


# Compilation

$(OBJECT_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@


# Cleaning

clean:
	rm -rf $(BUILD_DIR)


-include $(DEPENDENCIES)