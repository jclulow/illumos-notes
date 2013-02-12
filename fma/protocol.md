# illumos FMA Protocol

The Fault Management Daemon (`fmd`), and various other components in the
Fault Management Architecture, communicate amongst themselves with a series
of event data structures.  These structures are generally passed around as
libnvpair(3LIB) name-value pair lists.

## Terminology

In order to understand the FMA, you must first understand some 'basic'
terminology.  This section seeks to shine a light on the nomenclature and
concepts most directly relevant to comprehending the FMA Event Protocol.

### Fault-Managed Resource Identifier (FMRI)

A data structure that uniquely identifies a _Resource_ in the system.
Within the Fault Manager itself (`fmd`), and in associated plugins, this
data is stored in an `nvlist_t`.  An FMRI has two primary components:

- A 'scheme', which identifies the class of _Resource_.
- Some set of properties which the scheme-specific code can use to describe
  and locate the _Resource_ that this _FMRI_ refers to.

A [URI][4]-like string may also be constructed from an _FMRI_, though these
often do not contain all of the data present in the original `nvlist_t`
structure.

The illumos Operating System presently supports at least the following FMRI
schemes.  The code that handles (and encodes/decodes) these schemes is a
part of [libtopo][5].

|| *Scheme*     || *Description* ||
|| `cpu`        || Processors ||
|| `dev`        || FMA-internal representation of `/devices` paths, etc. ||
|| `fmd`        || Fault Management Daemon (`fmd`) modules ||
|| `hc`         || A hierarchical tree of Hardware Components, based on physical topology. ||
|| `legacy-hc`  || ? ||
|| `mem`        || DIMMs and other Memory modules ||
|| `mod`        || ? ||
|| `pkg`        || Software packages installed on the system ||
|| `svc`        || smf(5) services present on the system ||
|| `sw`         || ? ||
|| `zfs`        || Tracks zfs(1M) file systems and zpool(1M) pools and vdevs ||

### Resource

Some discrete component in the system, be it hardware, software or some
other variety of component.

A _Resource_ is an abstract concept, realised in two specific types:

- Automated System Recovery Unit (ASRU)
- Field-Replaceable Unit (FRU)

<!-- XXX: is this actually true? -->

### Automated System Recovery Unit (ASRU)

A type of _Resource_ in the system that the Fault Manager may disable _without
operator intervention_ in response to a detected fault condition.  An _ASRU_ may
be partially present in a system, such as if it is composed of multiple
independent _FRUs_.  An _ASRU_ is identified by an _FMRI_.

Examples of an _ASRU_ may include: 

- a zpool(1M) composed of multiple child vdevs
- each individual MAC chip on a multi-port network interface card
- an smf(5) service

### Field-Replaceable Unit (FRU)

A type of _Resource_ in the system that may be removed, repaired or replaced
manually by an operator.  A _FRU_ is either wholly present in, or absent from,
the system.  A _FRU_ (pronounced _Froo!_) is identified by an _FMRI_.  

Examples of _FRUs_ may include: 

- a hard disk that forms part of a zpool(1M)
- a multi-port network card
- the main system board

### Error Numeric Association (ENA)

`XXX` -- Event Timing Data, etc.

### Resource Cache

The Fault Manager keeps a cache of _ASRUs_ in the system and records their last
known fault status.  This cache is implemented in [fmd\_asru.c][7], and is used
when the Fault Manager is starting or restarting.

### Diagnosis Engine

A module which receives _Error Reports_ and other telemetry via the Fault
Manager and groups them into _Cases_.

A _Diagnosis Engine_ is identified by an _FMRI_.

### Case

The state machine for a _Case_ is documented in [fmd\_case.c][6].  When a case
changes state, the Fault Manager may emit a relevant _List Event_
(`FM_LIST_EVENT`). A _Case_ may exist in these states:

|| *Symbol*              || *Description* ||
|| `FMD_CASE_UNSOLVED`   || ||
|| `FMD_CASE_SOLVED`     || ||
|| `FMD_CASE_CLOSE_WAIT` || ||
|| `FMD_CASE_CLOSED`     || ||
|| `FMD_CASE_REPAIRED`   || ||
|| `FMD_CASE_RESOLVED`   || ||

A _Case_ is identified by a UUID.

## Top-level Classes

The set of top-level record classes are defined in [sys/fm/protocol.h][1].

|| *Event Type* || *Symbol*           || *String Pattern* ||
|| List         || `FM_LIST_EVENT`    || `"list.*"`       ||
|| Error Report || `FM_EREPORT_CLASS` || `"ereport.*"`    ||
|| Information ? ||`FM_IREPORT_CLASS` || `"ireport.*"` ||
|| Fault        || `FM_FAULT_CLASS`   || ||
|| Defect       || `FM_DEFECT_CLASS`  || ||
|| Resource     || `FM_RSRC_CLASS`    || ||

### Common Structure

The core fields, common to all classes of record, are defined in
[sys/fm/protocol.h][1].

- `FM_CLASS` _(string)_; the class, or type, of an FM Record.
- `FM_VERSION` _(uint8)_; a versioning field, presently at `0`.

## List Events (`FM_LIST_EVENT`)

Records of the `FM_LIST_EVENT` class alert subscribers to changes in the FM
state machine -- cases opened, closed, etc.

