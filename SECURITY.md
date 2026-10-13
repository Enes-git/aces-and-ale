## Security Posture

This document owns the threat model, security requirements, controls, and trust-boundary enforcement. [REQUIREMENTS.md](REQUIREMENTS.md) remains authoritative for behavior, actors, workflows, business data, integrations, and privacy/regulatory constraints. [DESIGN.md](DESIGN.md) owns frontend interaction and accessibility. [ARCHITECTURE.md](ARCHITECTURE.md) owns components, interfaces, data flows, and dependency direction.

No implementation is assumed. Controls below describe required or proposed future behavior, not evidence that controls exist or have passed testing. `UNKNOWN` marks missing facts; `TO BE DECIDED` marks unresolved decisions; `ASSUMPTION` marks project-specific proposals or inferred threats. Rule identifiers beginning `SEC-` and threat identifiers beginning `TH-` are local to this document, not standards identifiers.

- **Confirmed authentication policy:** Passkey only for everyone. Encourage users to set up two devices during registration. Source: the human Security Notes supplied with this task.
- **Known architecture:** React 19 browser client, React Native iOS/Android client, Node.js application/API, and Postgres. Their responsibility and trust allocations remain provisional as labeled in `ARCHITECTURE.md`.
- **Authorization:** Actor categories are players, judges, admin, press, trainers, and audience. Permissions, protected operations, public viewing, and account-to-player mapping are UNKNOWN. Authentication does not establish permission.
- **Data and privacy:** Player names and tournament information are specified. Merchandising and beer garden records, data classification, jurisdictions, legal obligations, retention, and deletion requirements are UNKNOWN. No payment, age-verification, health-data, or other regulatory scope is inferred.
- **External exposure:** Deployed origins, domains, hosting, API protocol, identity services, integrations, and operational access paths are UNKNOWN or TO BE DECIDED as recorded in the architecture.
- **Reference applicability:** The supplied Node.js 26, React 19, and React Native 0.87 prompts are authoritative security defaults for applicable capabilities. Their version labels do not select Node.js 26 or React Native 0.87 for deployment. Language, framework, library, session, provider, and tooling choices remain TO BE DECIDED where the architecture leaves them open.

## Threat Model

**ASSUMPTION:** Consider unauthenticated requesters, authenticated users exceeding their eventual permissions, malicious browser content, modified mobile clients, network attackers, and compromised dependencies or operational credentials. These are threat scenarios, not allegations about the listed actors. Deployment exposure, likelihood, impact ratings, and accepted residual risk are TO BE DECIDED.

**ASSUMPTION:** Protect the integrity and permitted disclosure of the application-owned tournament, participant, match, plan, score, statistics, and ranking data. Passkey account associations, credential records, session material, configuration secrets, and security logs are additional security assets whose schema and storage are TO BE DECIDED. Business objects for merchandising and beer garden management remain UNKNOWN.

Every threat below is an **ASSUMPTION** derived from the documented surfaces and proposed boundaries.

| ID | Abuse scenario and affected asset | Enforcement point and relevant controls |
| --- | --- | --- |
| TH-01 | A requester attaches a passkey to another account, replays a ceremony, or exploits recovery to take over an identity. | Application identity handling; SEC-AUTH-01 through SEC-AUTH-04. |
| TH-02 | A client changes an object reference or claimed actor category to read or modify another user's permitted records. | Application authorization on each protected operation/object; SEC-ACCESS-01. |
| TH-03 | Crafted names or other displayed values become executable browser markup, malicious navigation, or unsafe native input. | Client rendering and receiving adapters; SEC-WEB-01, SEC-MOBILE-01, SEC-INPUT-01. |
| TH-04 | Malformed fields, SQL injection, mass assignment, or concurrent commands corrupt participant counts, matches, or scores. | API validation, domain rules, and persistence; SEC-INPUT-01, SEC-DATA-01. |
| TH-05 | A stolen device, leaked session, cross-account cache, URL, or diagnostic log discloses identity or player information. | Session lifecycle, client storage, API responses, and operations; SEC-SESSION-01, SEC-MOBILE-01, SEC-OPS-01. |
| TH-06 | Slow, oversized, repeated, or expensive requests exhaust authentication, Node.js, or database resources. | Application admission, parsing, and resource access; SEC-RUNTIME-01. |
| TH-07 | Network interception or an untrusted redirect captures credentials or alters responses. | Transport endpoints and receiving clients; SEC-TRANSPORT-01. |
| TH-08 | A compromised package, build artifact, native module, or deployment credential introduces privileged code or leaks secrets. | Dependency/release review and runtime privilege boundaries; SEC-SUPPLY-01, SEC-OPS-01. |

