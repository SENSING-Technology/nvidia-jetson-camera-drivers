# Define the compiler
CC = gcc

# Define the include directories
INCLUDES = -I ./

# Define the source files
SRCS = iio_utils.c iio_generic_buffer.c

# Define the target executable
TARGET = iio_generic_buffer

# Define compiler flags
CFLAGS = -Wall -g

# Default target
all: $(TARGET)

# Link and create the executable
$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) $(INCLUDES) $^ -o $@

# Clean up generated files
clean:
	rm -f $(TARGET)

.PHONY: all clean

