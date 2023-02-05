########################################################
# Seashell System                                      #
# ---------------------------------------------------- #
# A toolkit to make Seashell project working complete. #
########################################################


# Exit with error message
# ------------------------------------------------------------
# Usage:
#   Seashell.System.exit "Something error"
Seashell.System.exit() {
    Seashell.Log.error $@
    exit 1
}

# Exit with message
# ------------------------------------------------------------
# Usage:
#   Seashell.System.die "Something wrong"
Seashell.System.die() {
    echo $@ > /dev/tty
    exit 1
}

# To initialize the Seashell running environment and
# to parse the mod file in the Seashell module.
# ------------------------------------------------------------
# Usage:
#   Seashell.System.init "/aa/bb/module/mod"
Seashell.System.init() {
    # generate header
    Seashell.Helper.generate_doc_header

    # mod file
    local entry_file
    entry_file="`Seashell.File.get_absolute_path "$1"`"

    shift
    Seashell.Helper.generate_commandline_argument "$@"

    # add module path
    Seashell.Module.add "`dirname "$entry_file"`"

    # reset mod alias, and parse mod file
    alias mod=':'
    Seashell.Parser.parse "$entry_file"
}

# To exit the Seashell running environment and to parse
# the current Seashell script file.
# ------------------------------------------------------------
# Usage:
#   Seashell.System.over
Seashell.System.over() {
    Seashell.Parser.parse "$SEASHELL_CURRENT_SCRIPT"

    Seashell.Helper.generate_entry_execute_function

    exit 0;
}
