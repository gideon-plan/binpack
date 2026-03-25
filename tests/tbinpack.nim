## tbinser.nim -- Tests for binser binary serialization.
{.experimental: "strict_funcs".}
import std/[unittest, tables]
import binpack

suite "msgpack":
  test "nil round-trip":
    let enc = encode(mp_nil())
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkNil

  test "bool round-trip":
    for v in [true, false]:
      let enc = encode(mp_bool(v))
      var pos = 0
      let dec = msgpack.decode(enc, pos)
      check dec.kind == mkBool
      check dec.bool_val == v

  test "positive fixint":
    let enc = encode(mp_int(42))
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkInt
    check dec.int_val == 42

  test "negative fixint":
    let enc = encode(mp_int(-5))
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkInt
    check dec.int_val == -5

  test "uint8":
    let enc = encode(mp_uint(200))
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkUint
    check dec.uint_val == 200

  test "string round-trip":
    let enc = encode(mp_str("hello world"))
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkStr
    check dec.str_val == "hello world"

  test "binary round-trip":
    let enc = encode(mp_bin("\x01\x02\x03"))
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkBin
    check dec.bin_val == "\x01\x02\x03"

  test "array round-trip":
    let arr = mp_array(@[mp_int(1), mp_str("two"), mp_bool(true)])
    let enc = encode(arr)
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkArray
    check dec.arr_val.len == 3
    check dec.arr_val[0].int_val == 1
    check dec.arr_val[1].str_val == "two"
    check dec.arr_val[2].bool_val == true

  test "map round-trip":
    let m = mp_map(@[(mp_str("key"), mp_int(99))])
    let enc = encode(m)
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkMap
    check dec.map_val.len == 1

  test "float64 round-trip":
    let enc = encode(mp_float64(3.14))
    var pos = 0
    let dec = msgpack.decode(enc, pos)
    check dec.kind == mkFloat64
    check abs(dec.f64_val - 3.14) < 0.001

suite "cbor":
  test "uint round-trip":
    let enc = cbor.encode(cbor_uint(42))
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckUint
    check dec.uint_val == 42

  test "negative int round-trip":
    let enc = cbor.encode(cbor_int(-10))
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckNegint
    check int64(-1) - int64(dec.negint_val) == -10

  test "text round-trip":
    let enc = cbor.encode(cbor_text("hello"))
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckText
    check dec.text_val == "hello"

  test "bytes round-trip":
    let enc = cbor.encode(cbor_bytes("\xDE\xAD"))
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckBytes
    check dec.bytes_val == "\xDE\xAD"

  test "array round-trip":
    let enc = cbor.encode(cbor_array(@[cbor_uint(1), cbor_text("two")]))
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckArray
    check dec.arr_val.len == 2

  test "bool round-trip":
    let enc = cbor.encode(cbor_bool(true))
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckBool
    check dec.bool_val == true

  test "null round-trip":
    let enc = cbor.encode(cbor_null())
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckNull

  test "float64 round-trip":
    let enc = cbor.encode(cbor_float64(2.718))
    var pos = 0
    let dec = cbor.decode(enc, pos)
    check dec.kind == ckFloat64
    check abs(dec.f64_val - 2.718) < 0.001

suite "schema":
  test "encode msgpack with schema":
    let s = schema("person", field("name", ftStr), field("age", ftInt))
    var vals: Table[string, string]
    vals["name"] = "Alice"
    vals["age"] = "30"
    let result = encode_msgpack(s, vals)
    check result.is_good
    check result.val.len > 0
