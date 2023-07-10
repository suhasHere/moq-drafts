---
title: MOQ Usages for audio and video applications
abbrev: moq-usages
docname: draft-jennings-moq-usages-latest
category: info
ipr: trust200902
stand_alone: yes
submissionType: IETF
author:
-
    fullname: Cullen Jennings
    organization: Cisco
    email: fluffy@iii.ca
-
    fullname: Suhas Nandakumar
    organization: Cisco
    email: snandaku@cisco.com
-
    fullname: Mo Zanaty
    organization: Cisco
    email: mzanaty@cisco.com

normative:
informative:
  MoQTransport: I-D.ietf-moq-transport
  RFC7656:
  RFC9000: RFC9000
  ISOBMFF:
    title: "Information technology -- Coding of audio-visual objects -- Part 12: ISO Base Media File Format"
    date: 2015-12
  CMAF:
    title: "Information technology -- Multimedia application format (MPEG-A) -- Part 19: Common media application format (CMAF) for segmented media"
    date: 2020-03
  

--- abstract

Media over QUIC Transport (MOQT) defines a publish/subscribe based unified media delivery protocol for delivering media for streaming and interactive applications over QUIC. This specification defines details for building audio and video applications over MOQT, more specifically, provides information on mapping application media objects to the MOQT object model and possible mapping of the same to underlying QUIC transport.


--- middle

# Introduction

Media Over QUIC Transport (MOQT) {{?MoQTransport}} allows set of publishers and subscribers to participate in the media delivery over QUIC for streaming and interactive applications. The MOQT specification defines the necessary protocol machinery for the endpoints and relays to particpate, however, it doesn't provide recommendations for media applications on using MOQT object model and mapping the same to underlying QUIC transport.

This document introduces MOQT's object model mapping to underlying QUIC transport in {{quic-map}}. The sections {{moq-audio}}
and {{moq-video}} describe various grouping of application level media objects and their mapping to the MOQT object model. Section {{multi}} disucsses considerations when using multi quality video applications, such as simulcast and/or layer coding, over the MOQT protocol. Section {{abr}} describes considerations for adaptive bitrate techniques and finally the section {{priority}} discusses interactions when priorities are used on objects and tracks.

Below picture captures the conceptual model showing mapping at various levels of a typical media application stack using MOQT delivery protocol.


~~~ascii
+------------------------------+
|     Application Data         | ----+ frames,slices,segments
+---------------+--------------+     |
                |                    v
                |   +-------------------------------+
                |   |    Tracks, Groups, Objects    |
                |   +-------------------------------+
 +--------------v---------------+
 |     MOQT Object Model        |
 +--------------+---------------+
                |  +----------------------------------------+
                |  |Stream per Group, Stream per Object, .. |
                |  +----------------------------------------+
+---------------v--------------+
|            QUIC              |
+------------------------------+
~~~

## Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD","SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in {{!RFC2119}}.

## Terminology

TODO

# MOQT QUIC Mapping {#quic-map}

In a typical MOQT media application, the captured media from a media source is encoded (compressed), encrypted (based on the encryption scheme), packaged (based on the container format) and mapped into MOQT object model. Applications can then deliver the encoded MOQT objects for a MOQT track using one of the options described in the sub-sections, when leveraging the QUIC transport.

~~~ascii-figure
        |                         
Encoded (and/or) Encrypted Media Stream                
        V                         
+-------------------+   
|       MOQT        | 
+-------------------+ 
        |                         
    MOQ Tracks
        V                   / =====  QUIC Stream per Group
+---------------------+    | 
|   QUIC Transport    |  --|  =====  QUIC Stream per Object
+---------------------+    |  
                           |  =====  QUIC Stream per Track
                           |     
                           |  =====  QUIC Stream per multiple Tracks
                           |    
                            \  =====  QUIC Stream per Priority
~~~

## Stream per MOQT Group {#spg}

In this mode, an unidirectional QUIC stream is setup per MOQ Group (section 2.2 of {{?MoQTransport}}). Following observations can be made about such a setup

* MOQT groups typically represent things that share some kind of relationship (eg decodability, priority) and having the objects of a group share the same underlying stream context allows them to delivered cohorently. 

* Media consumers can map each incoming QUIC stream into decoding context in the order of their arrival.

* Since the objects within group share the QUIC stream, there is likelyhood of increased end to end latency due to head-of-line blocking under losses.


## Stream per MOQT Object {#spo}

