---
title: Low Overhead Media Container
abbrev: media container
docname: draft-mzanaty-moq-loc-03
category: info
submissiontype: IETF
ipr: trust200902
stand_alone: yes
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
  MoQTransport: I-D.ietf-moq-transport
  MoQCatalog: I-D.wilaw-moq-catalogformat
  Framemarking: I-D.ietf-avtext-framemarking
  SecureObjects:
    title: "Secure Objects for Media over QUIC"
    target: https://suhashere.github.io/moq-secure-objects/#go.draft-jennings-moq-secure-objects.html
  MOQ-MLS:
    title: "Secure Group Key Agreement with MLS over MoQ"
    target: https://suhashere.github.io/moq-e2ee-mls/draft-jennings-moq-e2ee-mls.html
  WebCodecs:
    title: "WebCodecs"
    date: July 2023
    target: https://www.w3.org/TR/webcodecs/
  WEBCODECS-CODEC-REGISTRY:
    title: "WebCodecs Codec Registry"
    date: July 2023
    target: https://www.w3.org/TR/webcodecs-codec-registry/

informative:


--- abstract

This specification describes a media container format for
encoded and encrypted audio and video media data to be used
primarily for interactive Media over QUIC transport (MOQ),
with the goal of it being a low-overhead format. It also defines the
LOC Streaming Format for the MOQ Common Catalog format
for publishers to annouce and describe their LOC tracks and for
subscribers to consume them.

--- middle

# Introduction

This specification describes a low-overhead media container format for
encoded and encrypted audio and video media data to be used
primarily for interactive Media over QUIC transport (MOQT) {{MoQTransport}},
with the goal of it being a low-overhead format. It also defines the
LOC Streaming Format for the MOQ Common Catalog format {{MoQCatalog}}
for publishers to annouce and describe their LOC tracks and for
subscribers to consume them.

"Low-overhead" refers to minimal extra encapsulation as well as minimal application overhead when interfacing with WebCodecs {{WebCodecs}}.

The container format description is specified for all audio and video codecs defined in the
WebCodecs Codec Registry {{WEBCODECS-CODEC-REGISTRY}}.
The audio and video payload bitstream is identical to the "internal data"
inside an EncodedAudioChunk and EncodedVideoChunk, respectively, specified in the registry.

In addition to the media payloads, critical metadata is also specified for audio and video payloads.
(Note: Align with MOQT terminology of either "metadata" or "header".)

A primary motivation is to align with media formats used in WebCodecs to minimize
extra encapsulation and application overhead when interfacing with WebCodecs.
Other container formats like CMAF or RTP would require
more extensive application overhead in format conversions, as well as larger encapsultion overhead
which may burden some use cases like low bitrate audio scenarios.

This specification can also be used by applications outside the context of WebCodecs or a web browser.
While the media payloads are defined by referring to the "internal data" of an
EncodedAudioChunk or EncodedVideoChunk in the WebCodecs Codec Registry, this "internal data"
is the elementary bitstream format of codecs without any encapsulation. Referring to the WebCodecs
Codec Registry avoids duplicating it in an identical IANA registry.

* {{payload}} defines the core media payload formats.

* {{headers}} defines the metadata associated with audio and video payloads.

* {{catalog}} describes the LOC Streaming Format bindings to the MoQ Common Catalog format including examples.


## Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED",
"MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{!RFC2119}} {{!RFC8174}} when, and only when, they
appear in all capitals, as shown here.

## Terminology

TODO

# Payload Format {#payload}

The WebCodecs Codec Registry defines the contents of an EncodedAudioChunk and
EncodedVideoChunk for the audio and video codec formats in the registry. The
"internal data" in these chunks is used directly in this specification as
the "LOC Payload" bitstream. This "internal data" is the elementary bitstream format
of each codec without any encapsulation.

For video formats with multiple bitstream formats in the WebCodecs Registry, such as H.264/AVC or H.265/HEVC, the LOC Payload uses the "canonical" format ("avcc" or "hevc", not "annexB") with the following additions:
* Parameter sets are sent in the bitstream before key frames.
* 4 byte lengths are sent before each NAL Unit.
* No start codes or emulation prevention are used in the bitstream.
* No additional codec configuration information ("extradata") is needed.

## MOQ Object Mapping

An application object when transported as a {{MoQTransport}} object is composed of a MOQ Object Header
and its Payload. Media objects encoded using the container format defined in this
specification populate the MOQ Object Payload with a LOC Header and LOC Payload as shown below.

The LOC Payload is the "internal data" of an EncodedAudioChunk or EncodedVideoChunk.

~~~ ascii-art

+--------------+----------+-----------+
|  MOQ Object  |  LOC     |  LOC      |
|  Header      |  Header  |  Payload  |
+--------------+----------------------+
               <---------------------->
                  MOQ Object Payload

                  MOQ Object with LOC Container

~~~

## LOC Header Metadata {#headers}

The LOC Header carries metadata for the corresponding LOC Payload.
This metadata provides necessary information for intermediaries such as media switches to
perform their media switching decisions
when the payload is inaccessible due to encryption.

Section {{reg}} provides a framework for registering new LOC Header fields that aren't
defined by this specification.

### Common Header Data

The following metadata MUST be captured for each media frame.

Sequence Number: Identifies a sequentially increasing variable length integer that is
incremented per encoded media frame. This may be replaced with the Object Sequence
from the MOQ Object Header in cases where a MOQ Object is exactly one frame.

