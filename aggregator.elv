use path
use ./section
use ./utils/seq

var DEFAULT-NUM-WORKERS = 8

var -sandbox-script-path = (
  put (src)[name] |
    path:dir (all) |
    path:join (all) sandbox.elv
)

fn run-test-scripts { |&num-workers=$DEFAULT-NUM-WORKERS @script-paths|
  all $script-paths |
    seq:split-by-chunk-count $num-workers |
    peach &num-workers=$num-workers { |chunk-of-script-paths|
      elvish -norc $-sandbox-script-path $@chunk-of-script-paths |
        from-json
    } |
      section:merge
}