In this mode, an unidirectional QUIC stream is setup per MOQ Objecy (section 2.1 of {{?MoQTransport}}). Following observations can be made about such a setup 

* Using a single stream per object can help reduce latency at the source, when objects represent smaller units of the application data (say a single encoded frame or a small number of the same). 

* The impact of on-path losses to the end to end latency is scoped to the object duration. The smaller the object duration, the lesser impact on the end to end latency.

* One stream per object may end up in creating large number of streams, especially when the objects durations is small. 

* Media consumers may need to re-organize the incoming streams for handling objects within a group, since streams may arrive out of order.


## Stream per MOQT Track {#spt}

In this mode, there is one unidirectional QUIC stream per MOQT Track (section 2.3 {{?MoQTransport}}). Following observations can be made about such a setup 

* This scheme is the simplest in its implementation and the streams stays active until the track exists. Endpoints need to maintain just one stream context per track. 

* Since all the objects within the track share the same stream, the may be impact on end to end latency due to HOL blocking under loss.


## Stream per Priortiy {#spop}

In this mode, there is one unidirectional QUIC stream per MOQT Track/Object priority. Following observations can be made about such a setup 

* This scheme is relatively simpler in its implementation and number of stream contextx match number of priority levels.

* Such a scheme can be used at Relays when forwarding decisions can be naturally mapped to priorities carried in the object header.

## Stream per multiple MOQT Tracks {#spmt}

This mode is simialar {{spt}} but with more than one MOQT track delivered over a single unidirectional QUIC stream, thus allowing implementations to map multiple incoming QUIC streams to a few outgoing QUIC Streams. Similar to {{spt}}, this mode is relatively simple in its implementation and at the same time may suffer from latency impacts under losses.

# MoQ Audio Objects {#moq-audio}

Each chunk of encoded audio data, say 10ms, represents a MOQ Object.
In this setup, there is one `MOQT Object` per `MOQT Group`, where, the
`Group Sequence` in the object header is increment by one for each
encoded audio chunk and the `Object Sequence` is defaulted to value 0.
When mapped to the underlying QUIC Stream, each such unitary group
is sent over individual unidirectional QUIC stream (similar to {{spo}}/{{spg}}).

Future sub 2 kbps audio codecs may take advantage of a rapidly updated model that are needed to decode the audio which could result in audio needing to use groups with multiple objects to ensure all the objects needed to decode some audio are in the same group.

# MoQ Video Objects {#moq-video}

The decision on what constitues a MOQ object/group and its preferred mapping to the underlying QUIC transport for video streams is governed by the granularity of encoded bitstream, as chosen by the application. The smallest unit of such an application defined encoded bistream will be referred to as "Video Atom" in this specification and they are mapped 1:1 to MOQ Objects.

The size and duration of a video atom is application controlled and follow various strategies driven by application requirements such as latency, quality, bandwidth and so on. 

Following subsections identify various granulraties definiing the video atoms and their corresponding mapping to MOQT object model and the underlying QUIC transport.


## Encoded Frame {#enc-frame}

In this scheme, each encoded video frame is mapped to a MOQT Object.
The `Group Sequence` is incremented by 1 at IDR Frame boundaries. The `Object Sequence` is increment by 1 for each frame, starting at 0 and resetting to 0 at the start of new group. The first video frame (`Object Sequence` 0) should be I-Frame and the rest of the video frames are typically dependent frames (delta frames) and organized in the decode order.

When using QUIC mapping scheme defined in {{spo}}, each unidirectional QUIC stream is used to deliver one Encoded Frame. In this mode, the receiver application should manage out of order streams to ensure the MOQ Objects are delivered to the decoder in the increasing order of the `Object Sequence` within a group and  the increasing order of the `Group Sequence`.

When using QUIC mapping as defined in {spg}, each unidirectional QUIC stream is setup to deliver all the encoded frames (objects) within a group. 


## Encoded Slice {#enc-slice}

In Slice-based encoding a single video frame is “sliced” into separate sections and are encoded simultaneously in parallel. Once encoded, each slice can then be immediately streamed to a decoder instead of waiting for the entire frame to be encoded first.

In this scheme, each encoded slice is a MOQT Object, starting with IDR frame as `Object Sequence` of 0 for that slice and followed by delta frames with `Object Sequence` incremented by 1 successively. A MOQT Group is identified by set of such objects at each IDR frame boundaries. To be able to successfully decode and render, the identifier of the containing video frame for the slice is needs to be carried end to end. This would allow the media consumer to map the slices to right decoding context of the frame being processed.

