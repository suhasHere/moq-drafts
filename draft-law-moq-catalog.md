---
title: "Catalog Specification for MoQ Base Protocol compliant streaming formats"
abbrev: "catalog moq"
category: info

docname: draft-law-moq-catalog
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
    fullname: Will Law
    organization: Akamai
    email: wilaw@akamai.com
 -
    fullname: Suhas Nandakumar
    organization: Cisco
    email: snandaku@cisco.com

normative:

informative:


--- abstract

This document defines core requirements for a Catalog specification such that it is compliant with the MoQ Base Protocol and interoperable with other Catalog definitions.

--- middle

# Introduction

The MoQ Base Protocol [RFCXXX] defines a media transport protocol that utilizes the QUIC network protocol [QUIC] and WebTransport[WebTrans] to move objects between publishers, subscribers and intermediaries. Subscription IDs are used to identify available tracks.  The mapping of media characteristics to objects, as well as relative prioritization of those objects, is defined by a separate MoQ Streaming Format specification. Multiple streaming formats can operate concurrently over MoQ base protocol. Each streaming format defines its own catalog definition. This document provides normative requirements for these catalog definitions to ensure their compatibility across networks implementing the MoQ Base Protocol.

# Conventions and Definitions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 [RFC2119].

## Terminology

 - Catalog - a Track with a reserved Track ID within an emission that defines the availability of other Tracks.
 - Emission - a collection of Tracks under a common prioritization and orchestration domain.
 - MoQ Base Protocol (MBP) - a media transport protocol that utilizes the QUIC network protocol [QUIC] and WebTransport[WebTrans] to move objects between publishers, subscribers and intermediaries
 - MoQ Streaming Format - a specification which defines how to stream media over the MoQ Base Protocol. It includes a catalog definition, a mapping of media to MBP objects, prioritization rules and additional business logic.
 - Track - a sequence of Objects within MBP
 - Track ID - a string used to identify a Track

# Catalog

A Catalog is a special case of a Track. A Track is composed of a succession of Objects, each assigned to a Group.

## Catalog Track ID

A Catalog MUST have a Track ID of "catalog". This ID is a lowercase string. Each Emission must have at most one Track ID of "catalog", which defines all other tracks within that emission.  If a streaming format requires a series of multiple catalogs, then it MUST maintain a singleton parent "catalog" which is the entry point and definition of all other child catalogs within that emission.

## Catalog payload structure

The payload of a Catalog Object consists of two components - a two octet header defining the type, followed by the variable length body.

        +---------------+--------------------+
        |  0x01 - 0x02  |  Type designator   |
        |  0x03 -       |       Body         |
        +---------------+--------------------+

To understand the type of catalog object, a receiver would read the first two octets of the object payload and interpret them as an integer in the range  0x0000 - 0xFFFF. This would define the Streaming Format of the catalog object, which in turn would define the serialization of the body, allowing the receiver to parse the body and extract the internal information.

A Catalog specification MUST define the binary serialization of the body. This serialization may vary between streaming formats and there is no requirement to standardize how the data within the body is represented.

## Catalog contents

A Catalog MUST describe the Track IDs available within an emission. It MAY provide initialization data as well as selection criteria to assist a client in selecting content for subscription.

## Catalog dependency

The first Catalog object in any group sequence MUST be independent of any other catalog object. Subsequent catalog objects within the same group sequence MAY be dependent on the prior catalog objects within the same group.


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

# References

## Normative References

  [RFC XXX]   Nandakumar, S "MoQ Base Protocol"
              Work in progress

  [RFC2119]  Bradner, S., "Key words for use in RFCs to Indicate
             Requirement Levels", BCP 14, RFC 2119,
             DOI 10.17487/RFC2119, March 1997,
             <https://www.rfc-editor.org/info/rfc2119>.

## Informative references

  [RFC8126]  Cotton, M., Leiba, B., and T. Narten, "Guidelines for
             Writing an IANA Considerations Section in RFCs", BCP 26,
             RFC 8126, DOI 10.17487/RFC8126, June 2017,
             <https://www.rfc-editor.org/info/rfc8126>.

  [QUIC]    Iyengar, J., Ed. and M. Thomson, Ed., "QUIC: A UDP-Based Multiplexed and Secure Transport",
            RFC 9000, DOI 10.17487/RFC9000, May 2021,
            <https://www.rfc-editor.org/rfc/rfc9000>.

  [WebTransport]    Frindell, A., Kinnear, E., and V. Vasiliev, "WebTransport over HTTP/3",
                    Work in Progress, Internet-Draft, draft-ietf-webtrans-http3-04, 24 January 2023,
                    <https://datatracker.ietf.org/doc/html/draft-ietf-webtrans-http3-04>.

# Acknowledgments
{:numbered="false"}

The IETF MoQ mailing lists and discussion groups.
