use ../../assertions
use ../../summary

fn create-output-tester-constructor { |reporter|
  put { |sandbox-result|
    var summary = (summary:from-sandbox-result $sandbox-result)

    var report-output = (
      $reporter $summary |
        slurp
    )

    put [
      &debug-print={
        {
          echo 🔎🔎🔎🔎🔎🔎🔎
          echo $report-output
          echo 🔎🔎🔎🔎🔎🔎🔎
        } >&2
      }

      &expect-in-output={ |snippets|
        all $snippets | each { |snippet|
          put $report-output |
            assertions:should-contain $snippet
        }
      }

      &expect-not-in-output={ |snippets|
        all $snippets | each { |snippet|
          put $report-output |
            assertions:should-not-contain $snippet
        }
      }
    ]
  }
}