>Note: The video frame identitifer may be carried either as part of encoded object's payload header or introduce a group header for conveying the frame identifier. 

When using QUIC mapping scheme defined in {{spo}}, each unidirectional QUIC stream is used to deliver one encoded slice of a video frame. When using QUIC mapping as defined in {spg}, each unidirectional QUIC stream is setup to deliver all the encoded slices (objects) within a group. 
 

## CMAF Chunk {#enc-cmaf-chunk}

CMAF {{CMAF}} chunks are CMAF addressable media objects that contain a consecutive subset of the media samples in a CMAF fragment. CMAF chunks can be used by a delivery protocol to deliver media samples as soon as possible during live encoding and streaming, i.e., typically less than a second. CMAF chunks enable the progressive encoding, delivery, and decoding of each CMAF fragment.

A given video application may choose to have chunk duration to span more than on encoded video frame. When using CMAF chunks, each MOQT Object corresponds to a CMAF chunk. The CMAF chunk containing the IDR Frame shall have `Object Sequence` set to 0, with each additionl chunk with its `Obect Sequence` incremented by 1. The `Group Sequence` is incremented at every IDR interval and all the CMAF chunks within a given IDR interval shall be part of the same MOQT Group.

When using QUIC mapping scheme defined in {{spo}}, each unidirectional QUIC stream is used to deliver a CMAF Chunk. When using QUIC mapping as defined in {spg}, each unidirectional QUIC stream is setup to deliver all the CMAF chunks (objects) within a group. When using QUIC mapping defined in {{spt}} CMAF chunk corresponding to CMAF track are delivered over the same unidirectional QUIC stream. 

## CMAF Fragment {#enc-cmaf-frag}

CMAF fragments are the media objects that are encoded and decoded. For scenarios, where the fragments contian one or more complete coded and independently decodable video sequences, each such fragment is identified as single MOQT Object and it forms its own MOQT Group. There is one unidirectional QUIC stream per such an object {{spo}}. Media senders should stream the bytes of the object, in the decode order, as they are generated in order the reduce the latencies.


# MOQT Track 

MOQT Tracks are typically characterized by having a single encoded and optionally encrypted configuration. Applications can encoded a captured source stream into one or more qualities as described in the sub sections below.

## Single Quality Media Streams

For scenarios where the publisher intents to publish
single quality audio and video streams, applications shall map the 
audio and video streams to individual tracks enabling each 
track to represent a single quality. 

# Multiple Quality Media Streans {#multi}

It is not uncommon for applications to support multiple qualities (renditions) per source stream to support receivers with varied capabilites, enabling adaptive bitrate media flows, for example. We describe 2 common approaches for supporting multiple qualities(renditions/encodings) - Simulcast and Layered Coding. Sections below discusses media application's mapping of multiple media qualities to the MOQT object model and the underlying QUIC transport.

## Simulcast {#simulcast}

In simulcast, each MOQT track is an time-aligned alternate encoding
(say, multiple resolutions) of the same source content. Simulcasting allows
consumers to switch between tracks at group boundaries seamlessly.

Few observations:

* Catalog should identify time-aliged relationship between the simulcasted tracks.
* All the alternate encodings shall matching base timestamp and duration.
* All the alternate encodings are for the same source media stream.
* Media consumers can pick and choose the right quality by subscribing to the appropriate track.
* Media consumers react to changing network/bandwidth situations by subscribing to different quality track at the group boundaries.


## Scalable Video Coding (SVC)

SVC defines a coded video representation in which a given bitstream offers representations of the source material at different levels of
fidelity (spatial, quality, temporal) structured in a hierarchical manner. 
Such an organization allows bitstream to be extracted at lower bit rate than the complete sequence to enable decoding of pictures with multiple image structures (for sequences encoded with spatial scalability), pictures at multiple picture rates (for sequences encoded with temporal scalability), and/or pictures with multiple levels of image quality (for sequences encoded with SNR/quality scalability). Different layers can be separated into different bitstreams. All decoders access the base stream; more capable decoders can access enhancement streams. 


### All layers in a single MOQT Track

In this mode, the video applications transmits all the SVC layers under a single MOQT Track. When mapping to the MOQT object model, any of the methods described in {{moq-video}} can be leveraged to mapped the encoded bitstream into MOQT groups and objects. 

When transmitting all the layers as part of a single track, following properites needs to be considered:

* Catalog should identify the SVC Codec information in its codec defintion.

