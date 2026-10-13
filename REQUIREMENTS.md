# Product Requirements

This document owns functional and nonfunctional product behavior and acceptance criteria. [SECURITY.md](SECURITY.md) exclusively owns security requirements, permissions, disclosure, privacy and regulatory controls. [DESIGN.md](DESIGN.md) owns presentation and accessibility; [ARCHITECTURE.md](ARCHITECTURE.md) owns implementation choices. Authority and authoring conventions: [AGENTS.md](AGENTS.md).

## Required Requirement Inputs

- Purpose: Manage tennis tournaments with eight players at the start of play, participant names, matches, scoreboard, statistics, world/local rankings, match plans, merchandising and beer garden management.
- Actor categories: Players, judges, admin, press, trainers and audience; categories are not themselves access grants. Permissions and account relationships: [SECURITY.md](SECURITY.md#access-and-disclosure-policy).
- Business records: Tournaments, participants and supplied names, matches, plans, scores/completed results, statistics and rankings; catalog items, stock adjustments, sales, menu entries and orders as defined below.
- External integrations and unprovided measurable nonfunctional targets: TO BE DECIDED (OQ-17 and OQ-19).
- Security/authentication and regulatory/privacy decisions: [SECURITY.md](SECURITY.md#open-security-questions).
- Trace: Original project notes quoted in FR-1.1–FR-4.2; later human decisions (2026-10-13) allow incomplete drafts and set the start condition. FR-5 through FR-8 resolve launch scope under the user's explicit best-judgment delegation. Security policy has its own source trace.

# Functional Requirements

All operations below are subject to the owner policy in [SECURITY.md](SECURITY.md#access-and-disclosure-policy); this document does not grant permissions.

### Tournament Participation

- **FR-1.1** The system MUST allow incomplete tournament drafts and require exactly eight assigned players before play starts.
  - **Acceptance criteria:** Saving a draft with zero through seven players succeeds. Starting with fewer or more than eight is rejected without starting play; starting with exactly eight satisfies this participant-count precondition. Other start preconditions remain OQ-1/OQ-2/OQ-10.
  - **Trace:** “8 players per tournament”; subsequent human lifecycle clarification. Draft maximum and post-start substitutions remain OQ-4.
- **FR-1.2** The system MUST identify participants by their supplied names.
  - **Acceptance criteria:** Each assigned participant's supplied name is available in tournament participant information, including incomplete drafts.
  - **Trace:** “players names.”
- **FR-1.3** The system MUST support creating a draft and assigning participants to it.
  - **Acceptance criteria:** Creating a tournament returns its stable reference and draft state; assigning a participant associates that participant and supplied name with the referenced draft and is reflected on the next retrieval. Additional tournament fields and name identity rules remain OQ-3/OQ-5.

### Matches and Match Plan

- **FR-2.1** The system MUST provide a viewable match plan identifying the competing participants for each listed match.
  - **Acceptance criteria:** Retrieving a defined plan identifies every listed match and its competing participants.
  - **Trace:** “they play against each other”; “match plan.”
- **FR-2.2** The system MUST support entering and changing a match plan.
  - **Acceptance criteria:** A change satisfying the eventually defined format and lifecycle rules replaces the applicable plan information on next retrieval. Rejected changes leave the prior plan intact. Plan generation, scheduling fields and post-start changes remain OQ-8/OQ-9.

### Scoreboard

- **FR-3.1** The system MUST display available match scores with the corresponding match and competing participants.
  - **Acceptance criteria:** The scoreboard associates each available score with its match and participants.
  - **Trace:** “scoreboard”; “players names, they play against each other.”
- **FR-3.2** The system MUST support entering and correcting scores and completed match results.
  - **Acceptance criteria:** An accepted entry/correction is returned on next retrieval; a rejected entry leaves the prior result intact. Completed results identify winning and losing participants without counting a participant on both sides. Tennis scoring and completion rules remain OQ-10; these rules do not choose singles or doubles.

### World and Local Rankings

- **FR-4.1** The system MUST present available world ranking information with explicit world scope.
  - **Acceptance criteria:** Users viewing available world ranking information can identify its world scope.
  - **Trace:** “world and local ranking.”
- **FR-4.2** The system MUST present available local ranking information with explicit local scope.
  - **Acceptance criteria:** Users viewing available local ranking information can identify its local scope.
  - **Trace:** “world and local ranking.”

### Tournament Statistics

- **FR-5.1** The system MUST provide per-tournament, per-participant completed matches played, wins, losses and win percentage derived from recorded completed results.
  - **Acceptance criteria:** A participant's played count is wins plus losses; each completed match counts once for each recorded winning/losing participant. Scheduled/in-progress matches do not contribute. Win percentage is wins / played × 100 rounded to one decimal; with no completed matches it is unavailable (counts are zero). A corrected result changes the next retrieved totals without retaining the old contribution. This does not define ranking algorithms or match format.

### Merchandising

- **FR-6.1** The system MUST maintain catalog entries with stable item reference, name, nonnegative unit price, currency and nonnegative integer stock, supporting edits and reasoned stock adjustments.
  - **Acceptance criteria:** Creation and valid edits are reflected on retrieval. An adjustment records its reason and resulting stock; negative resulting stock or noninteger quantities are rejected without change.
- **FR-6.2** The system MUST record a merchandise sale against a unique sale reference, item and positive integer quantity, preserving the item's price/currency at acceptance and decrementing stock once.
  - **Acceptance criteria:** With sufficient stock, one sale and the corresponding decrement result. Insufficient stock leaves both unchanged. Repeating the same reference and content returns the established result; conflicting reuse is rejected. Later item edits do not alter the sale snapshot. Refunds, returns and sale reversals are outside launch scope.
- **FR-6.3** The system MUST report quantities sold by item and sale totals separately per currency.
  - **Acceptance criteria:** Each accepted sale contributes quantity and quantity × snapshot unit price once. Unlike currencies are never summed into one total.

### Beer Garden

- **FR-7.1** The system MUST maintain menu entries with stable reference, name, nonnegative unit price and currency, supporting creation and edits.
  - **Acceptance criteria:** Valid changes appear on retrieval; changing a menu entry does not change existing order snapshots.
- **FR-7.2** The system MUST create orders with a stable reference, one or more positive-integer-quantity menu lines, a single currency and price snapshots from the menu at order creation; orders start open.
  - **Acceptance criteria:** A valid order preserves its lines, prices and currency on retrieval. Empty orders, invalid quantities or mixed currencies are rejected. No customer identity is required. Lines are fixed after creation; cancel and create a new order to replace them.
- **FR-7.3** The system MUST support open → completed or open → cancelled transitions, with exactly one sale record on completion and none on cancellation.
  - **Acceptance criteria:** Completion contributes the order's snapshot total once; repeated completion returns the established result. Cancellation contributes no sale. Completed/cancelled orders cannot be reopened or switched to the other terminal state. Repeated cancellation returns the cancelled state.
- **FR-7.4** The system MUST show order status and completed beer-garden sales totals per currency.
  - **Acceptance criteria:** Open/cancelled orders contribute nothing; completed orders contribute once. Currency totals remain separate. Ingredient inventory, bookings, delivery and loyalty are outside launch scope.

### Commerce Outcomes

- **FR-8.1** The system MUST distinguish confirmed, rejected and unresolved mutation outcomes and support resolving an uncertain sale/order outcome using its stable reference without duplicate effects.
  - **Acceptance criteria:** After a response timeout, reference-based retrieval or resubmission identifies the recorded outcome or explicitly reports it unresolved; it never claims rejection merely because a response was lost. The same completed operation cannot produce a second sale or decrement. Rejected operations leave no partial business change.
- **FR-8.2** Launch commerce MUST record sales without online payment processing or payment-provider integration.
  - **Acceptance criteria:** The catalog/sale/order workflows complete without collecting payment credentials or invoking a payment provider. A recorded sale means a business sales record, not verification of settlement. Configured currencies and their supported monetary precision are TO BE DECIDED; calculations must preserve exact amounts at that precision.

# Open Questions

- **OQ-1 — TO BE DECIDED:** What tournament format is required: every player against every other, or another format?
- **OQ-2 — TO BE DECIDED:** Singles, doubles or both; if doubles, how are the eight players assigned to teams?
- **OQ-3 — TO BE DECIDED:** What tournament fields beyond reference, draft state and participants are required?
- **OQ-4 — TO BE DECIDED:** What maximum draft size, post-start participant changes/substitutions and other lifecycle states are supported?
- **OQ-5 — TO BE DECIDED:** How are names entered/corrected and validated, and how are participants with identical names distinguished?
- **OQ-8 — TO BE DECIDED:** Is the plan entered manually, generated or imported; which order/date/time/location fields are required?
- **OQ-9 — TO BE DECIDED:** Which changes are permitted after arranging or starting matches?
- **OQ-10 — TO BE DECIDED:** Which tennis scoring and match completion rules apply; what score detail and match/tournament coverage does the scoreboard show?
- **OQ-11 — TO BE DECIDED:** What score validation/rejection details and update latency beyond next retrieval are required?
- **OQ-13 — TO BE DECIDED:** What entities are ranked and what geographic/organizational boundary defines local?
- **OQ-14 — TO BE DECIDED:** Are rankings calculated, entered or imported; what rules, ties and refresh frequency apply?
- **OQ-17 — TO BE DECIDED:** Which external integrations, exchanged information, triggers and failure behavior are required?
- **OQ-18 — TO BE DECIDED:** What unavailable/incomplete-data behavior applies to scores, rankings and plans (statistics with no results are defined in FR-5.1)?
- **OQ-19 — TO BE DECIDED:** What measurable capacity, response-time, availability, update-latency and recovery objectives are required? Are offline behavior or asynchronous/scheduled processing needed?

Resolved question history: OQ-3/4 creation and start timing → FR-1.1/1.3; OQ-9/11 supported editing → FR-2.2/3.2; OQ-12 statistics → FR-5.1; OQ-15 merchandising → FR-6.1–6.3; OQ-16 beer garden → FR-7.1–7.4. Former OQ-6/7 (roles, multiple categories, authentication, permissions and unauthorized response) and OQ-20 (privacy/regulation, restrictions, retention and deletion) are owned by [SECURITY.md](SECURITY.md#open-security-questions), including remaining questions.

# Exclusions

Implementation languages, frameworks, components, deployment and infrastructure are owned by [ARCHITECTURE.md](ARCHITECTURE.md); visual/accessibility defaults by [DESIGN.md](DESIGN.md); authentication, authorization and security controls by [SECURITY.md](SECURITY.md). No unspecified format, scoring/ranking algorithm, generic nonfunctional target or functionality beyond the notes and explicit subsequent decisions is inferred. Commerce exclusions are specified with the relevant requirements above.
