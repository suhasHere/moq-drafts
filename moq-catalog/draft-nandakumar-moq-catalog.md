---
title: "Catalog Specification for Media Over QUIC Transport"
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

 -
    fullname: Mo Zanaty
    organization: Cisco
    email: mzanaty@cisco.com


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
  JSON: RFC8259
  BASE64: RFC4648
  LANG: RFC5646

informative:


--- abstract

Media over QUIC Transport (MOQT) defines a publish/subscribe based unified media delivery protocol for delivering media for streaming and interactive applications over QUIC. This specification defines an interoperable Catalog specification for streaming formats implementing the MOQ Transport Protocol [MOQTransport]. The Catalog describes the content made available by a publisher, including information necessary for track selection, subscription and initialization. 

--- middle

# Introduction

MOQT [MOQTransport] defines a transport protocol that utilizes the QUIC network protocol [QUIC] and WebTransport[WebTrans] to move objects between publishers, subscribers and intermediaries. Tracks are identified using a tuple of the the Track Namespace and the Track Name. A MOQT Catalog is a specialized track which captures details of all the tracks output by a publisher, including the identities, media profiles, initialization data and inter-track relationships. The mapping of media characteristics of objects with the tracks, as well as relative prioritization of those objects, are captured in separate MoQ Streaming Format specifications. This specification defines a JSON encoded catalog.

* {{catalog}} describes the MoQ Catalog format including examples.

# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 [RFC2119].


# Catalog {#catalog}

A Catalog is a MOQT Object that provides information about tracks from a given publisher. A Catalog is used by publishers for advertising their output and for subscribers to consume that output. The payload of the Catalog object is opaque to Relays and can be end-to-end encrypted. The Catalog provides the names and namespaces of the tracks being produced, along with the relationship between tracks, properties of the tracks that consumers may use for selection and any releavnt initialization data. 

## Catalog Fields

A catalog is a JSON [JSON] document, comprised of a series of mandatory and optional fields. At a minumum, a catalog MUST provide all mandatory fields. A producer MAY add additional fields to the ones described in this draft. Custom field names MUST NOT collide with field names described in this draft. To prevent custom field name collisions with future versions, custom field names SHOULD be prefixed using reverse domain name notation e.g "com.example-size". The order of field names within the JSON document is not important.

A parser MUST ignore fields it does not understand. 

Table 1 provides an overview of all fields defined by this document.

