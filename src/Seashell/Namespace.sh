#######################################################
# Seashell Namespace                                  #
# --------------------------------------------------- #
# Seashell namespace is the file organization for the #
# path of shell source. To make sure locating a file  #
# and importing namespace in the right way.           #
#######################################################


# To import the given namespace.
# "Import" will find the file in the module by the given namspace
# and then parse it.
# ------------------------------------------------------------
# Usage:
#   Seashell.Namespace.import "Abc.Bcd"
Seashell.Namespace.import() {
    # has been imported
    if [[ ":$SEASHELL_NAMESPACE_LOADED:" =~ ":$1:" ]]; then return 0; fi

    local file_name
    file_name=`Seashell.Namespace.to_path $1`

    local namespace_module
    namespace_module=`Seashell.Module.find_by_namespace $1`

    local src_file_path="$namespace_module/$SEASHELL_DIR_SRC/$file_name"

    # parsing by path
    Seashell.Parser.parse "$src_file_path" $1

    # record the status of import
    if [ -z "$SEASHELL_NAMESPACE_LOADED" ]; then SEASHELL_NAMESPACE_LOADED="$1"; fi
    if [[ ! ":$SEASHELL_NAMESPACE_LOADED:" =~ ":$1:" ]]; then SEASHELL_NAMESPACE_LOADED="$SEASHELL_NAMESPACE_LOADED:$1"; fi
}

# To make sure the given namespace is vaild.
# Usage:
#   Seashell.Namespace.verify "Abc.Bcd"
Seashell.Namespace.verify() {
    if [[ -z "$1" ]]; then Seashell.System.exit "Namespace can't be null!"; fi
    if [[ ! "$1" =~ ^([A-Z][a-zA-Z0-9]*\.)*[A-Z][a-zA-Z0-9]*$ ]]; then Seashell.System.exit "$1 isn't a vaild namespace!" ; fi
}

# Change a namespace to a path
# Usage:
#   Seashell.Namespace.to_path "Abc.Bcd"
#     => Abc/Bcd.sh
Seashell.Namespace.to_path() {
    echo "${1//.//}".sh
}
