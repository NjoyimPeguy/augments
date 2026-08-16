# Visual Decisions

Use a visual comparison when the answer depends on seeing spatial, perceptual, or temporal relationships. The goal is a decision with evidence, not a gallery of attractive options.

## Choose the medium per question

Visualize when comparing layout, grouping, density, navigation, component composition, typography, color roles, imagery, responsive transformation, or motion. Keep the discussion in conversation when deciding requirements, scope, terminology, data rules, technical architecture, or prose-only trade-offs.

A UI topic is not automatically a visual question. “Which steps belong in checkout?” is conceptual. “Which arrangement makes those agreed steps easiest to understand?” is visual.

## Use the first capability that fits

1. **Existing project preview.** Inspect project instructions, scripts, routes, component examples, design-system documentation, fixtures, visual tests, and development tooling. Build isolated variants from the real components, tokens, content shapes, and states. Do not replace the setup or change the production screen before a direction is chosen.
2. **Private native interactive page.** If the environment can create a private, self-contained interactive page, use it for side-by-side comparison or direct tuning. Keep the page grounded in project assets available to the session. Review its audience and content before publishing or sharing it.
3. **Self-contained local page.** Write a single local page under `.sdlc-skills/designs/{{YYYY-MM-DD}}-{{topic}}/visuals/` (another path only if the user set one). Start from `assets/comparison-template.html` — it carries the chrome (tokens, variant switcher, decision scaffolding, status pills) and its own fill rules; author only the variants. Use inline styles and vector or embedded assets; make no external requests. Add no dependency or server merely to display it. If the environment cannot open it, give the user the path and preserve a text summary.
4. **Screenshots or wireframes.** Use rendered screenshots when a real preview exists but cannot be shared interactively. Use annotated wireframes when structure is the question and polished visuals would create false confidence. Use text diagrams only when they preserve the relationship being judged.

The richer medium is not automatically better. Match fidelity to the decision: low fidelity for flow and hierarchy, realistic components for density and states, high fidelity for typography, color, imagery, and motion.

## Keep the comparison honest

- Show **2–4 variants**. Fewer can hide a real alternative; more diffuses attention.
- Make variants meaningfully different in structure, hierarchy, affordance, or visual direction. Color swaps are not different layout directions.
- Hold requirements, content, data, device, and baseline accessibility constant so the chosen axis is what changes.
- Use the same realistic happy and unhappy state in every variant. Never make a preferred option look better through better copy or easier data.
- State the question and 2–4 comparison dimensions on the surface: for example task clarity, information density, recovery, scanability, or brand fit.
- Give every viable option its strongest fair version and a one-line trade-off. Do not include a straw option.
- When tuning a continuous value such as density, scale, or motion timing, provide a bounded control only if the medium supports it and the value can be returned explicitly.

## Protect the project and its data

- Start local and private. Do not expose a listener, bind a public interface, or publish/share a page without explicit user approval.
- Do not include secrets, credentials, private production data, or unnecessary personal information. Use representative sanitized content.
- Do not fetch external scripts, fonts, images, or data unless the project already depends on them or the user approves the request.
- A comparison page is not an application: do not add a backend, authentication flow, or event receiver for it.
- A click or control state does not count as approval. Browser interaction may inform the discussion, but the user confirms the decision in the conversation.

## Run the decision loop

1. **Name the decision.** State the question, fixed constraints, open axis, fidelity, and evaluation dimensions.
2. **Build one comparison surface.** Put variants together whenever possible so memory and viewport differences do not distort the comparison. Include viewport or state switches only when they serve the decision.
3. **Orient the user.** Say where the surface is, what is controlled, what differs, and what feedback is needed. Preserve an equivalent text summary for accessibility and environments that cannot render it.
4. **Collect reasons, not only a letter.** Ask what works, what fails, and which
   dimension drove the preference. Label it as stakeholder preference unless it
   came from a defined research or usability observation. If the surface can
   prepare a structured decision for copying, still treat the pasted result as
   feedback until confirmed.
5. **Iterate visibly.** Change only the axes implicated by feedback, write a new version, and keep the prior version long enough to compare. Do not silently overwrite the evidence.
   Bind each version to a content identity and controlled inputs; a changed
   surface/input invalidates affected comparison evidence until reconfirmed.
6. **Confirm and record.** Write the decision into the versioned whole design.
   Variant confirmation alone does not approve the combined flow; obtain direct
   approval of the exact compiled version before implementation planning.

## Decision record

Record enough for an implementer or reviewer to reconstruct the choice:

- **Question:** the visual or interaction decision being made.
- **Constraints:** existing system, content, states, devices, and accessibility floor held constant.
- **Dimensions:** the named criteria used to compare.
- **Variants:** each direction and its strongest trade-off.
- **Evidence:** preview content identity, controlled inputs, paths/images, and
  classified project fact, research, usability observation, constraint,
  preference, or inference.
- **Decision:** the chosen direction and why it best serves the dimensions.
- **Rejected:** why the other viable directions lost; avoid “not preferred” with no reason.
- **Follow-ups:** unresolved details and usability or implementation risks, each
  with an evaluator and owner; route feasibility uncertainty to `prototyping`.

Keep final comparison evidence with the design record. Record retention, exact
cleanup targets/effects/recoverability, cleanup authority, and disposition.
Only pre-authorized scratch inside an explicitly disposable boundary may be
removed directly. Repository/workspace disposal routes through
`finishing-a-branch`; otherwise cleanup remains pending. Never delete
pre-existing, shared, user-owned, or ownership-uncertain artifacts.
