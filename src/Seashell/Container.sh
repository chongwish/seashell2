##############################################################
# Seashell Container                                         #
# ---------------------------------------------------------- #
# There are the environment variable, but they are different #
# from the environment defined in the seashell-init. They    #
# are used when Seashell is running.                         #
##############################################################


# ------------------------------------------------------------
# Runtime Environment Variable
# ------------------------------------------------------------

# Temp variable, changed when a function whose body has "ret"
# called and got by the keyword "var"
declare -g SEASHELL_FN_TEMP_SCALAR_RESULT
declare -ag SEASHELL_FN_TEMP_ARRAY_RESULT


# ------------------------------------------------------------
# Parsing time Environment Variable
# ------------------------------------------------------------

# Record all the moudle path, including the current module
# and vendor modules
declare -g SEASHELL_MODULE_PATHS=""

# Record all the loaded namespace
declare -g SEASHELL_NAMESPACE_LOADED=""

# Seashell's main directory structure
declare -g SEASHELL_DIR_SRC="src"
declare -g SEASHELL_DIR_BIN="bin"
declare -g SEASHELL_DIR_VENDOR="vendor"
declare -g SEASHELL_DIR_BUILD="build"
declare -g SEASHELL_DIR_MACRO="macro"

# The running way of Seashell
# - true: display parsed script
# - false: execute parsed script
declare -g SEASHELL_IS_ARCHIVE=${SEASHELL_IS_ARCHIVE:-false}

# Message color of debug mode
# Don't set any value here!
declare -g SEASHELL_DEBUG_QUOTE_BEGIN="${SEASHELL_DEBUG_QUOTE_BEGIN}"
declare -g SEASHELL_DEBUG_QUOTE_END="${SEASHELL_DEBUG_QUOTE_END}"

# CommandLine Argument
declare -ag SEASHELL_COMMAND_LINE_ARGUMENT=()