%%%
title = "MoQ Transport (moqt) - Unified Media Delivery Protocol over QUIC"
abbrev = "moqt"
ipr= "trust200902"
area = "transport"
workgroup = ""
keyword = ["realtime","moqt"]

[seriesInfo]
status = "informational"
name = "Internet-Draft"
value = "draft-nandakumar-moq-base-protocol"
stream = "IETF"

[[author]]
initials="S."
surname="Nandakumar"
fullname="Suhas Nandakumar"
organization = "Cisco"
  [author.address]
  email = "snandaku@cisco.com"

[[author]]
initials="C."
surname="Huitema"
fullname="Christian Huitema"
organization = "Private Octopus Inc."
  [author.address]
  email = "huitema@huitema.net"

%%%

.# Abstract

This specification defined MoqTransport (moqt), an unified media
delivery protocol over QUIC. It aims at supporting multiple application
classes with varying latency requirements including ultra low latency
applications such as interactive communication and gaming. It is based on a
publish/subscribe metaphor where entities publish and subscribe to data
that is sent through, and received from, relays in the cloud. The
data is delivered in the strict priority order. The information subscribed
to is named such that this forms an overlay information centric network.
The relays allow for efficient large scale deployments.


{mainmatter}

# Introduction

Recently new use cases have emerged requiring higher scalability
of delivery for interactive realtime applications and much lower
latency for streaming applications and a combination thereof. On one
side are use cases such as normal web conferences wanting to distribute
out to millions of viewers and allow viewers to instantly move
to being a presenter. On the other side are uses cases such as
streaming a soccer game to millions of people including people
in the stadium watching the game live. Viewers watching an e-sports
event want to be able to comment with minimal latency to ensure the
interactivity aspects between what different viewers are seeing
is preserved. All of these uses cases push towards latencies that are
in the order of 100ms over the natural latency the network causes.

Interactive realtime applications, such as web conferencing systems,
require ultra low latency (< 150ms) delivery. Such applications create
their own application specific delivery network over which latency
requirements can be met. Realtime transport protocols such as
RTP over UDP provide the basic elements needed for realtime
communication, both contribution and distribution, while leaving
aspects such as resiliency and congestion control to be provided
by each application. On the other hand, media streaming applications
are much more tolerant to latency and require highly scalable media
distribution. Such applications leverage existing CDN networks,
used for optimizing web delivery, to distribute media. Streaming
protocols such as HLS and MPEG-DASH operates on top of HTTP and
gets transport-level resiliency and congestion control provided
by TCP.

This specification defines MOQTransport, a publish and
subscribe based media delivery protocol over QUIC, where the
principal idea is entities publish unique named objects that
are end-to-end encrypted and consume data by subscribing to
the named objects. The names used are scoped and authorized
to the domain operating the application server (referred to as
Origin/Provider in this specification).

The published data carry metadata identifying relative priority,
time-to-live and other useful metadata that's authenticated
for components implementing Relay functions to make
drop/forwarding decisions. MoQTransport is designed to make it easy to
implement relays so that fail over could happen between relays
with minimal impact to the clients and relays can redirect a
client to a different relay.

# Terminology

* Provider server: Component managing/authoring the track Ids scoped under a
  domain for a specific application and is responsible for establishing
  trust between clients and relays for delivering media.

* Control Stream: QUIC Stream to exchange control
  message to setup appropriate context for media delivery and is scoped
  to a given QUIC Connection. Functionally, Control Messages enable authorization
  of names, setting up media properties and starting/terminating
  media sessions.

* Data Stream: QUIC Stream or QUIC Datagram based transport for
  delivering end to end encrypted application media objects. Such objects
  shall carry metadata (unencrypted) for Relays to make store/forwarding
  decisions along with the application payload.

* Provider: A provider is an entity which is capable of providing persistent group chat capabilities
  to a set of users that have signed up to their service. A provider offers its users both a client application and a backend cloud service that powers its client application. A provider is also capable of authenticating its users.