### Subclasses

|| *Symbol*                 || *String*          ||
|| `FM_LIST_SUSPECT_CLASS`  || `"list.suspect"`  ||
|| `FM_LIST_ISOLATED_CLASS` || `"list.isolated"` ||
|| `FM_LIST_REPAIRED_CLASS` || `"list.repaired"` ||
|| `FM_LIST_UPDATED_CLASS`  || `"list.updated"`  ||
|| `FM_LIST_RESOLVED_CLASS` || `"list.resolved"` ||

### Common Structure

- `FM_SUSPECT_UUID` _(string)_
- `FM_SUSPECT_DIAG_CODE` _(string)_; an [encoded FMA Message ID][2].
- `FM_SUSPECT_DIAG_TIME` _(uint64[2])_; the timestamp for this record.
- `FM_SUSPECT_DE` _(fmri)_ -- the Diagnosis Engine responsible for this
  list.
- `FM_SUSPECT_FAULT_SZ` -- the length of the Fault List.
- `FM_SUSPECT_FAULT_LIST` _(nvlist[])_ -- the Fault List.
- `FM_SUSPECT_FAULT_STATUS` _(uint8[])_ -- a bit field for each entry in the
  `FAULT_LIST`, describing the status of that resource.
  See also: *FM_SUSPECT_FAULT_STATUS Bit Field*.
- `FM_SUSPECT_INJECTED` _(boolean)_ -- If absent, defaults to `B_FALSE`.
- `FM_SUSPECT_MESSAGE` _(boolean)_ -- should we print this message? If
  absent, defaults to `B_TRUE`.
- `FM_SUSPECT_RETIRE` _(boolean)_
- `FM_SUSPECT_RESPONSE` _(boolean)_
- `FM_SUSPECT_SEVERITY` _(string)_ ??

#### The `FM_SUSPECT_FAULT_STATUS` Bit Field

The `FM_SUSPECT_FAULT_STATUS` bit field is of the following form:

|| *Symbol*                 || *Value* || *Meaning*                   ||
||                          ||  `0x00` || component is ok             ||
|| `FM_SUSPECT_FAULTY`      ||  `0x01` || component has a fault       ||
|| `FM_SUSPECT_UNUSABLE`    ||  `0x02` || component disabled by fault manager ||
|| `FM_SUSPECT_NOT_PRESENT` ||  `0x04` || component is not present    ||
|| `FM_SUSPECT_DEGRADED`    ||  `0x08` || providing degraded service  ||
|| `FM_SUSPECT_REPAIRED`    ||  `0x10` || repair was attempted        ||
|| `FM_SUSPECT_REPLACED`    ||  `0x20` || component was replaced ?    ||
|| `FM_SUSPECT_ACQUITTED`   ||  `0x40` || ?                           ||

Some combinations of these bits have particular meaning, as [interpreted by
fmadm][3].  For example:

|| *Combination*       || *Meaning*                                    ||
|| `FAULTY`            || faulted but still in service                 ||
|| `FAULTY | DEGRADED` || faulted but still providing degraded service ||
|| `FAULTY | UNUSABLE` || faulted and taken out of service             ||

### Suspect List Event (`FM_LIST_SUSPECT_CLASS`)

Generated when a case 

## Error Reports (`FM_EREPORT_CLASS`)

### Sub-Classes

- `FM_ERROR_CPU`
- `FM_ERROR_IO`

## Faults (`FM_FAULT_CLASS`)

### Common Structure

 - `FM_FAULT_ASRU` _(fmri)_
 - `FM_FAULT_FRU` _(fmri)_
 - `FM_FAULT_FRU_LABEL`
 - `FM_FAULT_CERTAINTY`
 - `FM_FAULT_RESOURCE`
 - `FM_FAULT_LOCATION`

## Resource Events (`FM_RSRC_CLASS`)

|| *String*                      || *Description*                             ||
|| `"resource.fm.asru.ok"`       || ASRU is neither `UNUSABLE` nor `FAULTED`. ||
|| `"resource.fm.asru.degraded"` || ASRU is `FAULTED`, but not `UNUSABLE`.    ||
|| `"resource.fm.asru.unknown"`  || ASRU is `UNUSABLE`, but not `FAULTED`.    ||
|| `"resource.fm.asru.faulted"`  || ASRU is both `UNUSABLE` and `FAULTED`.    ||

### Subclasses



<!-- Links/References: -->

[1]: http://src.illumos.org/source/xref/illumos-gate/usr/src/uts/common/sys/fm/protocol.h

[2]: https://github.com/jclulow/node-fmamsg

[3]: http://src.illumos.org/source/xref/illumos-gate/usr/src/cmd/fm/fmadm/common/faulty.c

[4]: http://en.wikipedia.org/wiki/Uniform_resource_identifier

[5]: http://src.illumos.org/source/xref/illumos-gate/usr/src/lib/fm/topo/libtopo/common/

[6]: http://src.illumos.org/source/xref/illumos-gate/usr/src/cmd/fm/fmd/common/fmd_case.c#26

[7]: http://src.illumos.org/source/xref/illumos-gate/usr/src/cmd/fm/fmd/common/fmd_asru.c

<!-- vim: set tw=80 syntax=markdown: -->
