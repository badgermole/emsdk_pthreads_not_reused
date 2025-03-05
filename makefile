# For printing help and diagnostics
NULCHR :=

# Include Directories
INCLUDES = -I.

VERBOSE ?= false  # Default value for VERBOSE if not specified on the command line

# Source files
SRC_DIR := .
BUILD_DIR := build/dbg
SRCS := $(wildcard $(SRC_DIR)/*.cpp)

# Basic compiler flags
CPPFLAGS=-std=c++20                                           \
         -Wno-backslash-newline-escape                        \
         -Wno-bitwise-op-parentheses                          \
         -Wno-deprecated-register                             \
         -Wno-inconsistent-missing-override                   \
         -Wno-logical-op-parentheses                          \
         -Wmissing-declarations                               \
         -Wdefaulted-function-deleted                         \
         -Wno-unused-value


# Set up where the build artifacts go based on TYPE.  Some variants of "debug" will
# work. Default is optimize if debug is not specified.  E.g., 'make TYPE=dbg', or
# 'make TYPE=debug'(see below).
BUILD_TOP = ./build_pt
BIN_TOP   = ./bin_pt
TYPE      = dbg
OBJ_DIR = $(BUILD_TOP)/$(TYPE)
BIN_DIR = $(BIN_TOP)/$(TYPE)

OBJS=$(addprefix $(OBJ_DIR)/, $(notdir $(subst .c,.o,$(subst .cpp,.o,$(SRCS)) ) ))

# Compiler and Settings
CC=emcc
CXX=em++
AR=emar
RM=rm -f

# See https://github.com/emscripten-core/emscripten/blob/main/src/settings.js for most of the below settings

# Common flags for both compile and link
COMMON_WASM_FLAGS= -fwasm-exceptions -pthread
PTHREAD_POOL_SIZE= -sPTHREAD_POOL_SIZE=4

# Conditionally add the -pthread flag
JS_OUT_NAME=my.html
JS_MODULE_EXPORT_NAME=MyAppWASM

# Common flags for compile
WASM_COMPILE_FLAGS= $(COMMON_WASM_FLAGS)

# Common flags for link
# -sEXPORT_NAME="$(JS_MODULE_EXPORT_NAME)"
WASM_LINK_FLAGS= $(COMMON_WASM_FLAGS) \
$(PTHREAD_POOL_SIZE) \
-sALLOW_MEMORY_GROWTH=1 \
-sALLOW_TABLE_GROWTH=1 \
-sASSERTIONS=2 \
-sDISABLE_DEPRECATED_FIND_EVENT_TARGET_BEHAVIOR=0 \
-sEXPORTED_FUNCTIONS='[]' \
-sEXPORTED_RUNTIME_METHODS='["ccall"]' \
-sLLD_REPORT_UNDEFINED \
-sMAXIMUM_MEMORY=4GB \
-sNO_EXIT_RUNTIME=1 \
-sSTACK_OVERFLOW_CHECK=1 \
-sMODULARIZE=1 \
-sEXPORT_ES6=1 \
-sUSE_ES6_IMPORT_META \
-sMAX_WEBGL_VERSION=2 \
-sFULL_ES3=1 \
-sWASMFS=1 \
-v

# For 'make help'
ifneq (,$(findstring help,$(firstword $(MAKECMDGOALS))))
    $(info $(NULCHR)  )
    $(info $(NULCHR)  Usage: make [-j8] [VERBOSE=true] [nuke | help])
    $(info $(NULCHR)    To create debug my.wasm and my.js in the ./bin/dbg_pt directory, just 'make' or 'make -j8'.)
    $(info $(NULCHR)    VERBOSE will control whether more output is printed - link flags, etc.  Default is false.)
    $(info $(NULCHR)    'nuke' will remove the dbg folder and object files and binaries.)
    $(info $(NULCHR)    'help' will print this help message.)
    $(info $(NULCHR)  )
    $(error $(NULCHR)  )
else
    $(info Type 'make help' to see usage.)
    $(info $(NULCHR)  )
endif

ENV_LNK_FLG=-sENVIRONMENT=web,worker

# if not nuking, but building...
ifeq (,$(findstring nuke,$(firstword $(MAKECMDGOALS))))
    $(info mkdir -p $(BIN_DIR) $(OBJ_DIR))
    $(shell mkdir -p $(OBJ_DIR) $(BIN_DIR))
    WASM_LINK_FLAGS+=$(ENV_LNK_FLG)
ifneq ($(TYPE), dbg)
	## For performance
    $(info - Using optimize flags)
    $(info $(NULCHR)  . . .)
	CPPFLAGS+= -O3 $(WASM_COMPILE_FLAGS)
	LDFLAGS=   -O3 $(WASM_LINK_FLAGS) -sTOTAL_MEMORY=256MB --pre-js button_setup.mjs
else
	## For debug
    $(info - Using debug flags)
    $(info $(NULCHR)  . . .)
	CPPFLAGS+= -g $(WASM_COMPILE_FLAGS)
	LDFLAGS=   -g $(WASM_LINK_FLAGS) -sSAFE_HEAP=1 -sTOTAL_MEMORY=1GB --pre-js button_setup.mjs
endif
endif

ifeq ($(VERBOSE),true)
    $(info INCLUDES = $(INCLUDES))
    $(info WASM_COMPILE_FLAGS = $(WASM_COMPILE_FLAGS) )
    $(info WASM_LINK_FLAGS = $(WASM_LINK_FLAGS) )
endif

LDLIBS= -lembind


# Default build steps
all: tool

# Create WebAssembly from object files
tool: $(OBJS)
	@echo "  Linking "
	@$(CC) $(LDFLAGS) -o $(BIN_DIR)/$(JS_OUT_NAME) $(OBJS) $(LDLIBS)

# Build .o from .cpp
$(OBJ_DIR)/%.o : %.cpp
	@echo "  Compiling " $<
	@$(CXX) $(CPPFLAGS) $(INCLUDES) -c $< -o $@

# Remove all generated files
nuke:
	rm -rf $(BUILD_TOP)
	rm -rf $(BIN_TOP)
