---
title: "Realtime Media Container"
abbrev: "container"
category: info

docname: draft-law-moq-catalog-latest
date: {DATE}
category: info
submissiontype: IETF
consensus: true
v: 3

area: "RAI"
workgroup: "Media Over QUIC"
venue:
  group: "Media Over QUIC"
  type: "Working Group"
  mail: "moq@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/moq/"
  github: "suhasHere/moq-drafts"

author:
 -
    fullname: Suhas Nandakumar
    organization: Cisco
    email: snandaku@cisco.com
 -
    fullname: Mo Zanaty
    organization: Cisco
    email: mzanaty@cisco.com
 -
    fullname: Peter Thatcher
    organization: Microsoft
    email: pthatcher@microsoft.com

normative:
  AV1:
    title: "AV1 Bitstream & Decoding Process Specification"
    date: January 18, 2019
    seriesinfo:
      Alliance for Open Media
    target: https://aomedia.org/av1/specification/
    authors:
      -
        ins: P. de Rivaz
        name: Peter de Rivaz
        org: Argon Design
      -
        ins: J. Haughton
        name: Jack Haughton
        org: Argon Design

  H.264:
    title: "Advanced video coding for generic audiovisual services"
    date: 2013
    seriesinfo:
      ITU-T: Recommendation H.264
    author:
      -
        org: ITU-T

  HEVC:
    title: "High efficiency video coding"
    date: 08/2021
    seriesinfo:
      ITU-T: Recommendation H.265
    author:
      -
        org: ITU-T

  ISO14496-15:
    title: "Information technology — Coding of audio-visual objects — Part 15: Carriage of network abstraction layer"
    date: 08/2022
    seriesinfo:
      ISO/IEC: 14496-15 
    author:
      -
        org: ISO/IEC

  VP9:
    title: "VP9 Bitstream & Decoding Process Specification"
    date: 2016
    seriesinfo:
      Google: Google APIs 
    target: 
      https://storage.googleapis.com/downloads.webmproject.org/
              docs/vp9/vp9-bitstream-specification-
              v0.6-20160331-draft.pdf
    author:
      -
        ins: A. Grange
        name: Adrian Grange
        org: Google
      -
        ins: P. de Rivaz
        name: Peter de Rivaz
        org: Argon Design
      -
        ins: J. Hunt
        name: Jonathan Hunt
        org: Argon Design

informative:

  OpenID:
    target: "http://openid.net/specs/openid-connect-core-1_0.html"
    title: "OpenID Connect Core 1.0 incoClientorating errata set 1"
    date: 2014/11/08
    author:
      -
        ins: N. Sakimura
        name: Nat Sakimura
        org: NRI
      -
        ins: J. Bradley
        name: John Bradley
        org: Ping Identity
      -
        ins: M. Jones
        name: Mike Jones
        org: Microsoft
      -
        ins: B. de Medeiros
        name: Breno de Medeiros
        org: Google
      -
        ins: C. Mortimore
        name: Chuck Mortimore
        org: Salesforce

  OpenID.Discovery:
    target: "https://openid.net/specs/openid-connect-discovery-1_0.html"
    title: "OpenID Connect Discovery 1.0 incoClientorating errata set 1"
    date: 2014/11/08
    author:
      -
        ins: N. Sakimura
        name: Nat Sakimura
        org: NRI
      -
        ins: J. Bradley
        name: John Bradley
        org: Ping Identity
      -
        ins: B. de Medeiros
        name: Breno de Medeiros
        org: Google
      -
        ins: E. Jay
        name: Edmund Jay
        org: Illumila

  OpenID.DPoP:
    target: "https://openid.net/todo"
    title: Demonstrating Proof of Possession in OpenID Connect
    date: 2022/01/01
    author:
      -
        ins: M. Jones
        name: Mike Jones
        org: Microsoft
      -
        ins: R. Barnes
        name: Richard Barnes
        org: Cisco
      -
        ins: P. Kasselman
        name: Pieter Kasselman
        org: Microsoft

--- abstract

This specification describes a media container format for
encoded and encrypted audio and video media data to be used
for interactive media usecases, with the goal of it being
a low overhead format.

--- middle

# Introduction - Mo

This specification describes a media container format for
encoded and encrypted audio and video media data to be used
for interactive media usecases, with the goal of it being
a low overhead format.

The container format description is specified for
most common audio and video codecs along with
necessary metadata needed for identifying the media
data.

