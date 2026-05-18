use path

var -script-dir = (path:dir (src)[name])

fn -get-scripts-from-sub-dir { |subdir|
  put $-script-dir/$subdir/*.test.elv | each { |script-path|
    count $-script-dir'/' |
      put $script-path[(all)..]
  }
}

var single-scripts = [(-get-scripts-from-sub-dir single-scripts)]

var aggregator = [(-get-scripts-from-sub-dir aggregator)]

var readme = [(-get-scripts-from-sub-dir readme)]

var all = [(
  all [
    $@single-scripts
    $@aggregator
    $@readme
  ] |
    order
)]

fn get-script-path { |subdirectory basename|
  path:join $-script-dir $subdirectory $basename'.test.elv'
}