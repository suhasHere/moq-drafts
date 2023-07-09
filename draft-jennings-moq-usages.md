---
title: MOQ Usages for audio and video applications
abbrev: moq-usages
docname: draft-jennings-moq-usages-latest
category: info
submissiontype: IETF
ipr: trust200902
submissionType: info
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

--- abstract

Media over QUIC Transport (MOQT) defines a publish/subscribe based protocol for delivering media over QUIC. This specification defines details for building audio and video application over MOQT.

--- middle

# Introduction

Media over QUIC Transport (MOQT) transport protocol allows set of publishers and subscribers to participate in the media delivery over QUIC for streaming and interactive applications.

The MOQT specification defines the media delivery API but it
stays out of defining specifics of me


TODO: Add what's in scope of the moqt
TODO: add this spec provides mapping to MOQT object model
TODO: mapping from the object model to QUIC Construcs

~~~ascii

+------------------------------+
|     Application Data         |
+---------------+--------------+
                |   +-------------------------------+
                |   |    Tracks, groups, objects    |
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



# Simplifying Assumptions 

- Closed GOP 
- Group typically follow IDR interval
- GOP duration is same across alternate encodings


# MOQT QUIC Mapping {#quic-map}

Appkiato
* Stream per Group: TODO

* Stream per Object: TODO


# MoQ Audio Objects {#moq-audio}

Each chunk of encoded audio data, say 10ms, represents a MOQ Object.
In this setup, there is one object per MOQ Group, where, the
`Group Sequence` in the object header is increment by one for each
encoded audio data and the `Object Sequence` is set to value 0.
When mapped to the underlying QUIC Stream, each such unitary group
is sent over individual unidirectional QUIC stream.

TODO: add a note on ML audio codecs.


# MoQ Video Objects {#moq-video}

The decision on what constitues a MOQ object/group and its preferred mapping to the underlying QUIC transport for video applications is governed by the granularity of encoded bitstream. The smallest unit of such an application defined encoded bistream will be called as "Video Atom" in this specification and they are mapped to MOQ Objects.
The size and duration of a video atom is application controlled and follow various strategies driven by requirements such as latency, quality, bandwidth and so on, and each video atom is mapped to a MOQ Object. Today's video is often encoded with I-frames at a fixed interval but this can result in pulsing video quality. Future system may want to insert I-frames at each change of scene resulting in groups with a variable number of frames. QuicR easily supports that.


Following subsection identify commonly used definition for such atoms and their corresponding mapping to MoQ object model and the QUIC transport.


## Encoded Frame {#enc-frame}

In this case, each encoded video frame is mapped to a MOQ Object.
The `Group Sequence` is incremented by 1 at the I-Frame/key frame boundaries. The `Object Sequence` is increment by 1 for each frame, starting at 0 and resetting to 0 on the next I-Frame (thus starting a new group). The first video frame (Object Sequence 0) should be I-Frame and the rest of the video frames are dependent frames (delta frames) and organized in the decode order.

When mapping to QUIC, there are couple of options for applications to choose from:

* One unidirectional QUIC stream is used to deliver one Encoded Frame. In this mode, the receiver application should manage out of order streams to ensure the MOQ Objects are delivered to the decoder in the increasing order of the `Object Sequence` within a group and in the increasing order of the `Group Sequence`.


* One unidirectional QUIC stream per group is setup to deliver all the encoded frames (objects) within a group are delivered over a single QUIC stream. It is to be noted of possible HOL blocking when delivering the group under losses.


TODO: Need a way in the API to pick the mode of delivery


## Encoded Slice {#enc-slice}

In Slice-based encoding a single video frame is “sliced” into separate sections and are encoded simultaneously in parallel. Once encoded, each slice can then be immediately streamed to a decoder instead of waiting for the entire frame to be encoded first.

