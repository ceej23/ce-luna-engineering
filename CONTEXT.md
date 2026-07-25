# Engineering Workflow Assessment

This context names the evidence and learning concepts used to assess the CE +
Sol/Luna engineering workflow without changing delivery authority.

## Language

**Engineering Run**:
A single execution of the engineering lifecycle, correlated from framing
through evidence sealing.
_Avoid_: Job, session

**Evidence Bundle**:
The sealed, privacy-minimised lifecycle facts produced by one Engineering Run.
_Avoid_: Transcript, trace, log

**Validated Summary**:
The immutable, redacted conformance facts derived deterministically from one
Evidence Bundle.
_Avoid_: Score, model assessment

**Assessment Window**:
A declared time span whose Validated Summaries are evaluated together for
recurring workflow outcomes and improvement opportunities.
_Avoid_: Monitoring period, telemetry window

**Coverage Gate**:
The minimum sufficient set of Validated Summaries required before an Assessment
Window may produce an Improvement Proposal.
_Avoid_: Sample threshold, confidence score

**Recurring Signal**:
The same evidence-backed workflow pattern present in consecutive Assessment
Windows.
_Avoid_: Trend score, anomaly

**Improvement Proposal**:
A report-only recommendation produced from an Assessment Window and requiring
separate approval before it becomes engineering work.
_Avoid_: Automatic fix, policy mutation