Capture Timestamp in Microseconds: Captures the wall-clock time of the encoded media frame in a 64-bit unsigned integer.

### Video Header Data

Flags for frames which are independent, discardable, or base layer sync
points, as well as temporal and spatial layer
identification. {{Framemarking}} .

### Audio Header Data

Audio Level: Captures the magnitude of the audio level of the corresponding audio frame encoded in 7 bits as defined in section 3 of {{!RFC6464}}.

### Header Data Registration {#reg}

This section details the procedures to register header data fields that might be useful for a
particular class of media applications.

Registering a given metadata field requires the following attributes to be specified.

Shortname: Short name for the metadata. (Not sent on the wire.)

Description: Detailed description for the metadata. (Not sent on the wire.)

ID: Identifier assigned by the registry. (varint)

Length: Length of metadata value in bytes. (varint)

Value: Value of metadata. (length bytes)

Registration of type "Specification Required" is followed for registering
new metadata in the LOC Header.


# Catalog {#catalog}

A catalog is a MOQT Object that provides information about tracks from a given publisher. A catalog is used by subscribers for consuming tracks and by publishers
to advertise and describe the tracks. The content of a catalog is opaque to the relays and may be end to end encrypted. A catalog describes the details of tracks such as Track IDs and corresponding media configuration details, for example, audio/video codec details.

The LOC Streaming Format uses the MoQ Common Catalog Format {{MoQCatalog}} to describe the content being produced by a publisher.

Per Sect 5.1 of {{MoQCatalog}}, this document registers an entry in the "MoQ Streaming Format Type" table, with the type value 2, the name "LOC Streaming Format", and the RFC XXX.

Every LOC catalog track MUST declare a streaming format type (See Sect 3.2.1 of {{MoQCatalog}}) value of 2.

Every LOC catalog track MUST declare a streaming format version (See Sect 3.2.1 of {{MoQCatalog}}) value of 1, which is the version described in this document.

Every LOC catalog track MUST declare a packaging type (See Sect 3.2.9 of {{MoQCatalog}}) of "loc".

The catalog track MUST have a track name of "catalog". A catalog object MAY be independent of other catalog objects or it MAY represent a delta update of a prior catalog object. The first catalog object published within a new group MUST be independent. A catalog object SHOULD only be published only when the availability of tracks changes.

Each catalog update MUST be mapped to a discreet moq-transport object.


## Catalog Fields

The MOQ Common Catalog defines the required base fields and optional extensions.

### Optional Extensions for Video

The LOC Streaming Format allows the following optional extensions for video media.

* temporalId: Identifies the temporal layer/sub-layer encoded, starting with 0 for the base layer, and increasing with higher temporal fidelity.

* spatialId: Identifies the spatial and quality layer encoded, starting with 0 for the base layer, and increasing with higher fidelity.

* depends: Identifies track dependencies for a given track, usually for video media with scalable layers in separate tracks.

* renderGroup: Identifies a group of time-aligned tracks which should be rendered simultaneously.

* selectionParams: Selection parameters for media quality, fidelity, etc.; see next section.

### Selection Parameters for Video {#profile}

Each video track can have the following associated Selection Parameters.

* codec: Codec information (including profile, level, tier, etc.), as defined by the codec registrations listed in {{WEBCODECS-CODEC-REGISTRY}}.

* framerate: As defined in section 7.8 of {{WEBCODECS-CODEC-REGISTRY}}.

* bitrate: As defined in section 7.7 and 7.8 of {{WEBCODECS-CODEC-REGISTRY}}.

* width, height: As defined in section 7.8 of {{WEBCODECS-CODEC-REGISTRY}}.

* displayWidth, displayheight: As defined in section 7.7 of {{WEBCODECS-CODEC-REGISTRY}}.

### Optional Extensions for Audio

The LOC Streaming Format allows the following optional extensions for audio media.

* renderGroup: Identifies a group of time-aligned tracks which should be rendered simultaneously.

* selectionParams: Selection parameters for media quality, fidelity, etc.; see next section.

### Selection Parameters for Audio {#audioprofile}

Each audio track can have the following associated Selection Parameters.

* codec: Codec information as defined by the codec registrations listed in {{WEBCODECS-CODEC-REGISTRY}}.

* bitrate: As defined in section 7.7 and 7.8 of {{WEBCODECS-CODEC-REGISTRY}}.

* samplerate: As defined in section 7.7 of {{WEBCODECS-CODEC-REGISTRY}}.

* chanelConfig: As defined in section 7.7 of {{WEBCODECS-CODEC-REGISTRY}}.

* lang: The primary language of the track, using standard tags from {{!RFC5646}}.


## Catalog Examples

See section 3.4 of the MOQ Common Catalog {{MoQCatalog}}.


# Payload Encryption

When end to end encryption is supported, the encoded payload is encrypted
with symmetric keys derived from key establishment mechanisms, such as {{MOQ-MLS}}, and the payload itself is protected using mechanisms defined in {{SecureObjects}}.

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


# Security Considerations

TODO

# IANA Considerations {#iana}

A new IANA registry for LOC Header Metadata is defined and populated with the information in section {{reg}}. Specification required for new metadata registration.

This document creates a new entry in the "MoQ Streaming Format" Registry (see {{MoQTransport}} Sect 8). The type value is 0x002, the name is "LOC Streaming Format" and the RFC is XXX.

--- back

# Acknowledgements {#Acknowledgements}

Thanks to Cullen Jennings for suggestions and review.