| Field                   |  Name  | Required |  Location |  JSON type |           Definition          |
|:========================|:=======|:=========|:==========|:===========|:==============================|
| Streaming format        | f      |  yes     |   R       |  Number    | See {#streamingformat}        |
| Streaming format version| v      |  yes     |   R       |  String    | See {#streamingformatversion} |
| Tracks                  | tracks |  yes     |   R       |  Array     | See {#tracks}                 |
| Parent sequence number  | psn    |  opt     |   R       |  Array     | See {#parentsequencenumber}   |
| Time-aligned            | ta     |  opt     |   R       |  Array     | See {#timealigned}            |
| Layered                 | ly     |  opt     |   R       |  Array     | See {#layered}                |
| Simulcast               | sim    |  opt     |   R       |  Array     | See {#simulcast}              |
| Track namespace         | ns     |  yes     |   RT      |  String    | See {#tracknamespace}         |
| Packaging               | p      |  yes     |   RT      |  String    | See {#packaging}              |
| Selection parameters    | sp     |  opt     |   RT      |  Object    | See {#selectionparameters}    |
| Track name              | n      |  yes     |   T       |  String    | See {#trackname}              |
| Track operation         | op     |  yes     |   T       |  Number    | See {#trackoperations}        |
| Track priority          | p      |  opt     |   T       |  Number    | See {#trackpriority}          |
| Track label             | lb     |  opt     |   T       |  String    | See {#tracklabel}             |
| Render group            | gr     |  opt     |   T       |  Number    | See {#rendergroup}            |
| Alternate group         | alt    |  opt     |   T       |  Number    | See {#altgroup}               |
| Initialization data     | ind    |  opt     |   T       |  String    | See {#initdata}               |
| Initialization track    | int    |  opt     |   T       |  String    | See {#inittrack}              |
| Temporal ID             | tid    |  opt     |   T       |  Number    | See {#temporalid}             |
| Spatial ID              | sid    |  opt     |   T       |  Number    | See {#spatialid}              |
| Codec                   | cs     |  opt     |   S       |  String    | See {#codec}                  |
| Framerate               | fr     |  opt     |   S       |  Number    | See {#framerate}              |
| Bitrate                 | br     |  opt     |   S       |  Number    | See {#bitrate}                |
| Width                   | wd     |  opt     |   S       |  Number    | See {#width}                  |
| Height                  | ht     |  opt     |   S       |  Number    | See {#height}                 |
| Samplerate              | sr     |  opt     |   S       |  Number    | See {#samplerate}             |
| Channel count           | cc     |  opt     |   S       |  Number    | See {#channelcount}           |
| Display width           | dw     |  opt     |   S       |  Number    | See {#displaywidth}           |
| Display height          | dh     |  opt     |   S       |  Number    | See {#displayheight}          |
| Language                | la     |  opt     |   S       |  String    | See {#language}               |


Required: 'yes' indicates a mandatory field, 'opt' indicates an optional field
Location: 'R' - the field is located in the root of the JSON object, 'T' - the field is located in a Track object,  'RT' - the field may be located in either the root or a track object, "S" - the field is located in the Selection Properties object.  

### Streaming format {#streamingformat}
A number indicating the streaming format type.  Every MoQ Streaming Format normatively referencing this catalog format MUST register itself in the "MoQ Streaming Format Type" table.  See {#iana} for additional details.  

### Streaming format version {#streamingformatversion}
A string indicating the version of the streaming format to which this catalog applies. The structure of the version string is defined by the streaming format. 

### Tracks {#tracks}
An array of track objects {#trackobject}

### Parent sequence number {#parentsequencenumber}
A number specifying the moq-transport object number from which this catalog represents a delta update. See {#deltaupdate} for additional details. Absence of this parent sequence number indicates that this catalog is independent and completely describes the content available in the broadcast. 

### Tracks object {#trackobject}
A track object is a collection of fields whose location is specified as 'T' or 'RT' in Table 1. 

### Track namespace {#tracknamespace}
The name space under which the track name is defined. See section 2.3 of {{MoQTransport}}. The track namespace is required to be specified for each track object. If the track namespace is declared in the root of the JSON document, then its value is inherited by all tracks and it does not need to be re-declared within each track object. A namesapce declared in a track object overwrites any inherited name sapce. 

### Packaging {#packaging}
A string defining the type of payload encapsulation. Allowed values are strings as defined in Table 2.

Table 2: Allowed packaging values

| Name            |   Value   |      Draft       |
|:================|:==========|:=================|
| CMAF            | "cmaf"    | See RFC XXXX     |
| LOC             | "loc"     | See RFC XXXX     |

### Track name {#trackname}
A string defining the name of the track. See section 2.3 of {{MoQTransport}}

### Track operations {#operations}

Each track description can specify an optional operation value that identifies
the catalog producer's intent. Track operation is a enumeration of values
as defined below.

* Add: Indicates the track is added to the catalog and the consumers of the
 catalog may subscribe to the track.

* Delete: Indicates that media producder is no longer producing media on the
associated track.

A catalog update in which all previously added tracks are deleted SHOULD be interpreted by a subscriber to indicate that the publisher has terminated the broadcast. 

Folowing Table 3 defines the numerical values for the track operations.

Table 3: Allowed track operations

| Name            | Value | Default value  |
|:================|:======|:===============|
| Add             | 1     |    yes         |
| Delete          | 0     |                |

The default track operation is 'Add'. This value does not need to be declared in the track object. 

### Track priority {#trackpriority}
A number indicating the relative priority of the track. See section X.X of {{MoQTransport}}.

### Track label {#tracklabel}
A string defining a human-readable label for the track. Examples might be "Overhead camera view" or "Deutscher Kommentar"

### Render group {#rendergroup}
An integer specifying a group of tracks which are designed to be rendered together. Tracks with the same group number SHOULD be rendered simultaneously and are designed to accompmnay one another. A common example would be tying together audio and video tracks. 

### Alternate group {#altgroup}
An integer specifying a group of tracks which are alternate versions of one-another. A subscriber SHOULD only subscribe to one track from a set of tracks specifying the same alternate group number. A common example would be a video tracks of the same content offered in alternate bitrates. 

### Initialization data {#initdata}
A string holding Base64 [BASE64] encoded initialization data for the track. 

### Initialization track {#inittrack}
A string specifying the track name of another track which holds initialization data for the current track. Note that initialization tracks SHOULD NOT delcare alternate group and render group bindings. 

### Selection parameters {#selectionparameters}
An object holding a series of name/value pairs which a subscriber can use to select tracks for subscription. If present, the selection parameters object MUST NOT be empty. Any selection parameters declared at the root level are inherited by all tracks. A selection parameters object may exist at both the root and track level. The additive combination of the parameters 

### Codec {#codec}
A string defining the codec used to encode the track.
For LOC packaged content, the string codec registrations are defined in Sect 3 and Section 4 of {{WEBCODECS-CODEC-REGISTRY}}.
For CMAF packaged content, the string codec registrations are defined in XXX.

### Framerate {#framerate}
A number defining the framerate of the track, expressed as frames per second.

### Bitrate {#bitrate}
A number defining the bitrate of track, expressed in bits second. 

### Samplerate {#bitrate}
The number of frame samples per second. This property SHOULD only accompany audio codecs. 

### Width {#width}
A number expressing the encoded width of the track content in pixels.

### Height {#height}
A number expressing the encoded height of the video frames in pixels.

### Channel count {#channelcount}
The number of audio channels. This property SHOULD only accompany audio codecs. 

### Display width {#displaywidth}
A number expressing the intended display width of the track content in pixels. 

### Display height {#displayheight}
A number expressing the intended display height of the track content in pixels. 

### Language {#language}
A string defining the dominant language of the track. The string MUST be one of the standard Tags for Identifying Languages as defined by [LANG].

### Temporal ID {#temporalid}
A number identifying the temporal layer/sub-layer encoding of the track, starting with 0 for the base layer, and increasing with higher temporal fidelity.

### Spatial ID {#spatialid}
A number identifying the spatial layer encoding of the track, starting with 0 for the base layer, and increasing with higher fidelity.

### Time aligned  {#timealigned}
An array of track names intended for synchronized playout. An example would be audio and video media synced for playout in a conference setting.
TODO - are these the same as groups?

### Layered {#layered}
An array of track names that are dependent on one another for decoding. Each track included in this layered relation set MUST include include either a temporal ID {#temporalid} or a spatial ID {#spatialid} as a track property. 

### Simulcast  {#simulcast}
An array of tracks that share the same time offset when producing the media as well as the same time offset when consuming the media. An example would be tracks representing camera capture across multiple encoding qualities.
TODO - are these the same as alternates?

## Catalog Delta Updates
A catalog may contain incremental changes. This is a useful property if many tracks may be initially declared but then there are small chnages to a subset of tracks. The producer can issue a delta update to describe these small changes. Changes are described incrementally, meaning that a delta-update may itself depend on a previous delta update. 

The following rules MUST be followed by subscribers in processing delta updates
* If a catalog is received without the parent sequence number field {#parentsequencenumber} defined, then it is an independent catalog and no delta update processing is required.
* If a catalog is received with a parent sequence number field present, then the content of the catalog MUST be parsed as if the catalog contents had been added to the contents received on the referenced moq-transport object. Newer field definitions overwrite older field definitions.
* Track namespaces may not be changed across delta updates. 
* Contents of the track selection properties object may not be varied across updates. To adjust a track selection property, the track must first be removed and then added with the new selection properties and a different name.
* Track names may not be changed across delta updates. To change a track name, remove the track and then add a new track with the new name and matching properties. 

## Catalog Examples

The following section provides non-normative JSON examples of various catalogs comopliant with this draft. .

TODO: add examples to show CMAF, mixed format, delat updates. 

### Lip Sync Audio/Video Tracks with single quality

This example shows catalog for the media sender, Alice, capable
of sending audio and video tracks and share lip-sync relation.

~~~json
{
  "f": 1,
  "v": "0.2",
  "ns": "conference.example.com/conference123/alice",
  "p": "loc",
  "ta": ["audio", "video"],
  "tracks": [
    {
      "n": "video",
      "sp":{"cs":"av01.0.08M.10.0.110.09","wd":1920,"ht":1080,"fr":30},
      "gr":1
    },
    {
      "n": "audio",
      "sp":{"cs":"opus","sr":48000,"cc":2},
      "gr":1
    }
   ]
}

~~~


### Simulcast video tracks - 3 qualities


This example shows catalog for the media sender, Alice, capable
of sending 3 video tracks for high definition, low definition and
medium definition qualities in time-aligned relation.


~~~json
{
  "f": 1,
  "v": "0.2",
  "ns": "conference.example.com/conference123/alice",
  "sp": {"cs":"av01","fr":30},
  "sim": ["hd", "sd", "md"],
  "tracks":[
    {
     
      "n": "hd",
      "sp": {"wd":1920,"ht":1080},
      "alt":1
    },
    {
      "n": "md",
      "sp": {"wd":720,"ht":640},
      "alt":1
    },
    {
      "n": "sd",
      "sp": {"wd":192,"ht":144},
      "alt":1
    }
   ]
}

~~~


# Security Considerations

The catalog payload type header MUST NOT be encrypted. The catalog payload body MAY be encrypted.

# IANA Considerations {#iana}

This section details how the MoQ Streaming Format Type can be registered.  The type registry can be updated by incrementally expanding the type space, i.e., by allocating and reserving new type identifiers.  As per [RFC8126], this section details the creation of the "MoQ Streaming Format Type" registry.

## MoQ Streaming Format Type Registry

This document creates a new registry, "MoQ Streaming Format Type".  The registry policy is "RFC Required".  The Type value is 2 octets.  The range is 0x0000-0xFFFF. The initial entry in the registry is:

         +--------+-------------+----------------------------------+
         | Type   |     Name    |            RFC                   |
         +--------+-------------+----------------------------------+
         | 0x0000 |   Reserved  |                                  |
         +--------+-------------+----------------------------------+

Every MoQ streaming format draft normatively referencing this catalog format MUST register itself a unique type identifier. 

# Acknowledgments
{:numbered="false"}

The IETF MoQ mailing lists and discussion groups.
