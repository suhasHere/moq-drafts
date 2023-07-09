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
  MOQT:
    title: "Media over QUIC Transport"
    date: May 2023
    target: https://datatracker.ietf.org/doc/draft-lcurley-moq-transport/
    authors:
      - ins: L. Curley
        name: Luke Curley
        org: Twitch
      - ins: K. Pugin
        name: Kiril Pugin
        org: Meta
      -
        ins: S. Nandakumar
        name: Suhas Nandakumar
        org: Cisco Systems
      -
        ins: V. Vasiliev
        name: Victor Vasiliev
        org: Google
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
  WEBCODECS-CODEC-REGISTRY:
    title: "Frame Marking RTP Header Extension"
    date: November 2021
    target: https://www.w3.org/TR/webcodecs-codec-registry/

informative:


--- abstract

This specification describes a media container format for
encoded and encrypted audio and video media data to be used
primilarily for interactive media usecases, with the goal of it being
a low overhead format. It also defines the MOQ Catalog format for publishers
to annouce their tracks and for subscribers to consume the same.

--- middle

# Introduction

This specification describes a low-overhead media container format for
encoded and encrypted audio and video media data. "Low-overhead" refers to minimal extra
encapsulation as well as minimal application overhead when interfacing with WebCodecs.

The container format description is specified for all audio and video codecs defined in the
WebCodecs Codec Registry. The audio and video payload bitstream is identical to the internal data
inside an EncodedAudioChunk and EncodedVideoChunk, respectively, specified in the registry.

In addition to the media payloads, critical metadata is also specified for audio and video payloads.

A primary motivation is to align with media formats used in WebCodecs to minimize application
overhead when interfacing with WebCodecs. Other container formats like CMAF or RTP would require
more extensive application overhead in format conversions, as well as larger encapsultion overhead
which may burden some use cases like low bitrate audio scenarios.

TODO: Add details on the sections

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
the payload bitstream.

An application object when transported as {!MOQT} object is composed of a header
and its payload. Media objects encoded using the container format defined in this
specification is shows as below, where in, the `MOQT Object's payload` is composed of
Loc Payload Header {{headers}} and encoded audio/video media that matches the
WebCodec EncodedAudioChunk and EncodedVideoChunk encodings respectively.

~~~ ascii-art

+----------------------+----------------+----------------------+
|   MOQ Object Header  |   LOC Payload  |  EncodedAudioChunk/  |
|                      |   Header       |  EncodedVideoChunk   |
+----------------------+----------------+----------------------+
                        <-------------------------------------->
                                       MOQ Object Payload

                  MOQ Object with LOC Container

~~~

# Payload Header Data {#headers}

This section specified metadata that needs to be carried out as payload metadata. Payload
header data provides necessary information for intermediaries to perform switching decisions
when the payload is inaccessible, due to encryption.

