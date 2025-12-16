use str
use ../../assertions
use ../../summary

fn create-output-tester-constructor { |reporter|
  put { |section|
    var summary = (summary:from-section $section)

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
          str:contains $report-output $snippet |
            assertions:should-be $true
        }
      }

      &expect-not-in-output={ |snippets|
        all $snippets | each { |snippet|
          str:contains $report-output $snippet |
            assertions:should-be $false
        }
      }
    ]
  }
}