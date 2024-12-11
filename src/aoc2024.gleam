import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils/read_file.{read_file}

fn only_zeros(a: String, r: List(String)) {
  case a, r {
    a, [b, ..r] if a == "0" -> only_zeros(b, r)
    a, [] if a == "0" -> True
    _, _ -> False
  }
}

fn check_even(a: String) {
  let a_oz = case a |> string.split("") {
    [a, ..r] -> only_zeros(a, r)
    _ -> False
  }
  case a_oz {
    True -> "0"
    False -> {
      let assert Ok(a) = a |> int.parse
      a |> int.to_string
    }
  }
}

fn handle(e: String, r: List(String), b: List(String)) {
  let is_even = { e |> string.length } % 2 == 0
  let h = case e {
    e if e == "0" -> ["1"]
    e if is_even -> {
      let len = e |> string.length
      let half = len / 2
      let fh = e |> string.slice(0, half) |> check_even
      let lh = e |> string.slice(half, len) |> check_even

      [fh, lh]
    }
    e -> {
      let assert Ok(e) = e |> int.parse
      let e = e * 2024
      [e |> int.to_string]
    }
  }
  let b = b |> list.append(h)
  case r {
    [e, ..r] -> handle(e, r, b)
    _ -> b
  }
}

pub fn main() {
  let records = read_file("./aoc2024_11.txt") |> string.split(" ")

  list.range(1, 75)
  |> list.fold(records, fn(a, _) {
    let b: List(String) = []
    case a {
      [e, ..r] -> handle(e, r, b)
      _ -> []
    }
  })
  |> list.length
  |> io.debug
}
