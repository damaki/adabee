# AdaBee

AdaBee is an experiment to write an IEEE 802.15.4 protocol stack in Ada and SPARK.

It is currently very much a work in progress. There is currently a fully
functional radio driver (PHY) for the nRF52840 and some MAC layer facilties
for encoding/decoding packets.

The goal is to target the gold level of SPARK. This gives formal, mathmatical
proof of:
 * **memory safety:** no buffer overruns, no null pointer dereferences,
   no use-after-free, resources are never leaked.
 * **absence of run-time errors (AoRTE):** no numerical overflows, no division
   by zero, no type range or predicate violations.
 * **key integrity properties:** all subprogram contracts and invariants are
   always maintained.

## License

Apache-2.0 WITH LLVM-exception

## Supported Targets

The physical layer (PHY) driver supports the following targets:
 * Nordic Semi nRF52840

## Protocol Layers

The code is organised into crates that reflect the implemented protocol stack
layers:
 * `phy/` contains the physical layer (PHY) API and implementations.
 * `mac/` contains the medium access control (MAC) layer.
   * `mac/frames/` contains the MAC frame encoders and decoders.
   * `mac/mlme/` contains the MAC Layer Management Entity (MLME) logic.
 * `common/` contains code that is not specific to any particular layer.

The `examples/` directory contains some example SPARK programs that use AdaBee.

### PHY Features

* low-power (sleep) modes
* delayed transmit & receive
* clear channel assessment (CCA)
* energy detection (ED) scanning
* receive packet filtering

The PHY API is written in SPARK, and its functional contracts are designed to
ensure that the PHY can only be operated in the correct manner. For example,
it is not possible to enable the receiver while the PHY is in a low-power
sleep state.

The PHY API is the boundary for the SPARK domain. The API is in SPARK, but the
implementation is written in Ada and is excluded from the SPARK proofs.
The purpose of this split is to allow for porting to different PHY targets
without affecting the SPARK proofs of the upper layers.

### MAC Features

The MAC layer a work in progress. It currently provides:
 * Encoders and decoders for MAC headers (MHR). It supports Beacon, Data, Ack,
   MAC command, and Multipurpose frame types.
 * A MAC layer management entity (MLME) and Service Access Point (MLME-SAP)
   with support for the following services:
   * MLME-SCAN for performing channel scanning.
   * MLME-SET for setting MAC PIB attributes.
   * MLME-GET for getting MAC PIB attributes.

The MLME-SAP is implemented using [LibSAP](https://github.com/damaki/libsap).

#### Encoder/Decoder SPARK Proofs

The MAC header (MHR) encoder/decoder is written to SPARK platinum level.
There is a formal specification, using ghost code, of the IEEE 802.15.4-2024
MAC header (MHR) format in the packages
`AdaBee.MAC.Frames.Headers.Decoder_Model` and
`AdaBee.MAC.Frames.Headers.Encoder_Model`
This specification models when each field is present, its position in the frame,
its length, and the conditions when the field is valid (if applicable).

The MHR encoder and decoder (in packages `AdaBee.MAC.Frames.Headers.Encoders`
and `AdaBee.MAC.Frames.Headers.Decoders` respectively) are formally verified
against this formal specification. The proofs ensure that:
 * invalid frames are always rejected;
 * valid frames are always accepted;
 * each field is correctly encoded to the correct position in the frame; and
 * the decoder and encoder are bidirectional inverses of each other. That is,
   `decode(encode(frame_data)) = frame_data`, and `encode(decode(frame)) = frame`.

#### MLME SPARK Proofs

The MLME is written to SPARK gold level. This includes the usual silver level
properties (memory safety, absence of run-time errors, etc), as well as
proof of key integrity properties.

The key integrity properties that are proven are:
 * **Correct PHY usage:** The proofs ensure that the MLME always operates the PHY
   in the correct manner. This means that the MLME will never attempt to
   perform an operation that is not allowed in the PHY's current state.
   For example, the MLME will never request the PHY to enable its receiver
   while a transmit operation is in progress.
 * **Correct MLME-SAP message exchanges:** When the MLME responds to a request,
   then it always responds with the correct kind of confirmation primitive.
   For example, if an MLME-SCAN.request is received, then the response sent
   will always be a MLME-SCAN.confirm primitive (and not, say, a
   MLME-SET.confirm primitive).
 * **Correct state machine invariants:** The MLME implements several state
   machines that are driven by various events such as PHY events
   (e.g. packet transmit was completed), reception of MLME-SAP requests, etc.
   The state of these state machines is tied to the state of other states, such
   as the current state of the PHY or the contents of a MLME-SAP request.
   The proofs ensure that the state machines are always kept in sync with these
   other states. For example, if the MLME state machine is currently performing
   an Energy Detection (ED) scan, then the PHY has been correctly placed into
   the `ED_Scan_Active` state.