Section ((#reg)) provides framework for registering  new payload header fields that aren't
defined by this specification

## Common Header Data

Following metadata MUST be captured for each media frame

Sequence Number: Identifies a sequentially increasing variable length integer that is
incremented per encoded media frame.

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

Audio Level: captures the magnitude of the audio level of the corresponding audio frame and
values in encoded in 7 bits as defined in the section 3 of {{!RFC6464}}

## Header Data Registration {#reg}

This section details the procedures to register header data fields that might be useful for a
particular class of media applications.

Registering a given metadata field requires the following attributes to be specified.

Shortname: Short name for the metadata. (Not sent on the wire.)

Description: Detailed description for the metadata. (Not sent on the wire.)

ID: Identifier assigned by the registry. (varint)

Length: Length of metadata value in bytes. (varint)

Value: Value of metadata. (length bytes)

Registration of type "Specification Required" is followed for registering
new for header data values.


# Catalog

A Catalog is a MOQT Object that provides information about tracks from a given
publisher. Catalog is used by subscribers for consuming tracks and for publishers
to advertise the tracks. The content of "Catalog" is opaque to the Relays and may
be end to end encrypted. Catalog provides the details of tracks such as Track IDs
and corresponding media configuration details (audio/video codec detail,
gamestate encoding details,for example).

## Catalog Fields

At the minumum catalog MUST provide enough information about MOQ Tracks, such as
its identifier, information about media for the track, for the consumers to
make appropriate subscription decisions. Following subsections identify
the mandatory `base` fields and optional `extensions` fields that describe
a given publisher's track in the catalog.

### Base Fields

This section identifies the mandatory fields needs to be defined per track listed in the catalog.

* Track Namespace: See section 2.3 of {{MOQT}}
* Track Name: See section 2.3 of {{MOQT}}
* Track Qualiity Profile: See {{profile}}
* Relation: See {{relations}}

Table 1 provides an overview of all base fields defined by this
document.

| Name            | Label | Media Type | JSON Type |
|:================|:======|:===========|:==========|
| Track Namespace | ns    |  AV        |   String  |
| Track Name      | tn    |  AV        |   String  |
| QualityProfile  | qp    | See {{profile}}        |
| Relation        | rel   | See {{relations}}      |

### Extension Fields

* Temporal ID: TODO

* Spatial ID: TODO

* Depend: TODO



Table 2 provides label and type identification for
the extension fields


| Name            | Label | Media Type | JSON Type |
|:================|:======|:===========|:==========|
| Temporal ID     | tid    |  V        |   String  |
| Spatial ID      | lid    |  V        |   String  |
| Depend          | dep    |  V        |   Array   |


TODO: Define a TLV strucuture.

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

For details of the JSON representation, see Section {{json}}; for
Raw binary, see Section {{binary}}.

TODO: Define CBOR encoding.

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
  sync for playout in a conference setting.

* layered: Indicates tracks are dependent via layered encoding
  and applies to video tracks. Each track that is part of the
  layered relation set MUST include depend quality profile
  property except the base layer.


CMAF defines the following logical media objects:

CMAF track, which contains encoded samples of media, such as video, audio, and subtitles, with a CMAF header and fragments. The samples are stored in a CMAF-specified container based on the ISO Base Media File Format (ISO BMFF). You can also protect media samples by means of MPEG Common Encryption (COMMON ENC).

CMAF switching set, which contains alternative tracks with different resolutions and bitrates for adaptive streaming, which you can splice in at the boundaries of CMAF fragments.

Aligned CMAF switching set, which contains switching sets from the same source through alternative encodings (e.g., with different codecs), which are time-aligned to one another.

CMAF selection set, which contains switching sets in the same media format. That format might contain different content, such as alternative camera angles or languages; or different encodings, such as alternative codecs.

CMAF presentation, which contains one or more presentation time-synchronized selection sets.


## Catalog Retrieval

On a successful connection setup, subscribers proceed by retrieving the
catalog (if not already retrieved), subscribing to the tracks of
their interest and consuming the data published as detailed below.


Catalogs are identifed as a special track, with its `Track Name` as "catalog".
Catalog objects are retrieved by subscribing to its `Full Track Name`  over
its own MoQ control channel. I

A successfull subscription will lead to one or more catalog
objects being published on a single unidirectional data stream.
Successfull subscriptions implies authorization for subscribing
to the tracks in the catalog.

Unsuccessful subscriptions MUST result in closure of the
Moqsession, followed by reporting the error obtained
to the application.

Catalog Objects obtained MUST parse successfully, otherwise
MUST be treated as error, thus resulting the closure of the
WebTransport session.


# Catalog Encoding

## JSON Representation {#json}

TODO

```
{

 "publications": [
  {
    mediaType: "video",
    trackNamespace: "track-namespace",
    trackName: "main-audio",
    "qualityProfile": "codec=av01.0.08M.10.0.110.09,width=1920,height=1080,framerate=30,br=100"
  },
 ],
}

```


## Raw Binary Representation {#binary}

TODO

```
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
```



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



# MOQ Transport Mapping

TODO

# Security Considerations

TODO

# IANA Considerations {#iana}

TODO on specification required for metadata registration.

--- back

# Acknowledgements {#Acknowledgements}

Thanks to Cullen Jennings for suggestions and review.
