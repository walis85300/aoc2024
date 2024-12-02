import gleam/int
import gleam/io
import gleam/list.{flat_map}
import gleam/option
import gleam/regexp.{type Match}
import gleam/string
import simplifile.{read}

fn p_sm(x: Match) -> List(Int) {
  x.submatches
  |> list.map(fn(sm: option.Option(String)) -> Int {
    option.map(sm, fn(val: String) -> Int {
      let num: Int = case int.parse(val) {
        Ok(num) -> num
        _ -> panic
      }
      num
    })
    |> option.unwrap(0)
  })
}

fn p_line(s: String) -> List(Int) {
  let regex: regexp.Regexp = case regexp.from_string("(\\d+) +(\\d+)") {
    Ok(regex) -> regex
    _ -> panic
  }
  regexp.scan(with: regex, content: s)
  |> flat_map(p_sm)
}

/// Get the right or left value in a list of pairs 
fn extract_value(pairs: List(List(Int)), index: Int) -> List(Int) {
  pairs
  |> list.map(fn(pair: List(Int)) -> Int {
    case pair {
      [x, _] if index == 0 -> x
      [_, x] if index == 1 -> x
      _ -> 0
    }
  })
  |> list.sort(by: int.compare)
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_1.gleam")
  let a: List(List(Int)) =
    string.trim_end(records)
    |> string.trim
    |> string.trim_start
    |> string.trim_end
    |> string.split(on: "\n")
    |> list.map(p_line)

  let ri: List(Int) = extract_value(a, 0)
  let le: List(Int) = extract_value(a, 1)

  list.zip(le, ri)
  |> list.map(fn(x: #(Int, Int)) -> Int {
    let #(l, r) = x
    l - r |> int.absolute_value
  })
  |> int.sum
  |> io.debug

  le
  |> list.map(fn(x: Int) -> Int {
    let c: Int = ri |> list.count(fn(y: Int) -> Bool { x == y })
    c * x
  })
  |> int.sum
  |> io.debug
}
