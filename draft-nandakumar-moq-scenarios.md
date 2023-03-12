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
-
   ins: C. Jennings
   name: Cullen Jennings
   org: Cisco
   email: fluffy@iii.ca

--- abstract

This document delineates a set of key scenarios and details the requirements
that they place on the MoQ data model.

--- middle

# Introduction

When developing the data model for MoQ, we realized that different WG participants were making different assumptions about the role of streams, broadcast or emitters, and also on the delivery constraints for objects compositing different streams. This draft studies different scenarios and details their requirements.

# Scenarios

One ambition of MoQ is to define a single QUIC based transport for multiple transmission scenarios, including streaming scenarios currently using RTMP and conferencing scenarios currently using WebRTC. Ideally, this would enable support in Content Distribution Networks for both types of scenarios.

## Streaming Scenarios

This section few scenarios for streaming use-cases. The scenarios listed are not exhaustive and doesn't intend to capture all possible application and architectures.

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

## Conferencing Scenarios - Classic

A interactive conferencing typically work under the
glass-to-glass latency to be around 200ms and is made up
of multiplcitiy of participant with varying capabilities
and operating under varying network conditions.

A typical conferencing session comprises of:

- Mutiple emitters, publishing on multiple tracks (audio, video tracks at different qualities)

- A media switch, sourcing tracks that represent a subset of tracks from across all
  the emitters. Such subset may represent tracks representing top 5 speakers at
  higher qualities and lot of tracks for rest of the emitters at lower qualities.

- Multiple receivers, with varied receiving capacity (bandwidth limited), subscribing to subset of the tracks


~~~
                                                       SFU:t1, E1:t2, E3:t6
 .───.  E1: t1,t2,t3,t4                                             .───.
( E1  )─────────┐                                      ┌─────────▶ ( S1  )
 `───'          │                                      │            `───'
                │                                      │
                └────────▶───────────────────┐         │
                         │                   │─────────┘
 .───.    E2: t1,t2      │       SFU         │       SFU:t1,E1:t2    .───.
( E2  )─────────────────▶│                   │────────────────────▶( S2  )
 `───'                   │                   │                      `───'
               ┌────────▶└───────────────────┴─────────┐
               │                                       │
               │                                       │
               │                                       │
               │                                       │
 .───.         │                                       │            .───.
( E3  )────────┘                                       └──────────▶( S3  )
 `───'     E3: t1,t2,t3,t4,t5,t6                     E3: t2,        `───'
                                                     E1: t2,
                                                     E2: t2,
                                                     SFU: t1
~~~



Above setup brings in following properties on the data model for the
transport protocol

- Media Switches to source new tracks but retain media payload from
  the original emitters. This implies new Track IDs sourced from the
  SFU, with obejct payload unchanged from the original emitters.

- Media Switches to propogate subset of tracks as-is from the emitters
  to the subscribers. This implies Track IDs to be scoped end to end.

- Subscribers to explictily request multiple appropriate qualities and
  dynamically move between the qualtiies during the course of the session

Another evolving topology for the interactive use-case is to use
multiple distribution networks for delivering the media and thus move
media switching functionality from purpose built SFUs to the
core distribution network as shown below

~~~
 E1: t1,t2,t3,t4              Distribution Network A
                                                            SFU:t1, E1:t2, E3:t6
    .───.                   ┌────────┐      ┌────────┐                 .───.
   ( E1  )──────────────────│ Relay  │──────│ Relay  ├──────────────▶ ( S1  )
    `───'                   └─────┬──┘      └──┬─────┘                 `───'
                                  │ ┌────────┐ │
   E2: t1,t2                      └─┤ Relay  │─┘
                      ┌────────────▶└────┬───┘                   SFU:t1,E1:t2
    .───.             │                  │                             .───.
   ( E2  )────────────┘                  │                   ┌───────▶( S2  )
    `───'                                │                   │         `───'
                             ┌────────┐  │   ┌────────┬──────┘
                    ┌────────┤ Relay  │──┴───│ Relay  │───────┐
                    │        └─────┬──┘      └──┬─────┘       │
                    │              │ ┌────────┐ │             │
                    │              └─┤ Relay  │─┘             │
    .───.           │                └────────┘               │        .───.
   ( E3  )──────────┘         Distribution Network B          └──────▶( S3  )
    `───'                                                              `───'
     E3: t1,t2,t3,t4,t5,t6                                    E3: t2,
                                                              E1: t2,
                                                              E2: t2,
                                                              SFU: t1
