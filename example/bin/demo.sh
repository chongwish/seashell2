source "$(dirname "$0")/../mod"

use Linux.Distribution [ get_distribution uname1 ]
use Linux.Distribution [ clean_and_search_mplayer ] @User

execute() {
  Linux.Distribution.install "mplayer"
  @User.clean_and_search_mplayer
  uname1
}