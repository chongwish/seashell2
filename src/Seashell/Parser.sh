##################################################################
# Seashell Parser                                                #
# -------------------------------------------------------------- #
# A core library for parsing shell script and translate the code #
# from the modularized style to the non-modularized style.       #
# There are 6 section here:                                      #
#   - parse                                                      #
#   - handle by line                                             #
#   - handle globally                                            #
#   - collect                                                    #
#   - generate                                                   #
#   - private                                                    #
##################################################################


# ------------------------------------------------------------
# Parse
# ------------------------------------------------------------

# Parse a script and make it valid in the given namespace
# There are 2 style to parse
#   - line by line
#   - global
# ------------------------------------------------------------
# Usage:
#   Seashell.Parser.parse "aa/bb/module/src/Abc/Bcd.sh" "Xyz.Def"
Seashell.Parser.parse() {
    # local variable to make this function working recursively
    local __NAMESPACE__=$2

    # the final content of a shell script
    local __CONTENT__

    # mark file
    __CONTENT__="`Seashell.Log.comment "${SEASHELL_DEBUG_QUOTE_BEGIN}$1${SEASHELL_DEBUG_QUOTE_END}"`"

    # helper variable
    local __HANDLE_IGNORED__=false
    local __COLLECT_IGNORED__=false
    local __CONTENT_FUNCION_LIST__

    # the final __LINE__ will be collect to the __CONTENT__
    local __LINE__

    while IFS='' read -r __LINE__ || [ -n "$__LINE__" ]; do
        # line handler
        Seashell.Parser.handle_blank
        Seashell.Parser.handle_comment
        Seashell.Parser.handle_source
        Seashell.Parser.handle_import

        # line collect
        Seashell.Parser.collect_line

        # reset helper variable
        __HANDLE_IGNORED__=false
        __COLLECT_IGNORED__=false
    done < "$1"

    # global handler
    Seashell.Parser.handle_global_function
    Seashell.Parser.handle_global_command
    Seashell.Parser.handle_global_var
    Seashell.Parser.handle_global_ret

    # display or execute
    Seashell.Log.code "$__CONTENT__"
}


# ------------------------------------------------------------
# Private
# ------------------------------------------------------------

