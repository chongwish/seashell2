################################################
# Seashell File                                #
# -------------------------------------------- #
# File operation, including file and directory #
# For example: create file, delete file.       #
################################################


# Get absolute path by a given path
# ------------------------------------------------------------
# Usage:
#   Seashell.File.get_absolute_path "../../abc"
#     => /xx/yy/zz/abc
Seashell.File.get_absolute_path() {
    if [ ! -e "$1" ]; then Seashell.System.exit "Can not get a absolute path of thing that doesn't exist!"; fi
    if [ -f "$1" ]; then
        echo $(cd "$(dirname "$1")" 2>&1 && pwd -P)"/`basename "$1"`"
    else
        echo $(cd "$1" 2>&1 && pwd -P)
    fi
}

# Create a file recursively. It will create the parent
# directories when they are not exist.
# ------------------------------------------------------------
# Usage:
#   Seashell.File.create_file "aa/bb/cc"
Seashell.File.create_file() {
    if [ ! -e "$1" ]; then
        mkdir -p "`dirname $1`"
        touch $1
    fi
}
