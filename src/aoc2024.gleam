import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string
import simplifile.{read}

fn process(a: Int, b: Int, r: List(Int)) -> Int {
  case a, b, r {
    _, _, [] -> {
      a * b
    }
    a, b, [c, d, ..rr] -> {
      { a * b } + process(c, d, rr)
    }
    _, _, _ -> panic
  }
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_3.txt")

  let line = string.trim_end(records)

  let assert Ok(regex) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  let numbers =
    regexp.scan(with: regex, content: line)
    |> list.flat_map(fn(x) { x.submatches })
    |> list.map(fn(sm) {
      option.map(sm, fn(v) {
        case int.parse(v) {
          Ok(number) -> number
          _ -> panic
        }
      })
      |> option.unwrap(0)
    })

  let process_result = case numbers {
    [a, b, ..r] -> process(a, b, r)
    _ -> panic
  }
  io.debug(process_result)
}
