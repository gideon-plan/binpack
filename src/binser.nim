## binser.nim -- CBOR/MessagePack binary serialization. Re-export module.

{.experimental: "strict_funcs".}

import binser/[msgpack, cbor, schema, lattice]
export msgpack, cbor, schema, lattice
