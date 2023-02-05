###############################################
# Seashell Function                           #
# ------------------------------------------- #
# Function operation. It's used for extending #
# or changing the running way of function.    #
###############################################


# Fetch the body of a function in memory, and generate a
# new function.
# ------------------------------------------------------------
# If "abc" is function and can be used by the current shell
# Usage:
#   Seashell.Function.change_name "abc" "bcd"
#     => bcd() {
#     =>   xxx
#     => }
Seashell.Function.change_name() {
    local body
    body="`declare -f $1`"
    echo "${body/$1/$2}"
}
