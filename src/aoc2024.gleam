import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/regexp
import gleam/string
import simplifile.{read}

fn process(a: Int, b: Int, r: List(Int)) -> Int {
  case a, b, r {
    // last case, the last two numbers, only apply the mul
    _, _, [] -> {
      a * b
    }
    // recursive operation
    // apply the multiplication and add the result
    a, b, [c, d, ..rr] -> {
      { a * b } + process(c, d, rr)
    }
    // hehe
    _, _, _ -> panic
  }
}

/// Parse a number in string format to int
fn parse_number(text: String) -> Int {
  case int.parse(text) {
    Ok(number) -> number
    _ -> panic
  }
}

fn extract_number_from_submatch(submatch: Option(String)) -> Int {
  option.map(submatch, parse_number)
  |> option.unwrap(0)
}

fn process_do(do_lines: List(String)) {
  case do_lines {
    [_, ..l] -> l
    _ -> panic
  }
}

fn calculate(numbers: List(Int)) -> Int {
  case numbers {
    // this is the first iteration of process function
    [a, b, ..r] -> process(a, b, r)
    _ -> panic
  }
}

fn same(x: a) -> a {
  x
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_3.txt")

  let line = string.trim_end(records)
  let assert Ok(regex) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")

  // first part
  regexp.scan(with: regex, content: line)
  |> list.flat_map(fn(match) { match.submatches })
  |> list.map(extract_number_from_submatch)
  |> calculate
  |> io.debug

  // second part
  let line_splits = line |> string.split("don't()")

  let #(fm, rest) = case line_splits {
    [a, ..c] -> #(a, c)
    _ -> panic
  }

  let valid_do =
    rest
    |> list.map(fn(x) { string.split(x, on: "do()") })
    |> list.map(process_do)
    |> list.flat_map(same)
    |> list.append([fm])

  valid_do
  |> list.map(fn(x) { regexp.scan(with: regex, content: x) })
  |> list.flat_map(same)
  |> list.map(fn(match) { match.submatches })
  |> list.flat_map(same)
  |> list.map(extract_number_from_submatch)
  |> calculate
  |> io.debug
}
