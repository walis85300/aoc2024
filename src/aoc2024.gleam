import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type Position =
  #(Int, String)

type DotPotion =
  Position

type IdPosition =
  Position

fn h(l: List(Position)) {
  case l {
    [#(_, "."), ..] -> 0
    [#(_, _), ..r] -> 1 + h(r)
    [] -> 0
  }
}

fn w(
  l: List(Position),
  p: #(IdPosition, DotPotion),
  r: List(#(IdPosition, DotPotion)),
  nl: Int,
) {
  let #(id_position, dot_position) = p
  let #(dp, _) = dot_position
  let #(np, nn) = id_position

  let current_pos = h(l)
  case current_pos >= nl {
    True -> l
    False -> {
      let updated_l =
        l
        |> list.key_set(dp, nn)
        |> list.key_set(np, ".")

      case r {
        [next_p, ..remaining] -> w(updated_l, next_p, remaining, nl)
        [] -> updated_l
      }
    }
  }
}

pub fn main() {
  let assert Ok(records) = read(from: "./aoc2024_9.txt")
  let records: List(Position) =
    records
    |> string.trim_end
    |> string.split(on: "")
    |> list.map(fn(i) {
      let assert Ok(i) = int.parse(i)
      i
    })
    |> list.index_map(fn(x, i) {
      case i, x {
        i, x if i % 2 == 0 -> {
          let id = { i / 2 } |> int.to_string
          list.range(0, x - 1)
          |> list.map(fn(_) { id })
        }
        _, x if x != 0 -> {
          list.range(0, x - 1)
          |> list.map(fn(_) { "." })
        }
        _, _ -> []
      }
    })
    |> list.flat_map(fn(x) { x })
    |> list.index_map(fn(x, i) { #(i, x) })

  let dot_position: List(DotPotion) =
    records
    |> list.filter(fn(x) {
      case x {
        #(_, x) if x == "." -> True
        _ -> False
      }
    })

  let num_position: List(IdPosition) =
    records
    |> list.filter(fn(x) {
      case x {
        #(_, x) if x != "." -> True
        _ -> False
      }
    })
    |> list.reverse

  let nl = num_position |> list.length
  let zipped = list.zip(num_position, dot_position)

  case zipped {
    [p, ..r] -> w(records, p, r, nl)
    _ -> records
  }
  |> io.debug
  |> list.map(fn(x) {
    let #(n, v) = x
    case n, v {
      _, v if v == "0" || v == "." -> 0
      n, v -> {
        let assert Ok(v) = v |> int.parse
        n * v
      }
    }
  })
  |> list.fold(0, fn(acc, a) { acc + a })
  |> io.debug
}