# Object Model

This section define various concepts that make up
object model enabling media delivery over QUIC.

## Tracks {#tracks}

Tracks form the central concept within the MoQ Transport
protocol for delivering media. A Track identifies the namespace
under which MoQ Media objects ((#objects)) are delivered.

A track is a transform of a Source Media Stream (RFC7656) using a
specific encoding process, a set of parameters for
that encoding, and possibly an encryption process.
The MoQ transport is designed to transport tracks.

Tracks have the following properties:

* Tracks MUST be owned by a single provider domain and sourced
  from a single Emitter within the owning provider domain.

* Tracks MUST have a single encoding and decoding configuration.

* Tracks MUST have a single security configuration.

Tracks are identified by a globally unique identifier,
called Track ID. Track ID MUST identify its owning provider
by a standardized identifier, such as domain name or equivalent,
then followed by the application context specific track name.


## Objects {#objects}

The binary content of a track is composed of a sequence
of objects. An Object is the smallest unit that makes
sense to decode and may not be independently decodable.
Object MUST belong to a group ((#groups))

Few examples, for video media an object could be an H.264
P frame or could be just a single slice from inside the
P Frame. For audio media, it could be a audio frame.

Objects are not partially decodable. The end to end
encryption and authentication ooperations are performed
across the whole object, thus rendering partial objects
shall not be possible.

Objects MUST be uniquely identifiable within the
MoQ delivery system. Objects carry associated header/metadata
containining priority/delivery order, time to live, and
other information aiding the caching/forwarding decision at
the Relays. Objects MAY be optionally cached at Relays.
Payload of objects are opaque to Relays.


## Object Groups {#groups}

An Object MUST belong to a group. Groups are composition of
objects and they carry the necessary dependecy information
needed to process the objects in the group. Objects that
carry information required to resolve dependecies are
marked appropriately in their headers. In cases where such information MAY NOT be available, the first object in the group MUST have all the dependency information needed to processs the
rest of the objects.

A group shall provide following utilities:

* Subscribers to specifiy the appropriate consumption point
  for enabling joins, rewinds and replay the objects, for
  certain video media usecases.

* Specify refresh points serving as decode points, switching
  between qualties for audio/video media

* Serve as checkpoint for relays to implement appropriate
    congestion responses.


## Track Bundle

Tracks can be bundled together to satisy certain application
requirements

### Scalable Codecs and relation to the tracks


# Concepts

## Emitter and Emission {#emission}

An Emission represents a collection of tracks sourced by an
Emitter and owned by an application Provider.
An Emitter MUST be authorized to publish objects of the
tracks in a Emission. An Emitter can have one or more emissions.

Few example of Emissions include,

 - Collection of audio and video tracks that makes up
   a broadcast for a live stream by OBS client,
   the Emitter, to provider, say Twitch.

-  Tracks from different participants (emitters) in
   a interactive video conference


## Catalog {#catalog}

Catalog is a MOQ object scoped to a MoQ Session ((#session)) that provides information about tracks from one of more Emissions and is used by the subscribers for consuming tracks.


## MoQ Session {#session}

A MoQ Session is a top level container under an application Provider that represetns one or more emitters, their tracks, optionally a set of participating relays, and set of receviers that are interested in the content being published.

# Protocol Design {#protocol}

Media delivery is started by the publisher/subscriber setting
up a "Control Stream" for one or more Tracks. The control stream,
which is based on QUIC stream, is used to configure and setup properties for
the "Data Stream". Track media objects is delivered over one or more
"Data Streams" which are unidirectional QUIC streams.
The Control Channel can also be used to configure in-session parameters.

## Control Stream and Messages

The client starts by opening a new bilateral stream, acting as
the "control stream" for the exchange of data, carrying a series of
control messages in both directions.

The control stream is created for one or more tracks to be published
or subscribed to and will remain open as long as the peers are still
sending or receiving the media. If either peer closes the control
stream, the other peer will close its end of the stream and discard
the state associated with the media transfer.

Streams are "one way". If a peer both sends and receive media, there will
be different control streams for sending and receiving.

The control channel carry series of messages, encoded as a length followed
by a message value:

```
message {
    length(16),
    value(...)
}
```

The length is encoded as a 16 bit number in big endian network order.

Below sub-sections define various control messages defined in
this specification.

### Catalog Message {#catalog}

```
catalog {
  message_type(i),
  catalog_legnth(i),
  catalog(...)
}
```

### Subscribe Message {#subscribe}

Entities that intend to receive media  will do so via
subscriptions to one or more Tracks.

```
enum subscribe_intent
{
  immediate(0),
  catch_up(1),
  wait_up(2),
}

track_info {
  track_id_length(i),
  track_id(...)...,
  subscribe_intent intent
}

subscribe_message {
  message_type(i),
  tracks_length(i),
  track_info tracks (...),
}
```

TODO: Add authz information

The message type will be set to SUBSCRIBE. `tracks` identifies the
list of tracks as defined in `track_info` type.

The `track_id` captures the Track ID and the `intent` field specifies
the intended consumption point.

Following options are defined for the `intent`

- immediate: Deliver any new objects it receives for a given track.

- catch_up: Deliver any new objects it receives and in addition send
  any previous objects it has received, beginning from the most
  recent group and matching the given track.

- wait_up: Wait until next group before delivering the objects.

Subscriptions are typically long-lived transactions and they stay
active until one of the following happens

   - a client local policy dictates expiration of a subscription.

   - optionally, a server policy dictates subscription expiration.

   - the underlying transport is disconnected.

The `subscribe` message is sent over the associated control
stream and the same is closed when the subscriptions for
the tracks includes are no longer required. This implies
the termination of all associated data streams.


TODO Add the flexibility on using one track per subscribe vs multiple

TODO: provide more details on authorization flows.

#### Aggregating Subscriptions

Subscriptions are aggregated at entities that perform Relay Function.
Aggregating subscriptions helps reduce the number of subscriptions
for a given track in transit and also enables efficient
distribution of published media with minimal copies between the
client and the origin server/ or other relays, as well as reduce the
latencies when there are multiple subscribers for a given namespace
object behind a given cloud server.


### SUBSCRIBE_REPLY Message

A `subscribe_reply` provides result of the subscription and is sent
on the control stream over which the `subscribe` control message was received.

```
enum response
{
  ok(0),
  expired(1),
  fail(2)
}

track_response {
  track_id_length(i),
  track_id(...)...,
  Response response,
  [Reason Phrase Length (i)],
  [Reason Phrase (...)],
  [media_id(i)]
}

subscribe_reply
{
  message_type(i),
  track_response tracks(...)
}
```

`tracks` capture the result of subscription per track included
in the `subscribe` message.

For each track, the `track_response` provides result of
subscripion in `response` field, where a response of `ok`
indicates successful subscription, for `failed`
or `expired` responses and "Reason Phrase" shall be populated
with appropriate reason.

The `media_id` for a given track is populted for a successful
subscription and represents an handle to the subscription to be
provided by the peer over the data streams(s). Given that the
media corresponding to a track can potentially arrive over
multiple data streams, the `media_id` provides the necessary
mapping between the control stream and the corresponding data streams.
It also serves as compression identifier for containing the size
of object headers instead of carrying complete track identifier
information in every object message.


While the subscription is active for a given name, the Relay(s)
must send objects for tracks it receives to all the matching subscribers.

Optionally, a client can refresh its subscriptions at any point
by sending a new `subscribe_message`.

### PUBLISH REQUEST Message.

The `publish_request` message provides one or more
Tracks that the publisher intends to publish data.


```

track_info {
  track_id_length(i),
  track_id(...)...,
  media_id(i),
}

publish_request {
  message_type(i),
  track_info tracks(...),
}
```

TODO: Add authz details

The message type will be set to PUBLISH\_REQUEST (6). `tracks` identifies the list of tracks. The `media_id` represents an handle to the track to be used over the data streams(s). Given that media corresponding to the track can potentially be sent over multiple data streams, the `media_id` provides the necessary mapping between the control stream and the associated data streams. `media_id` also serves as compression identifier for containing the size of object headers instead of carrying full formed Track Id in every object.

The `publish_request` message is sent on its own control stream and
akin to subscribes, the control stream's lifecycle bounds
the media transfer state. Terminating the control stream implies
closing of all the associated data streams for the tracks included
in the request.


### PUBLISH_REPLY Message.

`publish_reply` provides the result of intent to publish
on the track(s) in the `publish_request`. The `publish_reply`
control message is sent over the same control stream the
request was received on.

```
track_response {
  track_id_length(i),
  track_id(...)...,
  Response response,
  [Reason Phrase Length (i)],
  [Reason Phrase (...)],
}


publish_reply {
  message_type(i),
  track_response tracks(...),
}
```


The message id is set to PUBLISH\_REPLY (7).

`tracks` capture the result of publish request per track included
in the `publish_request` message.

For each track, the `track_response` provides result of
subscripion in `response` field, where a response of `ok`
indicates successful subscription, for `failed`
or `expired` responses and "Reason Phrase" shall be populated
with appropriate reason.

While the publishing objects is active for a given track, the Relay(s)
MUST send objects for tracks it receives to all the matching subscribers.


#### Implementation Note

### RELAY_REDIRECT MESSAGE

`relay_redirect` control message provides an explicit signal to
indicate relay failover scenarios. This message is sent on
all the control streams that would be impacted by reduced
operations of the Relay.

```
relay_redirect
{
  message_type(i),
  relay_address_length(i),
  relay_address(...)
}
```

## Data Stream and Messages {#data}

### Group Header

The first message on each Warp header is encoded as:
```
group_header_message {
  message_type(i),
  media_id(i),
  group_id(i)
}
```
The message type is set to GROUP_HEADER, 12.


### Object header

Each object in the stream is encoded as an Object header, followed by
the content of the object. The Object header is encoded as:
```
quicrq_object_header_message {
  message_type(i),
  object_id(i),
  [nb_objects_previous_group(i),]
  flags[8],
  object_length(i)
}
```

### Fragment Message

The Fragment message is used to convey the content of a media stream as a series
of fragments:

```
quicrq_fragment_message {
  message_type(i),
  [media_id(i)],
  [group_id(i)],
  [object_id(i)],
  fragment_offset(i),
  object_length(i),
  fragment_length(i),
  data(...)
}
```

The message type will be set to FRAGMENT (5).

The offset value indicates where the fragment
data starts in the object designated by `group_id` and `object_id`.
Successive messages are sent in order, which means one of the
following three conditions must be verified:

* The group id and object id match the group id and object id of the
  previous fragment, the previous fragment is not a `last fragment`,
  and the offset matches the previous offset plus the previous length.
* The group id matches the group id of the previous message, the
  object id is equal to the object id of the previous fragment plus 1,
  the offset is 0, and the previous message is a `last fragment`.
* The group id matches the group id of the previous message plus 1,
  the object id is 0, the offset is 0, and the previous message is a
  `last fragment`.

The `nb_objects_previous_group` is present if and only if this is
the first fragment of the first object in a group, i.e., `object_id`
and `offset` are both zero. The number indicates how many objects
were sent in the previous groups. It enables the receiver to check
whether all these objects have been received.

The `flags` field is used to maintain low latency by selectively
dropping objects in case of congestion. The value must be the same
for all fragments belonging to the same object.

The flags field is encoded as:
```
{
    maybe_dropped(1),
    drop_priority(7)
}
```

The high order bit `maybe_dropped` indicates whether the object can be dropped. The `drop_priority` allows nodes to selectively drop objects. Objects with the highest priority as dropped first.

When an object is dropped, the relays will send a placeholder, i.e.,
a single fragment message in which:

* `offset_and_fin` indicates `offset=0` and `fin=1`
* the `length` is set to zero
* the `flags` field is set to the all-one version `0xff`.

Sending a placeholder allows node to differentiate between a
temporary packet loss, which will be soon corrected, and a
deliberate object drop.

## Sending objects over streams considerations {#stream-considerations}

This section is non-normative and provided for
Applications can choose to define the mapping of the Objects onto
the Data Streams, as they see fit as driven by the use-case
requirements.

Certain applications can choose to send each group in their own
unidirectional QUIC stream. In such cases, stream will start with
a "group header" message specifying the media ID and the group ID,
followed for each object in the group by an "object header"
specifying the object ID and the object length and then the content
of the objects (as depicted below)

```
+--------+------------+-------+------------+-------+------
| Group  | Object     | Bytes | Object     | Bytes |
| header | header (0) |  (0)  | header (1) |  (1)  | ...
+--------+------------+-------+------------+-------+------
```

The first object in the stream is object number 0, followed by 1, etc.
Arrival of objects out of order will be treated as a protocol error.

Alternatively, certain applications can choose to send each object
in its own unidirectional QUIC stream. In such cases, each stream
will start with a "group header" message specifying the
media ID and the group ID, followed by a single "object header"
and then the content of the objects (as depicted below).

```
+--------+------------+-------+
| Group  | Object     | Bytes |
| header | header (n) |  (n)  |
+--------+------------+-------+
```

The MOQTransport doesn't enforce a rule to follow for the applications,
but instead aims to provide tools for the applications to make
the choices appropriate for their use-cases.

# Priority

In case of congestion, the MoQ nodes may have to drop some traffic in
order to avoid building large queues. The drop algorithm must respect
the relative importance of objects within a track, as well as the relative
importance of tracks within an MoQ connection. Relays base their
decisions on two propertes of objects:

* a "droppable" flag, which indicates whether the application would
  rather see the object queued (droppable=False) or dropped (droppable=True)
  in case of congestion.

* a "priority" value, which indicates the relative priority of this
  object versus other objects in the track or other tracks in the connection.

Higher values of the priority field indicate higher drop priorities: objects
mark with priority 0 would be the last to be dropped, objects marked with
priority 3 would be dropped before dropping objects with priority 2, etc. Nodes
support up to 8 priority levels, numbered 0 to 7.

Nodes may use priorities in two ways: either by delegating to the QUIC stack, or
by monitoring the state of congestion and performing their own scheduling.

## Applying priorities through the QUIC stack

Many QUIC stack allow application to associate a priority with a stream.
The MoQ transports can use that feature to delegate priority enforcement
to the QUIC stack. The actual delegation depends on the transport choice.

If the MoQ transport uses the strategy where each object is transmitted
on a separate unidirectional QUIC stream, then that stream should be marked
with the object's priority. The QUIC API should be set to request FIFO ordering
of streams within a priority layer.

If all the objects of a given group, say GOP, within a track are sent in a
single unidirectional QUIC stream. This strategy can be modified to be
priority aware. In a priority aware strategy, there will
be one unidirectional stream per group and per priority level, and the priority
of the unidirectional stream will match that level.

In both cases, if congestion happens, objects marked as "droppable" will have
be dropped by resetting the corresponding unidirectional streams. This decision
will happen separately for each track, typically at the end of a group. At that
point, the decision depends on whether the content of the unidirectional streams
have been sent or not:

* if all objects have been sent, the stream can be closed normally.
* if some objects have not been sent, or not acknowledged, the stream shall
  be reset, causing the corresponding objects to be dropped.

These policies will normally ensure that for any congestion state, only the
most urgent objects are sent.

## Applying priorities through active scheduling

Some transport strategies prevent delegation of priority enforcement to the
QUIC stack. For example, if the policy is to use a single QUIC stream or
a single stream carrying objects of different priorities. In such cases,
nodes react to congestion by scheduling some objects for transmission and explicitly dropping other objects.

Node should schedule objects as follow:

* if congestion is noticed, the node will delay or drop first the numerically higher
  priority level. The node will drop all objects marked at that priority,
  from the first dropped object to the end of the group.

* if congestion persists despite dropping or delaying the "bottom" level, the node will
  start dropping the next level, and continue doing so until the end of the group.

* if congestion eases, the node will increase the delay or drop level.

While the "drop level" is computed per connection, specific actions will have
to be performed at the "track" level:

* for a given track, the node remembers the highest priority level for which
  objects were dropped in the current group. That level will be
  maintained for that track until the end of the group.

* at the beginning of a group, the priority level is set to the currently computed
  value for the connection.

## Tracking drops

For management purposes, it is important to indicate which objects have been
dropped, as in "there was supposed to be here an object number X or priority P
but it has been dropped." In the scheduling approach, this can be achieved by
inserting a small placeholder for the missing object. In the delegating approach,
we need another solution. One possibility would be to send a "previous group summary"
at the beginning of each group, stating the expected content of the previous group.

## Marking objects with priorities

The publishers mark objects with sequence numbers within groups and with
drop and priority values according to the need of the application. This marks
must be consistent with the encoding requirements, making sure that:

* objects can only have encoding dependencies on other objects in the
  same group,

* objects can only have encoding dependencies on other objects with lower
  sequence numbers

* objects can only have encoding dependencies on other objects with equal or
  or numerically lower priority levels.

With these constraints, applications have broad latitude to pick priorities
in order to match the desired user experience. When using scalable video codecs,
this could mean for example chosing between "frame rate first" or "definition
first" priorities, or some compromise.

# Relay Function and Relays {#relay_behavior}

The Relays receive subscriptions and intent to publish request and
optionaly forward them towards the origin for authorization. Subscriptions
received are aggregated. When a relay receives a publish request with
data, it will forward it both towards the Origin and to any clients
or relays that have a matching subscription. This "short circuit" of
distribution by a relay before the data has even reached the
Origin servers provides significant latency reduction for nearby client.
Relays MAY cache some of the information for short period of time and
the time cached may depend on the Origin. The Relay keeps an outgoing
queue of objects to be sent to the each subscriber and objects are sent
in priority order.


At a high level, Relay Function within QuicR architecture support store and
forward behavior. Relay function can be realized in any component of the
QuicR architecture depending on the application. Typical use-cases might
require the intermediate servers (caches) and the origin server to implement
the relay function. However the endpoint themselves can implement the Relay
function in a Isomorphic deployment, if needed.

The relays are capable of receiving data in stream mode or in datagram mode.
In both modes, relays will cache and deliver fragments as they arrive.



## Relay or Cache or  Drop Decisions

Relays makes use of priority, time-to-live, is_discardable metadata properties
from the published data to make forward or drop decisions when reacting to
congestion as indicated by the underlying QUIC stack. The same can be used to
make caching decisions.

## Cache cleanup

Relays store objects no more than `best_before` time associated with the
object. Congestion/Rate control feedback can further influence what
gets cached based on the relative priority and rate at which data
can be delivered. Local cache policies can also limit the amount and
duration of data that can be cached.


## Relay fail over

A relay that wants to shutdown shall use the redirect message to move traffic
to a new relay. If a relay has failed and restarted or been load balanced
to a different relay, the client will need to resubscribe to the new relay
after setting up the connection.

TODO: Cluster so high reliable relays should share subscription info and
publication to minimize of loss of data during a full over.

## Relay Discovery

TODO

# Usages

Following subsections define usages of the MoQTransport over
WebTransport and over raw QUIC.

## WebTransport

WebTransport provides protocol framework that enables clients constrained
by the Web security model to communicate with a remote server using a secure multiplexed transport. WebTransport protocol also provides support for unidirectional streams, bidirectional streams and datagrams, all multiplexed within the same HTTP/3 connection.

MoqTransport uses WebTransport over HTTP/3 transport.


### Setup

Clients (publishers and subscribers) setup WebTransport Session
via HTTP CONNECT request to the application provided MoQSession and
provide the necessary authentication information
(in the form of authentication token) to securely connect to
the server. In case of any errors, the session is terminated and
reported to the application.


### Subscribers

On a successful connection, subscribers proceed by retrieving the
catalog (if not already retrieved), subscribing to the tracks of
thier interest and consuming the data published as detailed below.

### Catalog Retrieval

Catalog provides the details of tracks such as Track IDs and corresponding
configuration details (audio/video codec detail, gamestate encoding details,
for example).

Catalogs are identifed as a special track, with the track name as "catalog".
Catalog objects are retrived by subscribing to its TrackID over
its own control channel and the TrackID is formed as shown below

```
Catalog TrackID := <provider-domain>/<emission-id>/catalog

Ex: streaming.com/emission123/catalog
```

A successful subscription will lead to one or more catalog
objects being published on a single unidirectional data stream,
identified by its `media_id`. Successful subscriptions implies
authorizaiton for subscrbing to the tracks in the catalog.

Unsuccessful subscriptions MUST result in closure of the
WebTransport session, followed by reporting the error obtained
to the application.

Catalog Objects obtained MUST parse successfully, otherwise
MUST be treated as error, thus resulting the closure of the WebTransport
session.

### Subscribing to Media

Once a catalog is successfully parsed, subscribers proceed to
subscribe to the tracks listed in the catalog. Applications
can choose to use the same WebTransport session or multiple of
them to perform the track subscriptions based on the application
requirements.

Tracks subscription by sending `subscribe` message as defined
in ((#subscribe))

On successful subscription, subscribers should be ready to
consume media on one or more Data Streams as identified by their
`media_id`s.

Failure to subscribe MUST result on closure of the control stream
associated with the track whose subscription failed and the error MUST
be reported to the application.

## Publishers

On a successful connection and authorization, publishers
publish their catalog
and on successful authorization, proceed with publish objects.

### Publishing Catalog

Catalogs are identifed as a special track, with the track name
as "catalog". Catalog objects are published by sending a
`catalog` message on its own control channel and the TrackID
is formed as shown below

```
Catalog TrackID := <provider-domain>/<moq-session-id>/catalog

Ex: streaming.com/session123/catalog
```

A successful publishing will authorize the publisher to
the publish objects for tracks listed in the catalog.

Unsuccessful `catalog`  MUST result in closure of the
WebTransport session, followed by reporting the error
obtained to the application.

Note that applications MAY choose to get the initial
catalog from out of band mechanisms that is out of scope
for this specification.

### Publishing Media

Once a catalog is successfully authorized,
send `publish_request` message listing the tracks
they intend to publish. A sucessfull `publish_reply`
allows publishers to publish on the tracks. This
exchange of `publish_request` enables Relays to be
aware of tracks to expect publishes on and thus
explicitly signal the willingness to participate
in the media delivery for the advertised tracks.
This is due to the fact that, catalog messages are
opaque to Relays and `publish_request` will ensure
the appropriate authorization. For the scenarios,
where the initial catalog message is obtained
out of band, the exchange of `publish_request`
is important to setup neeede authorization for
publishes.



Publishing objects on the tracks follow the procedures
defined in ((#data)) and ((#stream-considerations)).


## MoQTransport over QUIC

MoQTransport can be used to deliver media over raw QUIC.
This document describes version "0.1" of the MoQTransport protocol,
negotiated using ALPN "moqt-01"

TODO Fill this section.

{backmatter}


# Acknowledgments

Thanks to Cullen Jennings, Mo Zanaty for contributions and suggestions to this
specification.

