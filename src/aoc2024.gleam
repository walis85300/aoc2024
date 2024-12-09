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

fn is_dot(x: Position) -> Bool {
  case x {
    #(_, x) if x == "." -> True
    _ -> False
  }
}

fn w(
  l: List(Position),
  p: #(IdPosition, DotPotion),
  r: List(#(IdPosition, DotPotion)),
  nl: Int,
) {
  let py =
    case l |> list.partition(is_dot) {
      #(a, _) -> a
    }
    |> list.length
  case py {
    ly if ly == nl -> {
      l
    }
    _ -> {
      let #(id_position, dot_position) = p
      let #(dp, _) = dot_position
      let #(np, nn) = id_position
      let l = l |> list.key_set(dp, nn) |> list.key_set(np, ".")
      case r {
        [pp, ..r] -> {
          w(l, pp, r, nl)
        }
        [] -> {
          l
        }
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
          string.repeat(id, x)
        }
        _, x -> string.repeat(".", x)
      }
    })
    |> list.fold("", fn(a, acc) { a <> acc })
    |> string.split(on: "")
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

  let nl = num_position |> list.count(fn(_) { True })
  let zipped = list.zip(num_position, dot_position)

  case zipped {
    [p, ..r] -> w(records, p, r, nl)
    _ -> records
  }
  |> list.fold("", fn(a, acc) {
    let #(_, nn) = acc
    a <> nn
  })
  |> io.debug
}
