---
title: "Catalog Specification for MoQ compliant streaming formats"
abbrev: "catalog moq"
category: info

docname: draft-nandakumar-moq-catalog-latest
submissiontype: IETF
number:
date:
consensus: true
v: 3
area: "RAI"
workgroup: "Media Over QUIC"
venue:
  group: "Media Over QUIC"
  type: "Working Group"
  mail: "moq@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/moq/"
  github: "suhasHere/moq-catalog"

author:
 -
    fullname: Suhas Nandakumar
    organization: Cisco
    email: snandaku@cisco.com

 -
    fullname: Will Law
    organization: Akamai
    email: wilaw@akamai.com

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
  CMAF:
    title: "Information technology -- Multimedia application format (MPEG-A) -- Part 19: Common media application format (CMAF) for segmented media"
    date: 2020-03
informative:


--- abstract

Media over QUIC Transport (MOQT) defines a publish/subscribe based unified media delivery protocol for delivering media for streaming and interactive applications over QUIC. This specification defines an interoperable Catalog specification for streaming formats implementing the MOQ Transport Protocol.

--- middle

# Introduction

MOQT [MOQTransport] defines a media transport protocol that utilizes the QUIC network protocol [QUIC] and WebTransport[WebTrans] to move objects between publishers, subscribers and intermediaries. Track IDs are used to identify available tracks.  The mapping of media characteristics to objects, as well as relative prioritization of those objects, is defined by a separate MoQ Streaming Format specification. Each streaming format identifies c Multiple streaming formats can operate concurrently over MoQT protocol. This document specifies
 normative requirements for these catalog definitions to ensure their compatibility across networks implementing the MoQ Base Protocol.

This specification defines JSON encoded Catalog.

* {{catalog}} describes the MoQ Catalog format including examples.

# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 [RFC2119].

## Terminology

TODO

# Catalog {#catalog}

A Catalog is a MOQT Object that provides information about tracks from a given publisher. Catalog is used by subscribers for consuming tracks and for publishers
to advertise the tracks. The content of "Catalog" is opaque to the Relays and may be end to end encrypted. Catalog provides the details of tracks such as Track IDs and corresponding media configuration details (audio/video codec detail, gamestate encoding details, for example)

## Catalog Fields

At the minumum catalog MUST provide enough information about MOQ Tracks, such as its full name, information about media for the track and mode of usage of the underlying QUIC transport. Following subsections identify the mandatory {{base}} fields and optional {{extensions}} fields that describe a given publisher's track in the catalog. The applications is free to add further fields to the catalog that is deemed necessary than the ones defined in this specification and they don't need to be standardized.

TODO: Describe mechanics for preventing field name conflicts for future extensions and for application specific extensions.

### Base Fields {#base}

This section identifies the mandatory fields needs to be defined per track listed in the catalog.

* Track Namespace: See section 2.3 of {{MoQTransport}}
* Track Name: See section 2.3 of {{MoQTransport}}
* Track Quality Profile: See {{profile}}
* Track Operation: see {operations}
* Relation: See {{relations}}


Table 1 provides an overview of all base fields defined by this
document.

| Name            | Label | Media Type | JSON Type |
|:================|:======|:===========|:==========|
| Track Namespace | ns    |  AV        |   String  |
| Track Name      | tn    |  AV        |   String  |
| Track Priority  | p     |  AV        |   Number  |
| Track Operation | op    |  AV        |   Number  |
| QualityProfile  | qp    | See {{profile}}        |

### Extension Fields {#extensions}

Following optional extension fields may be supported by the application.

* Temporal ID: Identifies the temporal layer/sub-layer encoded, starting with 0 for the base layer, and increasing with higher temporal fidelity.

* Spatial ID: Identifies the spatial and quality layer encoded, starting with 0 for the base layer, and increasing with higher fidelity.

* Depend: Identifies track dependencies for a given track.

* InitData : See {{init-data}}.

* Relation: See {{relations}}.


