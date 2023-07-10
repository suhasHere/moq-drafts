---
title: Low Overhead Media Container
abbrev: media container
docname: draft-mzanaty-moq-loc-latest
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
  Framemarking: I-D.ietf-avtext-framemarking
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
primarily for interactive Media over QUIC Transport (MOQT) {{MoQTransport}}, 
with the goal of it being a low-overhead format. It also defines the
MOQ Catalog format for publishers to annouce their tracks and for
subscribers to consume them.

--- middle

# Introduction

This specification describes a low-overhead media container format for
encoded and encrypted audio and video media data, as well as a MOQ Catalog format to describe such tracks.

"Low-overhead" refers to minimal extra
encapsulation as well as minimal application overhead when interfacing with WebCodecs {{WebCodecs}}.

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

* {{catalog}} describes the MoQ Catalog format including examples.


## Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD","SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{!RFC2119}}.

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

A Catalog is a MOQT Object that provides information about tracks from a given publisher. Catalog is used by subscribers for consuming tracks and for publishers
to advertise the tracks. The content of "Catalog" is opaque to the Relays and may be end to end encrypted. Catalog provides the details of tracks such as Track IDs and corresponding media configuration details (audio/video codec detail, gamestate encoding details, for example)

## Catalog Fields

At the minumum catalog MUST provide enough information about MOQ Tracks, such as its full name, information about media for the track and mode of usage of the underlying QUIC transport. Following subsections identify the mandatory {{base}} fields and optional {{extensions}} fields that describe a given publisher's track in the catalog. However, the application is free to add further fields than the ones defined in this specification.

### Base Fields {#base}

This section identifies the mandatory fields needs to be defined per track listed in the catalog.

* Track Namespace: See section 2.3 of {{MoQTransport}}
* Track Name: See section 2.3 of {{MoQTransport}}
* Track Qualiity Profile: See {{profile}}
* Relation: See {{relations}}

Table 1 provides an overview of all base fields defined by this
document.

| Name            | Label | Media Type | JSON Type |
|:================|:======|:===========|:==========|
| Track Namespace | ns    |  AV        |   String  |
| Track Name      | tn    |  AV        |   String  |
| QualityProfile  | qp    | See {{profile}}        |

### Extension Fields {#extensions}

Following optional extension fields may be supported by the applocation.

* Temporal ID: Identifies the temporal layer/sub-layer encoded, starting with 0 for the base layer, and increasing with higher temporal fidelity.

* Spatial ID: Identifies the spatial and quality layer encoded, starting with 0 for the base layer, and increasing with higher fidelity.

* Depend: Identifies track dependencies for a given track.

* Relation: See {{relations}}.


Table 2 provides label and type identification for
the extension fields

| Name            | Label | Media Type | JSON Type |
|:================|:======|:===========|:==========|
| Temporal ID     | tid    |  V        |   String  |
| Spatial ID      | lid    |  V        |   String  |
| Depend          | dep    |  V        |   Array   |
| Relation        | rel   | See {{relations}}      |



### Track Quality Profile {#profile}

Each track has an associated quality profile that describes the
media objects for that track. Following properties identify
a track's quality profile.

* Codec: Codec information as defined by the codec registrations listed in {{WEBCODECS-CODEC-REGISTRY}}.

* Framerate: As defined in section 7.8 of {{WEBCODECS-CODEC-REGISTRY}}.

* Bitrate: As defined in section 7.7 and 7.8 of {{WEBCODECS-CODEC-REGISTRY}}.

* SampleRate: As defined in section 7.7 of {{WEBCODECS-CODEC-REGISTRY}}.

* Width,Height: As defined in section 7.8 of {{WEBCODECS-CODEC-REGISTRY}}.

* ChanelCount: As defined in section 7.7 of {{WEBCODECS-CODEC-REGISTRY}}.

* DisplayWidth, DisplayHeight: As defined in section 7.7 of {{WEBCODECS-CODEC-REGISTRY}}.

Table 3 provides an overview of all QualityProfile fields defined by this
document with their respective labels, applicable media types and data types.