An integration-specific threat model cannot be completed because external integrations are UNKNOWN. SSRF, webhook authentication, payment processing, file uploads, and background-worker controls apply only if such capabilities are established; this document does not introduce them.

## Security Requirements

**SEC-AUTH-01 — Passkey-only authentication.** All user authentication MUST use passkeys, including authentication by any actor category later granted administrative permissions. Password, email/SMS code, magic-link, or other non-passkey sign-in fallbacks MUST NOT be introduced. This policy does not determine which views require sign-in. Service-to-service and operational identities are UNKNOWN; their policy is TO BE DECIDED. Source: human Security Notes.

**SEC-AUTH-02 — Registration encouragement.** Registration MUST encourage setting up access on two devices. The second device is encouraged, not a mandatory registration gate. Exact interaction, supported devices, and enrollment tracking are TO BE DECIDED. A synced passkey can be available on several devices, so credential count cannot be treated as proof of two independent recovery methods. Source: human Security Notes and [FIDO passkey synchronization guidance](https://fidoalliance.org/passkeys/).

**SEC-AUTH-03 — ASSUMPTION: proposed passkey verification.** Use a maintained WebAuthn-compatible verifier in the application; library and native integration are TO BE DECIDED. Bind cryptographically random, expiring, single-use challenges to the ceremony and intended account context. Verify ceremony type, challenge, expected origin, RP ID, account/credential association, required presence/verification flags, algorithms, registration response, and assertion signatures before accepting authentication. Prevent reuse and cross-account credential attachment. **ASSUMPTION:** Require user verification for passwordless ceremonies; policy confirmation is TO BE DECIDED. RP ID, origin allowlist, attestation policy, challenge limits, expiry, and authenticator compatibility are TO BE DECIDED. This is a project proposal derived from [WebAuthn Level 2, registration](https://www.w3.org/TR/2021/REC-webauthn-2-20210408/#sctn-registering-a-new-credential) and [assertion verification](https://www.w3.org/TR/2021/REC-webauthn-2-20210408/#sctn-verifying-assertion), not a custom cryptographic protocol.

**SEC-AUTH-04 — ASSUMPTION: credential lifecycle and recovery.** Require recent successful passkey verification before adding or removing a credential on an existing account; protect these operations against request forgery and account substitution. Freshness, initial registration/bootstrap, revocation, last-credential removal, and all-devices-lost recovery are TO BE DECIDED. Recovery must be reconciled with SEC-AUTH-01 before implementation; no weaker fallback or support override is implicitly authorized. Authentication records must not equate player names with unique account identities.

**SEC-ACCESS-01 — Server authority.** The API MUST independently authorize each protected operation and object using trusted server context. Client roles, hidden controls, route state, object references, and native assertions grant no authority. Reject unvalidated privilege/ownership fields rather than binding request bodies directly to records. **ASSUMPTION:** Deny protected operations lacking an explicitly defined grant; the permission matrix and observable rejection contract are TO BE DECIDED. Sources: S-JS, S-REACT, S-NATIVE.

**SEC-INPUT-01 — Runtime validation.** Validate incoming commands, API responses at clients, stored client values, and configuration at their receiving boundary. Use allowlisted security-sensitive fields and bound types, bytes, structure, collections, and computational cost. Reject prototype-polluting keys; keep untrusted data out of dynamic execution and module selection. Type annotations cannot substitute for runtime checks. Exact schemas and limits are TO BE DECIDED; do not invent player-name, score, or ranking rules. Sources: S-JS, S-NODE, S-REACT, S-NATIVE; S-TS only if TypeScript is selected.

**SEC-DATA-01 — Data integrity and persistence.** Bind SQL values and allowlist dynamic query structure. The application MUST enforce resolved business rules independently of the originating client, coordinating database consistency where needed. Enforce the eight-player invariant at the lifecycle point requirements eventually define. No duplicate-name restriction, match format, ranking formula, or scoring algorithm is inferred. **ASSUMPTION:** Use a least-privilege application database identity, with schema-changing and operational privileges separated from routine record access. Schema, constraints, transaction/concurrency mechanism, and grants are TO BE DECIDED. Sources: `ARCHITECTURE.md`, S-JS, S-NATIVE.

**SEC-SESSION-01 — Session protection.** Session format, storage, expiry, rotation, revocation, logout, and reauthentication rules are TO BE DECIDED. Once sessions exist, verify them on the server and prevent stale client responses or caches from restoring an earlier identity. If browser cookies carry authentication, use `Secure`, `HttpOnly`, an appropriate `SameSite` policy, and server-side request-forgery protection; cookie attributes alone are insufficient. If native bearer/refresh credentials are selected, protect them using platform credential storage and support bounded lifetime and server-side invalidation. Do not select JWT, a token provider, or browser storage merely because a reference discusses it. Sources: S-JS, S-REACT, S-NATIVE.

**SEC-TRANSPORT-01 — Network authenticity.** Protect remote credential and application traffic with authenticated encryption and certificate/hostname verification. For web/mobile HTTPS traffic, keep verification enabled; release mobile builds must reject broad cleartext and development trust exceptions. If cross-origin browser access is needed, allowlist exact origins; CORS is not API authorization and is not a native-client security boundary. TLS termination, trust configuration, network topology, native app associations, and any pinning decision are TO BE DECIDED. Sources: S-NODE, S-NATIVE.

**SEC-WEB-01 — Safe React rendering.** Render player names and other untrusted values as inert text. Keep untrusted values out of raw HTML, SVG, scripts, styles, arbitrary props, and executable resource URLs. Rich HTML is not required; if later introduced, review its sanitizer and sinks. Apply a restrictive CSP and Trusted Types where supported, with compatibility testing for the selected React minor and rendering strategy; exact policy is TO BE DECIDED. Keep secrets out of client bundles and hydration data. If SSR, Server Components, or Server Functions are selected, separately review request isolation, caching, endpoint authorization, serialization, and request-forgery protection. Sources: S-JS, S-REACT.

**SEC-MOBILE-01 — Native client containment.** Treat the application bundle, local state, device, and native-module outputs as untrusted. Keep credentials out of AsyncStorage and ordinary plaintext files; use iOS Keychain or Android Keystore-backed protection for any application-held session credentials. Platform passkey private keys are not application-managed session tokens. Minimize cached personal data and clear user-scoped state on identity changes and revocation. Request only capabilities required by resolved workflows. Deep links, WebViews, push, and additional device permissions are not established capabilities; if introduced, review destination validation, message provenance, native bridges, and authorization first. Storage libraries and backup policy are TO BE DECIDED. Source: S-NATIVE.

**SEC-RUNTIME-01 — Node.js resource and execution limits.** Bound request parsing, body sizes, timeouts, concurrency, retries, database work, and authentication attempts; values are TO BE DECIDED. Use strict protocol parsing when HTTP is selected and trust forwarded identity headers only from explicitly configured intermediaries. Fail startup on invalid security configuration. Keep secrets out of arguments and untrusted data out of shells or dynamic code. Restrict runtime privileges and diagnostics; Node.js permission controls, if applicable to the selected runtime, provide defense in depth and do not sandbox malicious code. Container, reverse-proxy, and runtime-specific mechanisms remain TO BE DECIDED. Sources: S-JS, S-NODE.

**SEC-OPS-01 — Secrets, errors, and accountability.** Exclude credentials, session material, sensitive request/response bodies, and unnecessary personal data from logs, URLs, analytics, crash reports, and client errors. Return safe errors while preserving accessible field feedback required by `DESIGN.md`. Restrict diagnostic artifacts and secret access; mechanisms are TO BE DECIDED. **ASSUMPTION:** Record sanitized authentication, credential-change, permission-denial, and supported data-change events with correlation and outcome; event fields, access, retention, alert thresholds, incident ownership, and response procedures are TO BE DECIDED. Sources: S-JS, S-NODE, S-REACT, S-NATIVE.

**SEC-SUPPLY-01 — Dependencies and releases.** Use reviewed, locked dependency resolution and a reproducible build; assess packages, runtime, native modules, and shipped artifacts for applicable advisories. Review lifecycle scripts before execution, keep development/debug surfaces out of releases, and protect native signing credentials. Applicable high/critical dependency findings must be resolved before promotion under the supplied baseline. Package manager, scanners, release gates, CI/CD system, update tooling, and exception authority are TO BE DECIDED. Source version labels and historical review dates are not evidence that a future deployment is patched. Sources: S-JS, S-NODE, S-REACT, S-NATIVE.

## Controls and Trust-Boundary Enforcement

The allocations below are **ASSUMPTION**, following the provisional architecture. Controls stay within the existing client, application, and persistence boundaries; no authentication vendor, worker, proxy, or separate security service is selected.

| Boundary or surface | Authoritative enforcement | Control and remaining decision |
| --- | --- | --- |
| Browser/mobile request to Node.js | Node.js application/API | Runtime input validation, verified identity where required, object/action authorization, and business rules before protected effects. Protocol, permissions, and failure contract: TO BE DECIDED. |
| Platform passkey response through client to API | Application passkey verifier | SEC-AUTH-03; the client transports proof but cannot declare authentication successful. Library, native association mechanism, credential record storage, and bootstrap: TO BE DECIDED. |
| Application to Postgres | Application data access plus database grants/constraints | Parameter binding, limited privileges, resolved invariants, and consistent mutations. Clients do not receive database credentials or access records directly. Connection protection, migrations, and recovery mechanisms: TO BE DECIDED. |
| Application response to browser/native rendering | Receiving client rendering and validation | Inert text, deliberate response fields, identity-scoped state, safe navigation, and accessibility. API response schemas and any persisted client state: TO BE DECIDED. |
| Native runtime to device storage/capabilities | Reviewed platform adapters, with authorization retained server-side | Protected credential storage, narrow native methods, input validation, and least necessary permissions. Native modules and supported platform versions: TO BE DECIDED. |
| Build/runtime configuration and diagnostics | Operational access controls | Reviewed dependencies, protected secrets/signing material, bounded runtime authority, and sanitized diagnostics. Deployment and operational identities: TO BE DECIDED. This row is a control obligation, not a new deployed component. |

**ASSUMPTION:** Keep passkey credential metadata and account associations separate from business player identity, and expose only deliberate public response fields. Storage location, account schema, data classifications, encryption-at-rest/key management, backup access, retention, and deletion behavior are TO BE DECIDED. Do not assign legal retention periods or mark player names public merely because the scoreboard displays names.

The registration prompt and security feedback must retain the design's labels, keyboard operation, focus behavior, text scaling, and assistive-technology announcements. Unsupported-device and lost-device experiences are TO BE DECIDED; accessibility does not authorize a non-passkey authentication bypass.

## Security Verification

No implementation-level security testing has been performed because no implementation is assumed. **ASSUMPTION:** The following evidence should be required for the corresponding implemented capability; test tooling and release process are TO BE DECIDED.

| Area | Required evidence to define before release |
| --- | --- |
| Passkeys and registration | Rejected invalid/replayed/cross-account ceremonies; supported native/browser interoperability; cancellation; no non-passkey fallback; two-device encouragement remains optional; credential changes and eventual recovery follow reviewed policy. |
| Authorization and integrity | Positive and negative tests for each approved actor/action/object grant, tampered references, mass assignment, and concurrent writes at the resolved eight-player enforcement point. |
| Rendering and client state | Malicious names render as text; safe URLs and props; no cross-account cache or late-response leak; required keyboard, focus, resizing, and screen-reader behavior. |
| Transport and sessions | Rejected invalid certificates, origins and expired/revoked credentials; request-forgery coverage for the selected transport; protected native storage and release trust settings. |
| Availability and operations | Enforced configured limits under malformed/oversized/slow requests; safe dependency failure; redaction checks; restricted diagnostics and secrets; recovery evidence once objectives are defined. |
| Supply chain | Reviewed locks and install scripts, applicable runtime/package/native advisory assessment, release artifact inspection, and protected signing provenance. |

OWASP ASVS 5.0.0 applicability, assurance level, and requirement mappings are TO BE DECIDED. No ASVS identifier or conformance claim is asserted.

## Sources

The specific prompt files below were accessible and read. Their titles are reproduced exactly; rules above are project-specific summaries. Version values are reference versions. Upstream pages merely listed in a local `sources.md` are not presented as independently verified evidence. The TypeScript source was reviewed for applicability and remains conditional; it does not select TypeScript.

| Source | Exact title or source identifier | Version | Exact path or URL |
| --- | --- | --- | --- |
| S-REQ | `REQUIREMENTS.md` | UNKNOWN; no declared document version | [Repository requirements](REQUIREMENTS.md) |
| S-DESIGN | `DESIGN.md` | UNKNOWN; no declared document version | [Repository design](DESIGN.md) |
| S-ARCH | `ARCHITECTURE.md` | UNKNOWN; no declared document version; provisional | [Repository architecture](ARCHITECTURE.md) |
| S-HUMAN | Human Security Notes: Authentication and Authoritative Security Defaults | Unversioned input supplied 2026-10-13 | Conversation input; no file or URL supplied |
| S-NODE | Node.js 26 Secure Coding Prompt | 26 | [prompt.md](/Users/jmanico/Dropbox/github/aegis/secure-coding-knowledge/content/js/nodejs/26/prompt.md) |
| S-REACT | React 19 Secure Coding Prompt | 19 | [prompt.md](/Users/jmanico/Dropbox/github/aegis/secure-coding-knowledge/content/js/react/19/prompt.md) |
| S-NATIVE | React Native 0.87 Secure Coding Prompt | 0.87 | [prompt.md](/Users/jmanico/Dropbox/github/aegis/secure-coding-knowledge/content/js/react-native/0.87/prompt.md) |
| S-JS | JavaScript ES2026 Secure Coding Prompt | ES2026 | [prompt.md](/Users/jmanico/Dropbox/github/aegis/secure-coding-knowledge/content/js/javascript/ES2026/prompt.md) |
| S-TS | TypeScript 7 Secure Coding Prompt | 7; guidance targets 7.0.x; conditional | [prompt.md](/Users/jmanico/Dropbox/github/aegis/secure-coding-knowledge/content/js/typescript/7/prompt.md) |
| S-WEBAUTHN | Web Authentication: An API for accessing Public Key Credentials Level 2 | W3C Recommendation, 8 April 2021 | [§7.1 Registering a New Credential](https://www.w3.org/TR/2021/REC-webauthn-2-20210408/#sctn-registering-a-new-credential); [§7.2 Verifying an Authentication Assertion](https://www.w3.org/TR/2021/REC-webauthn-2-20210408/#sctn-verifying-assertion) |
| S-FIDO | FIDO Passkeys: Passwordless Authentication \| FIDO Alliance | Unversioned page; accessed 2026-10-13 | [Passkey synchronization FAQ](https://fidoalliance.org/passkeys/) |

Local paths identify the supplied reference library and may not be available to other repository readers. The cited prompts are not copied into this repository.

## Open Security Questions

1. **Authentication scope and source reconciliation:** `REQUIREMENTS.md` leaves authentication UNKNOWN. The later human note establishes passkey-only authentication and registration encouragement; it does not establish the protected-operation matrix or whether audience viewing is anonymous. The architecture now explicitly records that added constraint. There is no confirmed contradictory product rule; scope remains TO BE DECIDED.
2. **Reference conflicts and conditional defaults:** Node.js guidance discusses SQLite and deployment examples, while the architecture selects Postgres and leaves hosting open. React guidance covers optional server rendering/functions; native guidance covers OAuth, tokens, and WebViews. These passages do not mandate those capabilities. Password-storage guidance is inapplicable to the passkey-only policy. Imported TypeScript 7 guidance does not select a language or guarantee React Native/toolchain compatibility. Resolve applicability before implementation rather than silently replacing architectural decisions.
3. **Identity model:** Who may register, how are initial account and administrative privileges established, and how do accounts relate to named participants? Facts are UNKNOWN; bootstrap and privilege-assignment controls are TO BE DECIDED.
4. **Passkey configuration:** RP ID, approved origins, native application associations, supported authenticators/platform versions, user-verification and attestation policy, challenge expiry, verifier, and credential record design are TO BE DECIDED.
5. **Two-device and recovery policy:** What counts as successful setup across devices, how is encouragement presented accessibly, and what happens when every usable passkey is lost? Requirements beyond encouragement are UNKNOWN. Credential addition/removal, revocation, last-credential safeguards, and recovery are TO BE DECIDED without an implicit weaker sign-in method.
6. **Authorization and sessions:** Actor/action/object permissions are UNKNOWN. Session mechanism, lifetimes, rotation, revocation, logout, reauthentication, and failure disclosures are TO BE DECIDED. A successful passkey ceremony must not silently grant a tournament role.
7. **Business-rule integrity:** Scoring and correction rules, participant lifecycle, match-plan changes, ranking/statistic sources, and concurrent-update behavior remain unresolved in requirements. Security validation cannot supply those missing rules.
8. **Privacy and data protection:** Classification, public disclosure, applicable law, retention/deletion, telemetry fields, local caching, backups, and recovery objectives are UNKNOWN. Controls and accountable owners are TO BE DECIDED. No regulatory obligation is asserted from the project domain alone.
9. **Exposure and operations:** External integrations, origins, deployment topology, service/operational identities, resource budgets, secret management, incident contacts, vulnerability-reporting channel, and response timelines are UNKNOWN or TO BE DECIDED. No vendor or CI/CD product is selected.
10. **Verification and residual risk:** Assurance target, ASVS mappings, acceptance of proposed controls, release evidence, exception authority, and review ownership are TO BE DECIDED. Documentation does not establish operational readiness.