Table 2 provides label and type identification for
the extension fields

| Name            | Label | Media Type | JSON Type |
|:================|:======|:===========|:==========|
| Temporal ID     | tid    |  V        |   String  |
| Spatial ID      | lid    |  V        |   String  |
| Depend          | dep    |  V        |   Array   |
| Init Data       |         See {{init-data}}      |
| Relation        |         See {{relations}}      |


### Track Operations {#operations}

Each track description can specify an optional operation value that identifies
the catalog producer's intent. Track operation is a enumeration of values
as defined below.

* Add: Indicates the track is added to the catalog and the consumers of the
 catalog can start consuming the media by subscribing to the track.

* Delete: Indicates that media producder is no longer producing media on the
associated track. Subscribers MUST cleanup any local resources for the
track and discard any media received on the track with this operation.

Folowing table defines the numerica values for the track operations.

| Name            | Value |
|:================|:======|
| Add             | 1     |
| Delete          | 2     |

Section XXX specifices IANA registration procedures for the same.

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

* simulcast: Indicates set of tracks that share the same time
  offset when producing the media as well as considered as
  having same time offset when consuming the media. Typical
  example would be simulcasting a camera capture across multiple
  encoding qualities.

* time-aligned: Indicates a synchronized playout of the media
  from the tracks identified. Example audio and video media
  synced for playout in a conference setting.

* layered: Indicates tracks are dependent via layered encoding
  and applies to video tracks. Each track that is part of the
  layered relation set MUST include `depend` field listing the
  dependencies.


Table 4 lists relation fields defined by this
document with their respective labels, applicable media types and data types.


| Name          | Label | Media Type | JSON Type |
|:==============|:======|:===========|:==========|
| time-aligned  | ta    |  AV        |   Array   |
| layered       | ly    |  V         |   Number  |
| simulcast     | sim    |  V       |   Array  |


## Track Init Data {#init-data}

| Name          | Label | Media Type | JSON Type |
|:==============|:======|:===========|:==========|
| init-data     | init    |  AV      |   Array   |


* init-data: The init payload MUST consist of a File Type Box (ftyp) followed by a Movie Box (moov). This Movie Box (moov) consists of Movie Header Boxes (mvhd), Track Header Boxes (tkhd), Track Boxes (trak), followed by a final Movie Extends Box (mvex). These boxes MUST NOT contain any samples and MUST have a duration of zero. A Common Media Application Format Header {{CMAF}} meets all these requirements.


## Catalog Retrieval

On a successful connection setup, subscribers proceed by retrieving the
catalog (if not already retrieved), subscribing to the tracks of
their interest and consuming the data published as detailed below.

Catalogs are identified as a special track, with its `Track Name` as "catalog".
Catalog objects are retrieved by subscribing to its `Full Track Name`  over
its own MoQ control channel (Bidirectional QUIC Stream). I

A successful subscription will lead to one or more catalog
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

  "ta": ["audio", "video"],
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

  "sim": ["hd", "sd", "md"],
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


# Security Considerations

The catalog payload type header MUST NOT be encrypted. The catalog payload body MAY be encrypted.

# IANA Considerations {#iana}

This section details how the Type of the Catalog format that can be registered.  The type registry can be updated by incrementally expanding the type space, i.e., by allocating and reserving new type identifiers.  As per [RFC8126], this section details the creation of the "MoQ Base Protocol Catalog Type" registry.

## Catalog Type Registry

This document creates a new registry, "MoQ Base Protocol Catalog Type".  The registry policy is "RFC Required".  The Type value is 2 octets.  The range is 0x0000-0xFFFF. The initial entry in the registry is:

         +--------+-------------+----------------------------------+
         | Type   |     Name    |            RFC                   |
         +--------+-------------+----------------------------------+
         | 0x0000 |   Reserved  |                                  |
         +--------+-------------+----------------------------------+



# Acknowledgments
{:numbered="false"}

The IETF MoQ mailing lists and discussion groups.
