import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

fn add(p1, p2) {
  let #(x1, y1) = p1
  let #(x2, y2) = p2
  #(x1 + x2, y1 + y2)
}

fn word(map, pos, dir, w) {
  case w {
    [] -> 1
    [hd, ..tail] -> {
      let np = add(pos, dir)
      let n = map |> dict.get(np)
      case n {
        Ok(c) if hd == c -> word(map, np, dir, tail)
        _ -> 0
      }
    }
  }
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_4.txt")
  let lines =
    records
    |> string.trim_end
    |> string.split(on: "\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(char, x) { #(#(x, y), char) })
    })
    |> list.flat_map(fn(x) { x })
    |> dict.from_list

  lines
  |> dict.to_list
  |> list.fold(0, fn(acc, e) {
    let #(pos, char) = e
    let w = ["M", "A", "S"]
    case char {
      "X" ->
        acc
        + word(lines, pos, #(1, 0), w)
        + word(lines, pos, #(1, 1), w)
        + word(lines, pos, #(0, 1), w)
        + word(lines, pos, #(-1, 1), w)
        + word(lines, pos, #(-1, 0), w)
        + word(lines, pos, #(-1, -1), w)
        + word(lines, pos, #(0, -1), w)
        + word(lines, pos, #(1, -1), w)
      _ -> acc
    }
  })
  |> int.to_string
  |> io.debug

  lines
  |> dict.to_list
  |> list.fold(0, fn(acc, e) {
    let #(pos, char) = e
    case char {
      "A" -> {
        acc
        + {
          word(lines, pos, #(1, 1), ["S"])
          * word(lines, pos, #(1, -1), ["S"])
          * word(lines, pos, #(-1, 1), ["M"])
          * word(lines, pos, #(-1, -1), ["M"])
        }
        + {
          word(lines, pos, #(1, 1), ["M"])
          * word(lines, pos, #(1, -1), ["M"])
          * word(lines, pos, #(-1, 1), ["S"])
          * word(lines, pos, #(-1, -1), ["S"])
        }
        + {
          word(lines, pos, #(1, 1), ["M"])
          * word(lines, pos, #(1, -1), ["S"])
          * word(lines, pos, #(-1, 1), ["M"])
          * word(lines, pos, #(-1, -1), ["S"])
        }
        + {
          word(lines, pos, #(1, 1), ["S"])
          * word(lines, pos, #(1, -1), ["M"])
          * word(lines, pos, #(-1, 1), ["S"])
          * word(lines, pos, #(-1, -1), ["M"])
        }
      }
      _ -> acc
    }
  })
  |> io.debug
}
