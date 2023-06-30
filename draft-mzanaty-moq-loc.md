---
title: Low Overhead Media Container
abbrev: media container
docname: draft-mzanaty-moq-loc-latest
category: info
submissiontype: IETF
ipr: trust200902
submissionType: info
author:
-
    fullname: Mo Zanaty
    organization: Cisco
    email: mzanaty@cisco.com
-
    fullname: Suhas Nandakumar
    organization: Cisco
    email: snandaku@cisco.com
-
    fullname: Peter Thatcher
    organization: Microsoft
    email: pthatcher@microsoft.com
normative:
  Framemarking:
    title: "Frame Marking RTP Header Extension"
    date: November 2021
    target: https://datatracker.ietf.org/doc/draft-ietf-avtext-framemarking/
    authors:
      -
        ins: M. Zanaty
        name: Mo Zanaty
        org: Cisco Systems
      -
        ins: E. Berger
        name: Espen Berger
        org: Cisco Systems
      -
        ins: S. Nandakumar
        name: Suhas Nandakumar
        org: Cisco Systems

normative:
informative:


--- abstract

This specification describes a media container format for
encoded and encrypted audio and video media data to be used
for interactive media usecases, with the goal of it being
a low overhead format.

--- middle

# Introduction

This specification describes a low-overhead media container format for
encoded and encrypted audio and video media data. "Low-overhead" refers to minimal extra encapsulation as well as minimal application overhead when interfacing with WebCodecs.

The container format description is specified for all audio and video codecs defined in the WebCodecs Codec Registry. The audio and video payload bitstream is identical to the internal data inside an EncodedAudioChunk and EncodedVideoChunk, respectively, specified in the registry.

In addition to the media payloads, critical metadata is also specified for audio and video payloads.

A primary motivation is to align with media formats used in WebCodecs to minimize application overhead when interfacing with WebCodecs. Other container formats like CMAF or RTP would require more extensive application overhead in format conversions, as well as larger encapsultion overhead which may burden some use cases like low bitrate audio scenarios.

## Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD","SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in {{!RFC2119}}.

## Terminology

TODO

# Payload Format {#payload}

The WebCodecs Codec Registry defines the contents of an EncodedAudioChunk and EncodedVideoChunk for the audio and video codec formats in the registry. The "internal data" in these chunks is used directly in this specification as the payload bitstream.


# Payload Header Data

This section specified metadata that needs to be carried out as payload metadata. Payload header data provides necessary information for intermediaries to perform switching decisions when the payload is inaccessible, due to encryption.

Section ((#reg)) provides framework for registering  new payload header fields that aren't defined by this specification

## Common Header Data

Following metadata MUST be captured for each media frame

Sequence Number: Identifies a sequentially increasing variable length integer that is incremented per encoded media frame.

Capture Timestamp in Microseconds: Captures the wall-clock time of the encoded media frame.

## Video Header Data

Flags for frames which are independent, discardable, or base layer sync
points, as well as temporal and spatial layer
identification. {{!I-D.ietf-avtext-framemarking}} .

1. Does all the tracks go into same decoder or different decoder ?
   layered -> must go to the same decoder

2. Multiple tracks
    how are those mapped on encode side 
    how are these fed into the decoder

3. priority --> idr/not

4.how is group and object number set or intepreted by the middleboxes ( switches not relays)

5. Do we need extension mechanisms , like TLV ..

## Audio Header Data

Audio Level: captures the magnitude of the audio level of the corresponding audio frame and values in encoded in 7 bits as defined in the section 3 of {{!RFC6464}}

# Header Data Registration {#reg}

This section details the procedures to register header data fields that might be useful for a particular class of media applications.

Registering a given metadata field requires the following attributes to be specified.

Shortname: Short name for the metadata. (Not sent on the wire.)

Description: Detailed description for the metadata. (Not sent on the wire.)

ID: Identifier assigned by the registry. (varint)

Length: Length of metadata value in bytes. (varint)

Value: Value of metadata. (length bytes)

Registration of type "Specification Required" is followed for registering
new for header data values.

# Payload Encryption

When end to end encryption is supported, the encoded payload is encrypted
with keys from symmetric keying mechanisms, such a MLS, and the payload itself is protected using SFrame or equivalent.

# Container Serialization

The wire encoding of the payload conforming to this specification is
a set of length delimited values as shown below.

The Bytes is obtained as output of AEAD operation for encrypting the Payload
with the header data as additional data input.

~~~
+--------+------------+-------+------------+
| Payload | Bytes | Payload  | Bytes |
| Len     |  (0)  | Len (1)  |  (1)  | ...
+--------+------------+-------+------------+
~~~



# Catalog

Catalog is a MOQT Object scoped to a MoQ Session {{session}} that
provides information about tracks from a given publisher and
is used by the subscribers for consuming tracks and for publishers
to advertise the tracks. The content of "Catalog" is opaque to the
Relays and may be end to end encrypted in certain scenarios.


## Catalog Retrieval

On a successful connection setup, subscribers proceed by retrieving the
catalog (if not already retrieved), subscribing to the tracks of
their interest and consuming the data published as detailed below.

Catalog provides the details of tracks such as Track IDs and corresponding
configuration details (audio/video codec detail, gamestate encoding details,
for example).

Catalogs are identifed as a special track, with its track name as "catalog".
Catalog objects are retrieved by subscribing to its TrackID over
its own control channel and the TrackID is formed as shown below

~~~
Catalog TrackID := <provider-domain>/<moq-session-id>/catalog

Ex: streaming.com/emission123/catalog
~~~

A successfull subscription will lead to one or more catalog
objects being published on a single unidirectional data stream.
Successfull subscriptions implies authorizaiton for subscribing
to the tracks in the catalog.

Unsuccessful subscriptions MUST result in closure of the
WebTransport session, followed by reporting the error obtained
to the application.

Catalog Objects obtained MUST parse successfully, otherwise
MUST be treated as error, thus resulting the closure of the
WebTransport session.


CATALOG payload {
  media format type (i), // 0x02
  version (i),
  parent object sequence (i), --> // replace this with group/object semantics
  track change count (i),
  track change descriptors (..)
}

Track Change Descriptor {
  full track name length (i),
  full track name (..),
  operation (1),
  relation(...), <layered, simulcast, lip-sync>
  codecConfig: webcodec's codec config
}

Extensions:
    track media container format
        default: container-less/loc
        options: cmaf

qualityprofile -> maximum decoder limits for a given codec and the quality being advertised.

TrackABC
Track123
    repalces: trackABC

# MOQ Transport Mapping

TODO

# Security Considerations

TODO

# IANA Considerations {#iana}

TODO on specification required for metadata registration.

--- back

# Acknowledgements {#Acknowledgements}

Thanks to Cullen Jennings for suggestions and review.