~~~

Such a topology needs to meet all the properties listed in a classic
style setup, however having multiple distribution networks
and relying on the distribution networks to carryout the media delivery,
brins in further towards a data model that enables tracks to be uniquely
identifiable across the distribution networks and not just within a
single distribution network.

# Scenario differences

We find that scenarios differs in multiple ways. In the previous sections we detail the obvious differences, such as different network topologies or different latency targets, but other factors also come in play.

## Interval between access points

In the streaming scenarios, there is an important emphasis on resynchronization, characterized by a short distance between "access points". This can be used for features like fast-forward or rewinding, which are common in non-real-time streaming. For real-time streaming experiences such as watching a sport event, frequent access points allow "channel surfers" to quickly join the broadcast and enjoy the experience. The interval between these access points will often be just a few seconds.

In video encoding, each access point is mapped to a fully encoded frame
that can be used as reference for the "group of blocks". The encoding of
these reference frames is typically much larger than the differential
encoding of the following frames. This creates a peak of traffic at the
beginning of the group. This peak is much easier to absorb in streaming
applications that tolerate higher latencies than interactive video
conferences. In practice, many real time conferences tend to use much
longer groups, resulting in higher compression ratios and smoother
bandwidth consumption along with a way to request the start of a new
group when needed. Other real time conferences tend to use very short
groups and just wait for the next group when needed.

Of course, having longer blocks create other issues. Realtime conferences also need to accomodate the occasional occasional late comer, or the disconnected user who want to resynchronize after a network event. This drives a need for synchronization "between access points". For example, rather than waiting for 30 seconds before connecting, the user might quickly download the "key" frames of the past 30 seconds and replay them in order to "synchronize" the video decoder.

## Intervals and congestion

When streaming is organized as a series of short groups of objects, it is possible to use the groups as units of congestion control. The objects of a single stream or of related streams can be organized by order of delivery, starting with the most important in the group. In case of congestion, when there is not enough bandwidth to send everything, the objects at the "tail" of the transmission order get dropped, and transmission of the next group starts.

These "group oriented" mechanism are effectively making an adaptation
decision at the end of each group. The latency of the control loop is
the duration of the group, which implies that the target latency will be
tied to the duration of the group. But for real time conferencing other
priorities drive the group duration to large values such as 30 seconds,
which then require making decisions "inside the group", not "at the end
of it".  The available bandwidth of a home internet connection can
change rapidly as other users in the home start doing things like
joining a video call or streaming 4K video. MoQ applications will need
to be able to adjust to these bandwith changes in much less time than a
typically video group length

## Planning in advance or not {#planning-or-not}

If the entire set of objects to be sent in a group is known at the beginning of a group transmission, it is possible to order these objects according to the "delivery order" that will provide the best experience, instead of merely sending them according to their planned replay time. For example, taking a simple example of a "time based" layering, we would want to first send all the 15 fps frames, then all the 30 fps frames, then all the 60 fps frames. The receiver will get the objects that fit in the available bandwidth, and then render the frames in their natural order, playing the whole group at either 15 fps, 30 fps, or 60fps.

This kind of planning in advance is not possible for real time conferences. If we want to target a latency of 100 or 200 ms, we can buffer at most 6 or maybe 12 frames, certainly not the whole group. The order of transmission will have to be rather close to the order of capture. If the bandwidth is limited, some content will have to be pruned "in real time" rather than waiting the end of the group.

# Unit of grouping tracks

Two views:

*  Emission (non conferencing)
*  Multiple Emissions and their tracks into one container (conferencing A/B)

# Handling Scalable Video Codecs

Some video codecs have a complex structure. Consider an
application using both temporal layering and spatial layering. It would
send for example:

* an object representing the 30 fps frame at 720p
* an object representing the spatial enhancement of that frame to 1080p
* an object representing the 60 fps frame at 720p
* an object representing the spatial enhancement of that 60 fps frame to
1080p

The encoding of the 30 fps frame depends on the previous 30 fps frames,
but not on any 60 fps frame. The encoding of the 60 fps depends on the
previous 30 fps frames, and possibly also on the previous 60 fps frames
(there are options). The encoding of the spatial enhancement depends on
the corresponding 720p frames, and also on the previous 1080p
enhancements. Add a couple of layers, and the
expression of dependencies can be very complex. The AV1 documentation for
example provides schematics of a video stream with 3 frame rate options at
15, 30 and 60 fps, and two definition options, with a complex graph of
dependencies. Other video encodings have similar provisions. They may
differ in details, but there are constants:
if some object is dropped, then all objects that have a dependency on it
are useless.

