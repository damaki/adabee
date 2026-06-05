# AdaBee MAC Frame Library

This directory contains the code for encoding and decoding MAC frames according
to IEEE 802.15.4-2024. It supports the following frame types:
 * Beacon
 * Data
 * Acknowledgement
 * MAC Command
 * Multipurpose

It does not support Fragment/Frak or Extended frame types.

The MAC header (MHR) encoder and decoder is written to SPARK platinum level.
This means that the encoder and decoder are formally verified to correctly
encode and decode MAC headers according to a formal specification.
In particular, the decoder will always reject invalid frames and accept valid
frames, and the encoder will always produce a valid frame.

The formal specification of MAC frames and their rules are defined as ghost code
in the following packages:
 * `AdaBee.MAC.Frames.Headers.PAN_ID_Model` defines the rules for PAN ID
   fields, including PAN ID compression as described in IEEE 802.15.4-2024
   Section 7.2.2.6.
 * `AdaBee.MAC.Frames.Headers.Decoder_Model` defines the rules for when each
   field is present, its position and size in the frame, and whether the frame
   control and security control fields have valid values.
 * `AdaBee.MAC.Frames.Headers.Encoder_Model` defines the relation between a
   `MAC_Header` record to its encoded form in a byte array.
 * `AdaBee.MAC.Frames.Headers.Model_Equivalence` provides lemmas that prove the
   equivalence between the `Encoder_Model` and the `Decoder_Model`.