# For example:
#   use Abc.Bcd [ fn1 fn2 ]
#     fn_list => fn1 fn2
#     namespace => Abc.Bcd
#     child_namespace =>
#   use Abc.Bcd [ fn1 fn2 ] @Xyz
#     fn_list => fn1 fn2
#     namespace => Abc.Bcd
#     child_namespace => @Xyz
Seashell.Parser.find_import_pointcut() {
    fn_list=${__LINE__/use }
    namespace=${fn_list%% *}
    fn_list=${fn_list/$namespace}
    fn_list=${fn_list//[\[\]]}

    if [[ "$fn_list" == *@* ]]; then
        child_namespace=${fn_list##*@}
        child_namespace="@"${child_namespace// }
        fn_list=${fn_list/$child_namespace}
    fi
}

# Usage:
#   Seashell.Parser.generate_function_list "fn1 fn2" "Abc.Bcd" "@Xyz"
#   Seashell.Parser.generate_function_list "fn1 fn2" "Abc.Bcd"
Seashell.Parser.generate_function_list() {
    local body=""
    local char=$''
    for i in $1; do
        Seashell.Parser.generate_function $i $2 $3
        char=$'\n'
    done
    __LINE__="$body"
}

# Usage:
#  Seashell.Parser.generate_function "fn1" "Abc.Bcd" "@Xyz"
#    => alias User.@Xyz="Abc.Bcd.fn1"
#  Seashell.Parser.generate_function "fn1" "Bcd.Bcd"
#    => alias User.fn1="Abc.Bcd.fn1"
Seashell.Parser.generate_function() {
    local fn_name="${3:+$3.$1}" && fn_name="${fn_name:-$1}"
    __CONTENT_FUNCION_LIST__="${__CONTENT_FUNCION_LIST__:+$__CONTENT_FUNCION_LIST__|}$fn_name"
    body="$body${char}${SEASHELL_DEBUG_QUOTE_BEGIN}alias ${__NAMESPACE__:+$__NAMESPACE__.}$fn_name='$2.$1'${SEASHELL_DEBUG_QUOTE_END}"

}


# ------------------------------------------------------------
# Collect
# ------------------------------------------------------------

# Collect line
Seashell.Parser.collect_line() {
    if $__COLLECT_IGNORED__; then return 0; fi
    __CONTENT__="$__CONTENT__"$'\n'"$__LINE__"
}


# ------------------------------------------------------------
# Handle By Line
# ------------------------------------------------------------

# Ignore blank line
Seashell.Parser.handle_blank() {
    if $__HANDLE_IGNORED__; then return 0; fi
    if [[ -z "${__LINE__// }" ]]; then __HANDLE_IGNORED__=true && __COLLECT_IGNORED__=true; fi
}

# Ignore comment line
Seashell.Parser.handle_comment() {
    if $__HANDLE_IGNORED__; then return 0; fi
    if [[ "${__LINE__}" =~ ^[[:space:]]*#.*$ ]] ; then __HANDLE_IGNORED__=true && __COLLECT_IGNORED__=true; fi
}

# Ignore source line
Seashell.Parser.handle_source() {
    if $__HANDLE_IGNORED__; then return 0; fi

    if [[ "$__LINE__" ==  "source "* ]]; then
        __HANDLE_IGNORED__=true
        __COLLECT_IGNORED__=true
    fi
}

# Handle use line
Seashell.Parser.handle_import() {
    if $__HANDLE_IGNORED__; then return 0; fi

    if [[ "$__LINE__" == "use "* ]]; then
        local fn_list
        local namespace
        local child_namespace

        # fill 3 variables above
        Seashell.Parser.find_import_pointcut

        if [ -z "${fn_list// }" ]; then
            __COLLECT_IGNORED__=true
        else
            # generate alias
            Seashell.Parser.generate_function_list "$fn_list" $namespace $child_namespace
        fi

        # import new namespace, no current namespace
        Seashell.Namespace.import $namespace

        __HANDLE_IGNORED__=true
    fi
}


# ------------------------------------------------------------
# Handle Globally
# ------------------------------------------------------------

# Handle function defination
Seashell.Parser.handle_global_function() {
    # function xx() { / xx() { => xx
    local fn_list="`sed -rn 's/(function\s*)?(.+)\s*\(\)\s*\{/\2/p' <<< $__CONTENT__`"

    # xx yy zz => xx|yy|zz
    fn_list=${fn_list//[[:space:]]/\|}

    # ignore null
    if [[ -n "$fn_list" ]]; then
        __CONTENT_FUNCION_LIST__="${__CONTENT_FUNCION_LIST__:+$__CONTENT_FUNCION_LIST__|}$fn_list"
    fi

    # function xx() { / xx() { => function Abc.Bcd.xx() { / Abc.Bcd.xx() {
    __CONTENT__="`sed -r 's/(function\s*)?(.+)(\s*\(\)\s*\{)/\1'"${SEASHELL_DEBUG_QUOTE_BEGIN}${__NAMESPACE__:+$__NAMESPACE__.}"'\2'"${SEASHELL_DEBUG_QUOTE_END}"'\3/g' <<< $__CONTENT__`"
}

# Handle function calling. 2 conditions
Seashell.Parser.handle_global_command() {
    # 1. function call with namespace
    # defination place, delete
    # calling place, Abc.Bcd.fn1 => `Abc.Bcd.fn1`
    local namespace
    namespace="`sed -r '/(function\s*)?(.+)\s*\(\)\s*\{/d' <<< $__CONTENT__ | sed -rn 's/(^|;|\`|\$\(|&&|\|\|)(\s*)([A-Z][.a-zA-Z0-9]*[a-zA-Z0-9_]+)\s*[^\`\)]*(\s+|\`|\)|$)/\`\3\`/pg'`"

    # debug mode, mark changed
    if [[ -n "$SEASHELL_DEBUG_QUOTE_BEGIN" ]]; then
        __CONTENT__="$(sed -r 's/(^|;|\`|\$\(|&&|\|\|)(\s*)([A-Z][.a-zA-Z0-9]*[a-zA-Z0-9_]+)(\s*[^\`\)]*)(\s+|\`|\)|$)/\1\2'"${SEASHELL_DEBUG_QUOTE_BEGIN}"'\3'"$SEASHELL_DEBUG_QUOTE_END"'\4\5/g' <<< $__CONTENT__)"
    fi

    local i
    local re="\`(([A-Z][a-zA-Z0-9]*\.)*[A-Z][a-zA-Z0-9]*)\.[_a-zA-Z0-9]+\`"

    for i in $namespace; do
        # re match `Abc.Bcd.fn1` => Abc.Bcd
        if [[ "$i" =~ $re ]]; then
            Seashell.Namespace.import ${BASH_REMATCH[1]:-${match[1]}}
        fi
    done

    # calling place, fn1|fn2 => Abc.Bcd.fn1/Abc.Bcd.fn2
    if [[ -n "$__CONTENT_FUNCION_LIST__" ]]; then
        __CONTENT__="$(sed -r 's/(^|;|`|\$\(|&&|\|\|)(\s*)('$__CONTENT_FUNCION_LIST__')(\s*)(\s+|`|\)|$)/\1\2'"${SEASHELL_DEBUG_QUOTE_BEGIN}${__NAMESPACE__:+$__NAMESPACE__.}"'\3'"${SEASHELL_DEBUG_QUOTE_END}"'\4\5/g' <<< $__CONTENT__)"
    fi
}

# Handle keyword var calling
Seashell.Parser.handle_global_var() {
    # calling place, xyz=( "${array[@]}" )
    __CONTENT__="$(sed -r 's/(^|;)(\s*)var\s*([^= ]+)=(\( \")\s*(`|\$\()\s*(.+)\s*(`|\))\s*(\" \))(;|$)/\1\2'"${SEASHELL_DEBUG_QUOTE_BEGIN}"'\6; declare -a \3=\4${SEASHELL_FN_TEMP_ARRAY_RESULT[@]}\8'"${SEASHELL_DEBUG_QUOTE_END}"'/g' <<< $__CONTENT__)"
    # calling place, xyz="$scalar"
    __CONTENT__="$(sed -r 's/(^|;)(\s*)var\s*([^= ]+)=(\")\s*(`|\$\()\s*(.+)\s*(`|\))\s*(\")(;|$)/\1\2'"${SEASHELL_DEBUG_QUOTE_BEGIN}"'\6; local \3=\4$SEASHELL_FN_TEMP_SCALAR_RESULT\8'"${SEASHELL_DEBUG_QUOTE_END}"'/g' <<< $__CONTENT__)"
}

# handle keyword ret calling
Seashell.Parser.handle_global_ret() {
    # calling place, xyz=( "${array[@]}" )
    __CONTENT__="$(sed -r 's/(^|;)(\s*)ret\s*(\()(.+)(;|$)/\1\2'"${SEASHELL_DEBUG_QUOTE_BEGIN}"'SEASHELL_FN_TEMP_ARRAY_RESULT=\3\4\5; return 0'"${SEASHELL_DEBUG_QUOTE_END}"'/g' <<< $__CONTENT__)"
    # calling place, xyz="$scalar"
    __CONTENT__="$(sed -r 's/(^|;)(\s*)ret\s*([^( ]+)(;|$)/\1\2'"${SEASHELL_DEBUG_QUOTE_BEGIN}"'SEASHELL_FN_TEMP_SCALAR_RESULT=\3\4; return 0'"${SEASHELL_DEBUG_QUOTE_END}"'/g' <<< $__CONTENT__)"
}