Of course, we could encode these dependencies as properties of the object
being sent, stating for example that "object 17 can only be decoded if
objects 16, 11 and 7 are available." However, this approach leads to a lot
of complexity in relays. We believe that a linear approach is
preferable, using attributes of objects like delivery order (as discussed
in {{planning-or-not}} or priorities.

## Application choice for ordering

The conversion from dependency graph to linear ordering is not unique.
The simple graph in our example could be ordered either "frame rate first"
versus "definition first". If the application chooses frame rate first,
the policy is expressed as "in case of congestion, drop the spatial
enhancement objects first, and if that is not enough drop the 60 fps frames".
If the application chooses "definition first", the policy becomes
"drop the 60 fps frames and their corresponding 1080p enhancement first,
and if that is not enough also drop the 1080p enhancement of the 30 fps frames".

More complex graphs will allow for more complex policies, maybe for example
"15 fps at 720p as a minimum, but try to ensure at least 30fps, then try to
ensure 1080p, and if there is bandwidth available forward 60 fps at 1080p".
Such linearization requires choices, and the choices should be
made by the application, based on the user experience requirements of
the application.

The relays will not understand all the variation of what the media is
but the applications will need a way to indicate to the relays the
information they will need to correctly order which data is sent first.

## Linear ordering using priorities

As explained in {{planning-or-not}}, if the application can accept a latency
larger than the duration of a group, it is possible to derive from the
preferences a preferred "delivery order", which then defines the number
assigned to the object in the group. However, this method cannot be used
when the latency targets are much lower than the duration of the group.
For those cases, we propose to use a combination of object number and
object priority.

Let's consider our example of an encoding providing both spatial enhancement and
frame rate enhancement options, and suppose that the application has expressed
a preference for frame rate. We can express that policy as follow:

* the frames are ordered first by time and when the time is the same by resolution.
  This determines the "object number" property.
* the frame priority will be set to 1 for the 720p 30 fps frame,
  2 for the 720p 60 fps frames, and 3 for all the enhancement frames.

If the application did instead express a preference for definition, object numbers
will be assigned in the same way, but the priorities will be different:

* the frame priority will be set to 1 for the 720p 30 fps I frames and 2
  for the 720p 30 fps P and B frames,
  3 and 4 for the 1080p enhancements of the 60 fps frames, and 5 and 6 for the 60 fps
  frames and their enhancements.

Object numbers and priorities will be set by the publisher of the track, and
will not be modified by the relays.

## Replay behavior

In case of congestion, the relay
will use the priorities to selectively drop the "least important" objects:

* if congestion is noticed, the relay will drop first the lesser priority
  layer. In our example, that would mean the objects marked at
  priority 6. The relay will drop all objects marked at that priority,
  from the first dropped object to the end of the group.

* if congestion persists despite dropping a first layer, the relay will
  start dropping the next layer, in our example the objects marked at
  priority 5.

* if congestion still persist after dropping all but the highest priority
  layer, the relay will have to close the group, and start relaying
  the next group.

When dropping objects within the same priority:

* higher object numbers in the same group, which are later in the group,
  are "less important" and more likely to be dropped than objects in the
  same group with a lower object number. Objects in a previous group are
  "less important" than objects in the current group and MAY be dropped
  ahead of objects in the current group.

The specification above assumes that the relay can detect the onset
of congestion, and has a way to drop objects. There are several ways to
achieve that result, such as sending all objects of a group in
a single QUIC stream and making explicit action at the time of
relaying, or mapping separate priority layers into different QUIC streams
and marking these streams with different priorities. The exact
solution will have to be defined in a draft that specifies transport
priorities.

# High Loss Networks

Web conferencing systems are used on networks with well over 20% packet
loss and when this happens, it is often on connections with a relatively
large round trip times. In these situtation, forward error correction or
redundant transmitions are used to provide a reasonable user
experience. Often video is turned off in. There are multiple machine
learning based audio codecs in development that targeting a 2 to 3 Kbps
rate.

This can result in scenarios where very small audio objects are sent at
a rate of several hundreds packets per second with a high network loss
rate.
