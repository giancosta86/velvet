use path

var -this-script-dir = (path:dir (src)[name])

fn -get-scripts-for-sub-directory { |subdirectory|
  tmp pwd = $-this-script-dir
  put $subdirectory/*.test.elv
}

var single-scripts = [(-get-scripts-for-sub-directory single-scripts)]

var aggregator = [(-get-scripts-for-sub-directory aggregator)]

var readme = [(-get-scripts-for-sub-directory readme)]

var all = [(
  all [
    $@single-scripts
    $@aggregator
    $@readme
  ] |
    order
)]

fn get-script-path { |subdirectory basename|
  path:join $-this-script-dir $subdirectory $basename'.test.elv'
}