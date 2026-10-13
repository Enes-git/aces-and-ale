# Agent Instructions

## Load Specifications Only When Needed

This file contains agent operating and authoring guidance. The domain documents are **not eager imports**. Read the relevant owner only when needed for the current task, and consult another owner when the task crosses its domain; do not automatically load every specification for unrelated work.

| Task or decision | Read its owner |
| --- | --- |
| Functional/nonfunctional behavior, business records, workflows, testable product acceptance criteria | [REQUIREMENTS.md](REQUIREMENTS.md) |
| Brand/logo, tokens, typography, layout, components and accessibility | [DESIGN.md](DESIGN.md) |
| Components, interfaces, data flows, trust-boundary topology, technology choices and rationale | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Any security requirement, threat, posture, privacy/disclosure control, authorization or boundary enforcement | [SECURITY.md](SECURITY.md) |
| New GitHub issue or requirement authoring | [REQUIREMENT_TEMPLATE.md](REQUIREMENT_TEMPLATE.md) and the affected owner |

Security owns overlaps involving security policy. Put each rule in its owner; nonowners link rather than reauthor it. Preserve distinct facts, constraints, decisions, source provenance and caveats when relocating content. Architecture may place a control at a boundary but links to SECURITY for what the control enforces. Do not silently promote an assumption into a decision.

## Working Rules

- Every new GitHub issue MUST follow [REQUIREMENT_TEMPLATE.md](REQUIREMENT_TEMPLATE.md) so each issue is a structured, testable requirement.
- Do not invent workflow, tooling or process details; mark unresolved choices explicitly `TO BE DECIDED`. `UNKNOWN` may identify unavailable historical facts; `ASSUMPTION` labels unapproved proposals.
- Follow the affected owner's verification requirements, including [security verification](SECURITY.md#security-verification) when security-critical decisions or error paths are involved. Select checks appropriate to the change; do not claim implementation conformance from document review.
- Record setup/build/test/run/release guidance here when actually decided. Do not infer commands or review gates from template examples.

## Requirement Authoring

- Use one template per atomic, independently testable requirement; split compound behavior where outcomes are independently specifiable. Uppercase normative terms use BCP 14 semantics (RFC 2119 and RFC 8174); prefer `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT` and `MAY`.
- Replace bracketed placeholders. Use `N/A` only after evaluating nonapplicability and `TO BE DECIDED` for unresolved inputs.
- Each acceptance criterion MUST describe one independently testable observable pass/fail outcome, identifying preconditions, action and expected result within the statement's scope, without introducing new behavior. Use Given/When/Then or an equally explicit form.
- Include only standard mappings verified against the cited version; do not guess control IDs. Record evaluated nonapplicability as `N/A`, unassessed applicability/mapping as `TO BE DECIDED`.
- Template security/context/failure/reviewer fields reference owner policy; filling a field does not authorize a new control exception or approval gate. Security coverage and failure rules belong exclusively to [SECURITY.md](SECURITY.md).

## Development Workflow

| Item | Decision |
| --- | --- |
| Local setup and dependency installation | TO BE DECIDED |
| Build, lint, format, test and run commands | TO BE DECIDED |
| Branch, commit, pull request and review conventions | TO BE DECIDED |
| Release and deployment procedure | TO BE DECIDED |

### Reading a Local Copy

The original README provided these commands to obtain the specifications (not an application setup or dependency-install procedure):

```sh
git clone https://github.com/jmanico/aces-and-ale.git
cd aces-and-ale
```

Then consult only the owner needed for the task using the routing table above.
