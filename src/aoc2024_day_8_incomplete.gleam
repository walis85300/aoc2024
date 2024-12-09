import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import simplifile.{read}

pub type Position {
  Free
  Node(String)
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_8.txt")

  let l =
    records
    |> string.trim_end
    |> string.split(on: "\n")
    |> list.index_map(fn(a, row) {
      a
      |> string.to_graphemes
      |> list.index_map(fn(x, col) {
        let b = case x {
          "." -> Free
          c -> Node(c)
        }
        #(#(col, row), b)
      })
    })
    |> list.flat_map(fn(x) { x })

  let max = l |> list.last |> result.lazy_unwrap(fn() { panic }) |> pair.first

  let map =
    l
    |> list.filter(fn(x) {
      case x {
        #(_, Node(_)) -> True
        _ -> False
      }
    })
    |> list.group(by: pair.second)
    |> dict.map_values(fn(_k, v) { v |> list.map(pair.first) })
    |> dict.values

  let info = #(map, max)
  io.debug(info)
}