In this case, each encoded slice is a MoQ object, starting with I-frame as `Object Sequence` of 0 for that slice and followed by delta frames with `Object Sequence` incremented by 1. A group is identified by set of such objects at each I-frame boundaries. To be able to successfully decode and render, the video frame Id in the slice is contained needs to be carried in the encoded object.


When mapping to QUIC, there are couple of options for applications to choose from:

* One unidirectional QUIC stream per encoded slice (Object)

* One unidirectional QUIC stream per group of slices

* One unidirectional QUIC stream per the video frame

* One unidirectional QUIC stream is used to deliver one Encoded Frame. In this mode, the receiver application should manage out of order streams to ensure the MOQ Objects are delivered to the decoder in the increasing order of the `Object Sequence` within a group and in the increasing order of the `Group Sequence`.

* One unidirectional QUIC stream per group is setup to deliver all the encoded frames (objects) within a group are delivered over a single QUIC stream. It is to be noted of possible HOL blocking when delivering the group under losses.

## CMAF Chunk {#enc-cmaf-chunk}

CMAF chunks are CMAF addressable media objects that contain a consecutive subset of the media samples in a CMAF fragment. CMAF chunks can be used by a delivery protocol to deliver media samples as soon as possible during live encoding and streaming, i.e., typically less than a second. CMAF chunks enable the progressive encoding, delivery, and decoding of each CMAF fragment.

A given video application may choose to have chunk duration to span more than on encoded video frame. When using CMAF chunks, each MOQ object corresponds to a CMAF chunk. The CMAF chunk containing the IDR-Frame shall have `Object Sequence` set to 0, with each additionl chunk with sequence incremented by 1. The `Group Sequence` is incremented at every IDR interval and all the CMAF chunks within a given IDR interval shall be part of the same MOQ Group. On the receiver, the MOQ objects (chunks) are delivered to the decoder in the order of `Object Sequence`.

## CMAF Fragment {#enc-cmaf-frag}

CMAF fragments are the media objects that are encoded and decoded. For scenarios, where the fragments contian one or more complete coded and indepdently decodable video sequences, each such fragment is identified as single MOQ Object and it forms its own MoQ Group. There is one unidirectional QUIC stream per such an object. Media senders should stream the bytes of the object, in the decode order, as they are generated in order the reduce the latencies.


# Single Quality Media Streams

For scenarios where the publisher intents to publish
single quality audio and video streams. Application shall map the 
audio and video streams to individual tracks enabling each 
track to represent a single quality.

TODO: Add an example
TODO: Add a note on Catalog 

# Multiple Quality Media Streans

It is not uncommon for applications to support multiple qualities (renditions) per
media stream to support receivers with varied capabilites, enabling adaptive bitrate media flows, for example. Serveral subsections attempts to discuss how media applications can map such multiple media qualities to the MOQT object model and the underlying QUIC transport.

## Simulcast {#simulcast}

In simulcast, each MOQT track is an time-aligned alternative encoding
(say,  multiple resolutions) of the same source content. Simulcasting allows
consumers to switch between tracks at group boundaries.

### Media Sender Behavior

* Catalog should identify time-aliged relationship between the simulcasted tracks.
* All the alternate encodings shall matching base timestamp and duration.
* All the alternate encodings are for the same source media stream.

### Media Consumer Behavior

TODO


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

In this mode, each SVC layer is mapped to MOQT Track. Each unique combination of fidelity (say spatial and temporal) is identified by a MOQT Track ( see example below). 

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


# Object and Track Priorities

TODO: Add notes from Mo

# Bitrate Adaptation


# Media Containerization

TODO: add a note on wmf & loc, also capture enryption option





--- back


# Security Considerations

This section needs more work

# IANA Considerations {#iana}

TODO: fill this section. Register ALPN. Register WebTransport protocol.
Open new registry for MoQ message types. Possibly, open registry for
MoQ errors.

# References

## Normative References

## Informative references

# Acknowledgments

Cullen Jennings, the IETF MoQ mailing lists and discussion groups.
