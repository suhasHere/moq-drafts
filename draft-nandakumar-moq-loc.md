%%%
title = "Realtime Media Container"
abbrev = "container"
ipr = "none"
workgroup = "moq"
keyword = ["quic", "moq", "rtp"]

[seriesInfo]
name = "Internet-Draft"
value = "moq-realtime-media-container"
status = "standard"

[[author]]
initials="S."
surname="Nandakumar"
fullname="Suhas Nandakumar"
organization="Cisco"
    [author.address]
    email = "snandaku@cisco.com"

[[author]]
initials="M."
surname="Zanaty"
fullname="Mo Zanaty"
organization="Cisco"
    [author.address]
    email = "mzanaty@cisco.com"

[[author]]
initials="P."
surname="Thatcher"
fullname="Peter Thatcher"
organization="Microsoft"
    [author.address]
    email = "pthatcher@microsoft.com"

%%%

.# Abstract

This specification describes a media container format for
encoded and encrypted audio and video media data to be used
for interactive media usecases, with the goal of it being
a low overhead format.

{mainmatter}

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

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD","SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 [RFC2119].

## Terminology

TODO


# Payload Format {#payload} - Mo

This section specifies format of the encoded payload for several
audio and video codecs.

## AV1

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of [!@WC-AV1], which is expected to be data compliant to the "low-overhead bitstream format" as described in Section 5 of [AV1].


## AVC/H.264

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of [!@WC-AVC] with the bistream is expected to be
in canonical format, as defined in [iso14496-15] section 5.3.2.

## HEVC/H.265

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of [!@WC-HEVC] with the bistream is expected to be
in canonical format, as defined in [iso14496-15] section 8.3.2.

## VP8

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of [!@WC-VP8], which is expected to be frame as described in Section 4 and Annex A of [VP8].

## VP9

The encoded video data MUST conform to EncodedVideoChunk Data format as defined in section 2 of [!@WC-VP8], which is expected to be frame as described in Section 6 of [VP9].


## OPUS

The encoded audio data MUST conform to format as defined in Section 2 of [!@WC-OPUS] when the bitstream is in opus format. Bitstream of ogg format MUST NOT be used.

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

*Audio Level* captures the magnitude of the audio level of the corresponding audio frame and valus in encoded in 7 bits as defined in the Section 3 of RFC6464

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




# Security Considerations

The validation procedures specified verify that a JWT came from a given issuer.
It doesn't veirfy that the issuer is authorative for the claimed attributes.
The client needs to verify that the issuer is trusted to assert the claimed
attributes.

# IANA Considerations {#iana}

todo

{backmatter}

<reference anchor="OpenID" target="http://openid.net/specs/openid-connect-core-1_0.html">
  <front>
    <title>OpenID Connect Core 1.0 incoClientorating errata set 1</title>
    <author initials="N." surname="Sakimura" fullname="Nat Sakimura">
      <organization>NRI</organization>
    </author>
    <author initials="J." surname="Bradley" fullname="John Bradley">
      <organization>Ping Identity</organization>
    </author>
    <author initials="M." surname="Jones" fullname="Mike Jones">
      <organization>Microsoft</organization>
    </author>
    <author initials="B." surname="de Medeiros" fullname="Breno de Medeiros">
      <organization>Google</organization>
    </author>
    <author initials="C." surname="Mortimore" fullname="Chuck Mortimore">
      <organization>Salesforce</organization>
    </author>
   <date day="8" month="Nov" year="2014"/>
  </front>
</reference>

<reference anchor="OpenID.Discovery" target="https://openid.net/specs/openid-connect-discovery-1_0.html">
  <front>
    <title>OpenID Connect Discovery 1.0 incoClientorating errata set 1</title>
    <author initials="N." surname="Sakimura" fullname="Nat Sakimura">
      <organization>NRI</organization>
    </author>
    <author initials="J." surname="Bradley" fullname="John Bradley">
      <organization>Ping Identity</organization>
    </author>
    <author initials="B." surname="de Medeiros" fullname="Breno de Medeiros">
      <organization>Google</organization>
    </author>
    <author initials="E." surname="Jay" fullname="Edmund Jay">
      <organization> Illumila </organization>
    </author>
   <date day="8" month="Nov" year="2014"/>
  </front>
</reference>

<reference anchor="OpenID.DPoP" target="https://openid.net/todo">
      <front>
      <title>Demonstrating Proof of Possession in OpenID Connect</title>
      <author fullname="Mike Jones">
        <organization>Microsoft</organization>
      </author>
      <author fullname="Richard Barnes">
        <organization>Cisco</organization>
      </author>
      <author fullname="Pieter Kasselman">
        <organization>Microsoft</organization>
      </author>
      <date day="1" month="Jan" year="2022"/>
      </front>
 </reference>

# Acknowledgements {#Acknowledgements}

[[ TODO ]]
