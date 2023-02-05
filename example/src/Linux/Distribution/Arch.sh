install() {
    echo "Arch install: pacman -S $1"
}

clean() {
    echo "Arch clean: pacman -Scc"
}

search() {
    var package_name="`search_package $1`"
    var package_name_list=( "`search_package_list $1`" )
    echo "Arch package search: < $package_name >"
    echo "Arch package list search: [ ${package_name_list[@]} ]"
}

search_package() {
    echo "Searching Package $1"
    local result="$1"
    ret "$result"
    echo "Doesn't Display"
}

search_package_list() {
    echo "Searching Package List $1"
    declare -a result=( "$1-1" "$1-2" "$1-3" )
    ret ( "${result[@]}" )
    echo "Doesn't Display"
}
