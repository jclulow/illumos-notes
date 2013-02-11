# illumos FMA Protocol

The Fault Management Daemon (fmd), and various other parts of the FM system,
communicate with a serious of data structures.  These data structures are
generally passed around as libnvpair(3LIB) name-value pair lists.

## Common Structure

The core fields, common to all classes of record, are defined in
[sys/fm/protocol.h][1].

- `FM_CLASS` _(string)_; the class, or type, of an FM Record.
- `FM_VERSION` _(uint8)_; a versioning field, presently at `0`.

## Top-level Classes

The set of top-level record classes are defined in [sys/fm/protocol.h][1].

- `FM_EREPORT_CLASS`; an Error Report record.  Generally posted by some part
  of the operating system kernel.
- `FM_FAULT_CLASS`
- `FM_DEFECT_CLASS`
- `FM_RSRC_CLASS`
- `FM_LIST_EVENT`
- `FM_IREPORT_CLASS`

## The `FM_LIST_EVENT` Class

Messages of the `FM_LIST_EVENT` class alert subscribers to changes in the FM
state machine -- cases opened, closed, etc.

### Common Structure

- `FM_SUSPECT_UUID` _(string)_
- `FM_SUSPECT_DIAG_CODE` _(string)_; an [encoded FMA Message ID][2].
- `FM_SUSPECT_DIAG_TIME` _(uint64[2])_; the timestamp for this record.
- `FM_SUSPECT_DE`
- `FM_SUSPECT_FAULT_LIST`
- `FM_SUSPECT_FAULT_SZ`
- `FM_SUSPECT_FAULT_STATUS`
- `FM_SUSPECT_INJECTED`
- `FM_SUSPECT_MESSAGE`
- `FM_SUSPECT_RETIRE`
- `FM_SUSPECT_RESPONSE`
- `FM_SUSPECT_SEVERITY`

### Subclasses

- `FM_LIST_SUSPECT_CLASS`
- `FM_LIST_ISOLATED_CLASS`
- `FM_LIST_REPAIRED_CLASS`
- `FM_LIST_UPDATED_CLASS`
- `FM_LIST_RESOLVED_CLASS`

## `FM_EREPORT_CLASS` Sub-Classes

- `FM_ERROR_CPU`
- `FM_ERROR_IO`




## References

[1]: http://src.illumos.org/source/xref/illumos-gate/usr/src/uts/common/sys/fm/protocol.h

[2]: https://github.com/jclulow/node-fmamsg

<!-- vim: set tw=76 syntax=markdown: -->