TODO: Add some context on existing payload formats like in
RTP, container formats like CMAF and why there is a needed for
generic low overhead container format.l.

## Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD","SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in {{!RFC2119}}.

## Terminology

TODO


# Payload Format {#payload} - Mo

This section specifies format of the encoded payload for several
audio and video codecs.

TODO: verify and fix references.

## AV1

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of {{AV1}}, which is expected to be data compliant to the "low-overhead bitstream format" as described in Section 5 of {{AV1}}.


## AVC/H.264

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of {{H.264}} with the bistream is expected to be
in canonical format, as defined in {{ISO14496-15}} section 5.3.2.

## HEVC/H.265

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of {{HEVC}} with the bistream is expected to be
in canonical format, as defined in {{ISO14496-15}} section 8.3.2.

## VP8

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of {{!RFC6386}}, which is expected to be frame as described in Section 4 and Annex A of {{!RFC6386}}.

## VP9 {#vp9-payload}

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of {{!RFC6386}}, which is expected to be frame as described in Section 6 of {{VP9}}.


## OPUS

The encoded audio data MUST conform to format as defined in Section 2 of {{!RFC6716}} when the bitstream is in opus format. Bitstream of ogg format MUST NOT be used.

# Payload Header Data

This section specified metadata that needs to be carried out as payload metadata. Payload metadata provides 
necessary information for intermediaries to perform necessary switching decisions when the payload is inaccessible, possibly due to encryption.

Section XXX provides framework for registering 
new payload metadata fields that aren't defined by
this specification

## Common Header Data

Following metadata MUST be captures for each media frame

*Sequence Number* identifies a sequentially increasing variable length integer that is incremented per encoded media frame.

*Encoding Timestamp in Microseconds* capture the wall-clock time of the encoded media frame.

## Video Metadata
 TODO fill this 

## Audio Metadata

*Audio Level* captures the magnitude of the audio level of the corresponding audio frame and valus in encoded in 7 bits as defined in the section 3 of {{!RFC6464}}

# Metadata Registration

This section details the procedures to register metadata field that might be useful for a particular class of media applications. 

Resistering a given metadata field requires following 
attributes to be specified

*name* User friendly identifier for the metadata. 
*datatype* for the representing the metadata on wire
*id* a varint ien
*value* 

# Payload Encryption

When end to end encryption is supported, the encoded paylood is encrypted
with keys from symmetric keying mechanisms, such a MLS, and the payload itself is protected

# Container Serialization

# MOQ Transport Mapping

## Extra

~~~~
What needs to be agreed on or standardized?
What are the “bytes” of the “payload” for a codec?
Just do what’s defined at https://w3c.github.io/webcodecs/codec_registry.html
May have to decide on which “format”, probably “avc” and “hevc” (same as “AVCC in MP4”, which uses length-prefixed NALUs
TODO: For spatial layers, will WebCodecs give on chunk or N?
Do we support (metadata + payload) smaller than a frame, and if so, what metadata goes on each of those?
What metadata do we want on each frame? (timestamp + id + …)
How is “payload” + metadata serialized? (Protobuf vs. CBOR)
CBOR is viable; just define list of (id, type)
Another thing we could do: define our own TLV using QUIC base types?
With e2ee, What metadata is exposed to routers/server and which is encrypted and only seen by endpoints?
For SVC, is it 1 frame or N?  Update: for WebCodecs, it will be N frames (AKA EncodedVideoChunks)
~~~~

~~~~
hbhauth		e2eau		e2ee
[object_header][payload metadata][payload]
Object header
	Priority (8) = 6 bits of appln defined priorty , X , is_discardable
360p 30 60
720p 30 60
Smoother 360p 30
Lsb = tid 0/1
Next bit = 0
Priorrt = 00, 01

Payload Metadata

Encoding Timestamp in microseconds
Sequence
Audio level header
{
 Registry entry and value
  Tid , T:int
}
[Framemarking] - idr,is_discardable, tid, layer_id
[rotation]
Container Format
	Payload is web codec (does it do for audio as well ??)
	Payload is encrypted using kesy from MLS and something like sframe	


Moq Transport Mapping
 	Seuence = ObjectId
	Idr = group boundary
~~~~



# Security Considerations

The validation procedures specified verify that a JWT came from a given issuer.
It doesn't veirfy that the issuer is authorative for the claimed attributes.
The client needs to verify that the issuer is trusted to assert the claimed
attributes.

# IANA Considerations {#iana}

todo



--- back

# Acknowledgements {#Acknowledgements}

TODO