| Name          | Label | Media Type | JSON Type |
|:==============|:======|:===========|:==========|
| Codec         | cs    |  AV        |   String  |
| Framerate     | fr    |  V         |   Number  |
| Bitrate       | br    |  AV        |   Number  |
| Width         | wd    |  V         |   Number  |
| Height        | ht    |  V         |   Number  |
| SampleRate    | sr    |  A         |   Number  |
| ChanelCount   | cc    |  A         |   Number  |
| DisplayWidth  | dw    |  V         |   Number  |
| DisplayHeight | dh    |  V         |   Number  |


### Track Relations {#relations}

Tracks can express dependency on other tracks via relations
property. Following relation types are defined in this document.

* time-aligned: Indicates set of tracks that share the same time
  offset when producing the media as well as considered as
  having same time offset when consuming the media. Typical
  example would be simulcasting a camera capture across multiple
  encoding qualities.

* lip-sync: Indicates a synchronized playout of the media
  from the tracks identified. Example audio and video media
  synced for playout in a conference setting.

* layered: Indicates tracks are dependent via layered encoding
  and applies to video tracks. Each track that is part of the
  layered relation set MUST include `depend`field listing the 
  dependencies.


Table 4 lists relation fields defined by this
document with their respective labels, applicable media types and data types.


| Name          | Label | Media Type | JSON Type |
|:==============|:======|:===========|:==========|
| lip-sync      | ls    |  AV        |   Array   |
| layered       | ly    |  V         |   Number  |
| time-aligned  | ta    |  AV        |   Number  |



## Catalog Retrieval

On a successful connection setup, subscribers proceed by retrieving the
catalog (if not already retrieved), subscribing to the tracks of
their interest and consuming the data published as detailed below.

Catalogs are identifed as a special track, with its `Track Name` as "catalog".
Catalog objects are retrieved by subscribing to its `Full Track Name`  over
its own MoQ control channel (Bidirectional QUIC Stream). I

A successfull subscription will lead to one or more catalog
objects being published and implies authorization for subscribing
to the tracks in the catalog.

Unsuccessful subscriptions MUST result in closure of the
MOQT session, followed by reporting the error obtained
to the application.

Catalog Objects obtained MUST parse successfully, otherwise
MUST be treated as error, thus resulting the closure of the
WebTransport session.


## Catalog Examples

The following section provides JSON examples of the catalog. 

### Lip Sync Audio/Video Tracks with single quality

This example shows catalog for the media sender, Alice, capable 
of sending audio and video tracks and share lip-sync relation. 

~~~json
{

  "ls": ["audio", "video"],
  [
    {
      "ns": "conference.example.com/conference123/alice",
      "n": "video",
      "qp": "cs=av01.0.08M.10.0.110.09,wd=1920,ht=1080,fr=30"
    },
    {
      "ns": "conference.example.com/conference123/alice",
      "n": "audio",
      "qp": "cs=opus,sr=48000,cc=2"
    }
 ],
}

~~~


### Simulcast video tracks - 3 qualities

This example shows catalog for the media sender, Alice, capable 
of sending 3 video tracks for high definition, low definition and 
medium definition qualities in time-aligned relation.


~~~json
{

  "ta": ["hd", "sd", "md"],
  [
    {
      "ns": "conference.example.com/conference123/alice",
      "n": "hd",
      "qp": "cs=av01,wd=1920,ht=1080,fr=30"
    },
    {
      "ns": "conference.example.com/conference123/alice",
      "n": "md",
      "qp": "cs=av01,wd=720,ht=640,fr=30"
    },
    {
      "ns": "conference.example.com/conference123/alice",
      "n": "sd",
      "qp": "cs=av01,wd=192,ht=144,fr=30"
    }
 ],
}

~~~

# Payload Encryption

When end to end encryption is supported, the encoded payload is encrypted
with keys from symmetric keying mechanisms, such a MLS, and the payload itself is protected using SFrame or other schemes similar schemes.

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

--- back

# Acknowledgements {#Acknowledgements}

Thanks to Cullen Jennings for suggestions and review.
