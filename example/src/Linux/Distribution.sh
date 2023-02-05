use Linux.Distribution.Arch [ search ] @Arch
use Linux.Distribution.Ubuntu [ clean ]

clean_and_search_mplayer() {
    clean # Ubuntu
    Linux.Distribution.Arch.clean # Arch
    echo "emerge --depclean -v" # Gentoo
    @Arch.search mplayer
}

install() {
    if [[ "`get_distribution`" == "Arch" ]]; then
        Linux.Distribution.Arch.install "$1"
    else
        Linux.Distribution.Ubuntu.install "$1"
    fi
}

uname1() {
    get_distribution && uname -a && get_distribution
}

get_distribution() {
    echo "Arch"
}