* Media producer should map each video atom to the MOQ object in the decode order and can utilize any of the QUIC mapping methods described in {{quic-map}}.

* Dependency information for all the layers (such as spatial/temporal layer identifiers, dependeny descriptions) are encoded in the bistream and/or container for media consumers to ensure sucessfull decoding.

The scheme to map all the layers to a single track is simple to implement and allows subscibers/media consumers can independently make layer drop decisions without needing any protocol exchanges (as needed in {{simulcast}}). However, such a scheme is constrained by disallowing receivers to subscribers to selectively subscribe to the layers of their interest.

### One SVC layer per MOQT Track

In this mode, each SVC layer is mapped to a MOQT Track. Each unique combination of fidelity (say spatial and temporal) is identified by a MOQT Track ( see example below). 

~~~
+-----------+            +-----------+
|  S0T0     | -------->  |  Track1   |
+-----------+            +-----------+
+-----------+            +-----------+
|  S0T1     | -------->  |  Track2   |
+-----------+            +-----------+
+-----------+            +-----------+
|  S1T0     | -------->  |  Track3   |
+-----------+            +-----------+
+-----------+            +-----------+
|  S1T1     | -------->  |  Track4   |
+-----------+            +-----------+

ex: 2-layer spatial and 2-layer temporal scalability encoding

~~~

#### Media Producder Properties

The catalog should identify the complete list of dependent tracks for each track that is part of layered coding for a given media stream. For example the figure below shows a sample layer dependency structure (2 spatial and temporal layetrs) and corresponding tracks dependencies.


~~~ascii-figure

                  +----------+
     +----------->|  S1T1    |
     |            | Track4   |
     |            +----------+
     |                  ^
     |                  |
+----------+            |
|  S1TO    |            |
| Track3   |            |
+----------+      +-----+----+
      ^           |  SOT1    |
      |           | Track2   |
      |           +----------+
      |               ^
+----------+          |
|  SOTO     |         |
| Track1    |---------+
+----------+
   

Catalog Track Dependencies:

Track2 depends on Track1
Track3 depends on Track1
Track4 dependson Track2 and Track3   

~~~

Within each track, the encoded media for the given layer can follow mappings defined in {{moq-video}} and can choose from the options defined in {{quic-map}} for transporting thus mapped objects over QUIC. The bitstream and/or the container should carry the necessary to capture video frame level dependencies.

Media consumers would need to consider information from catalog to identify the track dependencies for a given media stream. This would allow the consumer to appropriately map the incoming QUIC streams and MOQ objects to the right decoder context.

### k-SVC

k-SVC is a flavor of layered coding wherein the encoded frames within a layer depend on only on the frames within the same layer, with the exception that the IDR frame in the enhancement layers depends on the IDR frame in its lower layer.

When each layer of a k-SVC encoded bitstream is mapped to a MOQT track, following needs to be taken into consideration:

* Catalog should identify the tracks are related via k-SVC dependency
* MOQT protocol should be extended to propose a group header that enables track for the enhancement layer to identify the `group sequence` that the current group depends on for the IDR Frame (object 0).

# Object and Track Priorities {#priority}

TODO: Add notes from Mo

# Bitrate Adaptation {#abr}

TODO: add considerations for cloent side ABR and possible options for server side ABR.

# Relay Considerations

Relays are not allowed to modify MOQT object header, as it might break encryption and authentication. However, Relays are free to apply any of the transport mappings defined in {{quic-map}} that it sees fit based on the local decisions.

For example, a well engineered Relay network may choose to take multiple incoming QUIC streams and map it to few outgoing QUIC streams (similar to one defined in {{spt}}) or the Relays may choose MOQT object priorities {{spop}} to decide the necessary transport mapping. It is important to observe that such decisions cam be made solely considering the MOQT Object header information.


# Usage mode identification 

This specification explores 2 possible usage modes for applications to conisder using MOQT media delivery protocol :

1. Transport Mapping {{quic-map}}

2.  MOQT Object model mapping

For interoperability purposes, media producers should communicate its usage modes to the media consumers. Same can be achieved in one of the following ways

1. Out of band, application specific mechanism. This apporach limits the interoperabiloty across applocations, however.

2. Exchange the usager modes via Catalog. This approach enables consumers of catalog to setup their transport/media stacks appropriately based on the sender's preference.


--- back


# Security Considerations

This section needs more work.

# IANA Considerations {#iana}

This document doesn't recommend any changes to IANA registries.

# Acknowledgments
