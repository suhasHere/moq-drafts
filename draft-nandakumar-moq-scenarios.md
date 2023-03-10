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

One ambition of MoQ is to define a single QUIC based transport for multiple transmission scenarios, including streaming scenarios currently using RTMP and conferencing scenarios currently using WebRTC. Ideally, this would enable support in Content Distribution Networks for both types of scenarios.

## Streaming Scenarios

Streaming scenarios typically separate "content ingestion" and "content distribution". Content is provided by one or several "emitters"

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

# Scenario differences

We find that scenarios differs in multiple ways. In the previous sections we detail the obvious differences, such as different network topologies or different latency targets, but other factors also come in play.

## Interval between access points

In the streaming scenarios, there is an important emphasis on resynchronization, characterized by a short distance between "access points". This can be used for features like fast-forward or rewinding, which are common in non-real-time streaming. For real-time streaming experiences such as watching a sport event, frequent access points allow "channel surfers" to quickly join the broadcast and enjoy the experience. The interval between these access points will often be just a few seconds.

In video encoding, each access point is mapped to a fully encoded frame that can be used as reference for the "group of blocks". The encoding of these reference frames is typically much larger than the differential encoding of the following frames. This creates a peak of traffic at the beginning of the group. This peak is much easier to absorb in streaming applications that tolerate higher latencies than interactive video conferences. In practice, real time conferences tend to use much longer groups, resulting in higher compression ratios and smoother bandwidth consumption.

Of course, having longer blocks create other issues. Realtime conferences also need to accomodate the occasional occasional late comer, or the disconnected user who want to resynchronize after a network event. This drives a need for synchronization "between access points". For example, rather than waiting for 30 seconds before connecting, the user might quickly download the "key" frames of the past 30 seconds and replay them in order to "synchronize" the video decoder.

## Intervals and congestion

When streaming is organized as a series of short groups of objects, it is possible to use the groups as units of congestion control. The objects of a single stream or of related streams can be organized by order of delivery, starting with the most important in the group. In case of congestion, when there is not enough bandwidth to send everything, the objects at the "tail" of the transmission order get dropped, and transmission of the next group starts.

These "group oriented" mechanism are effectively making an adaptation decision at the end of each group. The latency of the control loop is the duration of the group, which implies that the target latency will be tied to the duration of the group. But for real time conferencing other priorities drive the group duration to large values such as 30 seconds, which then require making decisions "inside the group", not "at the end of it".

## Planning in advance or not

If the entire set of objects to be sent in a group is known at the beginning of a group transmission, it is possible to order these objects according to the "delivery order" that will provide the best experience, instead of merely sending them according to their planned replay time. For example, taking a simple example of a "time based" layering, we would want to first send all the 15 fps frames, then all the 30 fps frames, then all the 60 fps frames. The receiver will get the objects that fit in the available bandwidth, and then render the frames in their natural order, playing the whole group at either 15 fps, 30 fps, or 60fps.

This kind of planning in advance is not possible for real time conferences. If we want to target a latency of 100 or 200 ms, we can buffer at most 6 or maybe 12 frames, certainly not the whole group. The order of transmission will have to be rather close to the order of capture. If the bandwidth is limited, some content will have to be pruned "in real time" rather than waiting the end of the group.

# Unit of grouping tracks

Two views:

*  Emission (non conferencing)
*  Multiple Emissions and their tracks into one container (conferencing A/B)


