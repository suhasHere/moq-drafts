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

## Linear ordering using priorities

For scheduling and adaptation to congestion, we propose to use a combination of object number and
object priority.

Let's consider our example of an encoding providing both spatial enhancement and
frame rate enhancement options, and let's also suppose that the application has expressed
a preference for frame rate. We can express that policy as follow:

* the frames are ordered first by time and when the time is the same by resolution.
  This determines the "object number" property.
* the frame priority will be set to 1 for the 720p 30 fps frame,
  2 for the 720p 60 fps frames, and 3 for all the enhancement frames.

If the application did instead express a preference for definition, object numbers
will be assigned in the same way, but the priorities will be different:

* the frame priority will be set to 1 for the 720p 30 fps frame,
  2 for the 1080p enhancements of the 60 fps frames, and 3 for the 60 fps
  frames and their enhancements.

Object numbers and priorities will be set by the publisher of the track, and
will not be modified by the relays. 

## Replay behavior

In case of congestion, the relay
will use the priorities to selectively drop the "least important" objects:

* if congestion is noticed, the relay will drop first the lesser priority
  layer. In our example, that would mean the objects marked at
  priority 3. The relay will drop all objects marked at that priority,
  from the first dropped object to the end of the group.

* if congestion persists despite dropping a first layer, the relay will
  start dropping the next layer, in our example the objects marked at
  priority 2.

* if congestion still persist after dropping all but the highest priority
  layer, the relay will have to close the group, and start relaying
  the next group.

The specification above assumes that the relay can detect the onset
of congestion, and has a way to drop objects. There are several ways to
achieve that result, such as sending all objects of a group in
a single QUIC stream and making explicit action at the time of
relaying, or mapping separate priority layers into different QUIC streams
and marking these streams with different priorities. The exact
solution will have to be defined in a draft that specifies transport
priorities.





