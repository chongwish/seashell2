##########################################################
# Seashell Log                                           #
# ------------------------------------------------------ #
# A logger to record or display message in different way #
##########################################################


# To display information message in console by force
# ------------------------------------------------------------
# Usage:
#   Seashell.Log.info "hello"
Seashell.Log.info() {
    echo $'\e[32m\e[43m'$@$'\e[0m' > /dev/tty
}

# To display error message in console by force
# ------------------------------------------------------------
# Usage:
#   Seashell.Log.error "hello"
Seashell.Log.error() {
    echo $'\e[31m\e[43m'$@$'\e[0m' > /dev/tty
}

# To display information comment
# when the global variable SEASHELL_IS_ARCHIVE is true
# ------------------------------------------------------------
# Usage:
#   Seashell.Log.comment_info "hello"
Seashell.Log.comment_info() {
    if $SEASHELL_IS_ARCHIVE; then
        cat <<< "# "$'\e[32m\e[43m'$@$'\e[0m'
    fi
}

# To display error comment
# when the global variable SEASHELL_IS_ARCHIVE is true
# ------------------------------------------------------------
# Usage:
#   Seashell.Log.comment_error "hello"
Seashell.Log.comment_error() {
    if $SEASHELL_IS_ARCHIVE; then
        cat <<< "# "$'\e[31m\e[43m'$@$'\e[0m'
    fi
}

# To display comment
# when the global variable SEASHELL_IS_ARCHIVE is true
# ------------------------------------------------------------
# Usage:
#   Seashell.Log.comment "hello"
Seashell.Log.comment() {
    if $SEASHELL_IS_ARCHIVE; then
        cat <<< "# $@"
    fi
}

# To display the code
# when the global variable SEASHELL_IS_ARCHIVE is true
# ------------------------------------------------------------
# Usage:
#   Seashell.Log.code_for_archive "$code_content"
Seashell.Log.code_for_archive() {
    if $SEASHELL_IS_ARCHIVE; then
        cat <<< $@
    fi

}

# To display the code
# when the global variable SEASHELL_IS_ARCHIVE is true
# To Run the code
# when the global variable SEASHELL_IS_ARCHIVE is false
# ------------------------------------------------------------
# Usage:
#   Seashell.Log.code "$code_content"
Seashell.Log.code() {
    if $SEASHELL_IS_ARCHIVE; then
        cat <<< $@
    else
        source <(cat <<< "$@")
    fi
}
