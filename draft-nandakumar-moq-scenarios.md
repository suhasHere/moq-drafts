---
title: Exploration of MoQ scenarios and Data Model
abbrev: MoQ Scenarios
docname: draft-nandakumar-moq-scenarios-latest
date: {DATE}
category: info

ipr: trust200902
area: General
submissionType: IETF
workgroup: Independent Submission
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
-
  ins: S. Nandakumar
  name: Suhas Nandakumar
  org: Cisco
  email: snandaku@cisco.com
-
   ins: C. Huitema
   name: Christian Huitema
   org: Private Octopus Inc.
   email: huitema@huitema.net

--- abstract

This document delineates a set of key scenarios and details the requirements
that they place on the MoQ data model.

--- middle

# Introduction

When developing the data model for MoQ, we realized that different WG participants were making different assumptions about the role of streams, broadcast or emitters, and also on the delivery constraints for objects compositing different streams. This draft studies different scenarios and details their requirements.

# Scenarios

## Streaming Scenarios
~~~
live.tw.tv
OBS Client -> Ingest Server 
  (Emitter)

Distribution Server -> Clients 
  Catalog that has tracks 
 Latency = 500ms - 2 seconds
                   (maps to GOP length)
~~~

## Conferencing Scenarios
~~~
Conferencing - A
  publishers - Conferencing Server - Subscribers
                [auth server, media logic]
  ==> similar to combination of 2 examples above
  Latency - 200ms 

Conferencing - B
  publishers - Relays - Subscribers
               [origin server for authorization,
                catalog management]
       Multiple emitters in a catalog
       Subscribers subscribe to emitter trackId
    Track Namespace               
  Latency - 200ms 
            boundary by GOP length is not practical 
~~~

# Unit of grouping tracks

Two views:

*  Emission (non conferencing)
*  Multiple Emissions and their tracks into one container (conferencing A/B)

# Transmission requirements

~~~
  Streaming scenario - easy resynchronization - rewind, fast forward
                     ==> GOP are typically rather short (~2s)

  Interactive Scenario - avoid too many restart points, makes transmission
                         inefficient over short periods of time ( peaks of bW requests for the i-frame)
                        If restart points are used to recover, they are spread out too far. It drives resynchronization between restart points 
~~~