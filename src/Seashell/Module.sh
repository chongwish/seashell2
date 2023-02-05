###################################################
# Seashell Module                                 #
# ----------------------------------------------- #
# Seashell module is the directory structure of a #
# project. It manages the file in the module and  #
# makes multiple module working togather.         #
###################################################


# To add a Seashell Module. Just to append the module path
# to the global variable SEASHELL_MODULE_PATHS.
# ------------------------------------------------------------
# Usage:
#   Seashell.Module.add "./abc_module"
Seashell.Module.add() {
    if [ -z "$1" ]; then Seashell.System.exit "Module name can not be null!"; fi

    local seashell_module_path
    seashell_module_path="`Seashell.File.get_absolute_path "$1"`"

    if [ -z "$SEASHELL_MODULE_PATHS" ]; then
        SEASHELL_MODULE_PATHS="$seashell_module_path"
    else
        if [[ ! ":$SEASHELL_MODULE_PATHS:" =~ ":$1:" ]]; then SEASHELL_MODULE_PATHS="$SEASHELL_MODULE_PATHS:$seashell_module_path"; fi
    fi

    # find its vendor modules
    Seashell.Module.append_vendors "$seashell_module_path"
}

# To add the vendor modules in the current module.
# To notice that it will never stop finding the vendor module
# when they depend each other!
# ------------------------------------------------------------
# Usage:
#   Seashell.Module.add "./abc_module"
Seashell.Module.append_vendors() {
    if [ -d "$1/vendor" ]; then
        local i;
        for i in "$1/vendor"/*; do
            Seashell.Module.add "$i"
        done
    fi
}

# To find a module path by namespace
# ------------------------------------------------------------
# Usage:
#   Seashell.Module.find_file_by_namespace "Abc.Bcd"
#     => /aaa/bbb/moduleA/vendor/moduleB
Seashell.Module.find_by_namespace() {
    Seashell.Namespace.verify $1

    local namespace_path
    namespace_path=`Seashell.Namespace.to_path $1`

    local i
    local OLD_IFS=$IFS
    IFS=$":"
    for i in $SEASHELL_MODULE_PATHS; do
        if [ -f "$i/src/$namespace_path" ]; then
            echo $i
            return 0
        fi
    done
    IFS=$OLD_IFS

    Seashell.System.exit "Can not find the file with the namespace of $1!"
}


# To get a file path in the module by namespace
# ------------------------------------------------------------
# Usage:
#   Seashell.Module.find_file_by_namespace "Abc.Bcd"
#     => /aaa/bbb/moduleA/vendor/moduleB/src/Abc/Bcd.sh
Seashell.Module.find_file_by_namespace() {
    local src_file
    src_file="`Seashell.Module.find_by_namespace $1`"
    echo "$src_file/src/`Seashell.Namespace.to_path $1`"
}
