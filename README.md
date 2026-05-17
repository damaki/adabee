# AdaBee

AdaBee is an experiment to write an IEEE 802.15.4 protocol stack in Ada and SPARK.

It is currently very much a work in progress. There is currently a fully
functional radio driver (PHY) for the nRF52840 and some MAC layer facilties
for encoding/decoding packets.

The goal is to target the gold level of SPARK. This gives formal, mathmatical proof of:
 * memory safety: no buffer overruns, no null pointer dereferences, no use-after-free.
 * absence of run-time errors (AoRTE): no numerical overflows, no division by zero,
   no type range or predicate violations.
 * key integrity properties: all subprogram contracts and invariants are always
   maintained.

## License

Apache-2.0 WITH LLVM-exception

## Supported Targets

The physical layer (PHY) driver supports the following targets:
 * Nordic Semi nRF52840

## Layers

The code is organised into crates that reflect the protocol stack layers.
 * `phy/` contains the physical layer (PHY) API and implementations.
 * `mac/` contains the medium access control (MAC) layer.
 * `common/` contains code that is not specific to any particular layer.

The `examples/` directory contains some example SPARK programs that use AdaBee.

### PHY Features

* low-power (sleep) modes
* delayed transmit & receive
* clear channel assessment (CCA)
* energy scans

The PHY API is written in SPARK, and its functional contracts are designed to
ensure that the PHY can only be operated in the correct manner. For example,
it is not possible to enable the receiver while the PHY is in a low-power
sleep state.

The PHY API is the boundary for the SPARK domain. The API is in SPARK, but the
implementation is written in Ada and is excluded from the SPARK proofs.

### MAC Features

The MAC layer is very much in progress. It currently provides some facilities
for encoding and decoding MAC frames according to IEEE 802.15.4-2024.

It supports Beacon, Data, Ack, MAC command, and Multipurpose frame types.
It does not support Fragment/Frak or Extended frame types.

The MAC frame encoder/decoder is written to SPARK platinum level.
There is a formal specification (using ghost code) of the IEEE 802.15.4-2024
MAC header (MHR) fields and frame formats in the package
`AdaBee.MAC.Frames.Headers.MHR_Model`.
This specification models when each field is present, its position in the frame,
its length, and the conditions when the field is valid (if applicable).

The MAC header decoder (in package `AdaBee.MAC.Frames.Headers.Decoders`) is
formally verified against this formal specification to verify that frames are
always decoded correctly. In particular, that invalid frames are always rejected,
valid frames are always decoded successfully, and that each field in the frame
is correctly decoded according to the formal specification.
