# AI Maintenance Guide for AzPolicyLens Reuse

This guide is for future AI-assisted maintenance of the AzPolicyLens implementation in this directory when keeping a reusable overlay aligned with upstream.

Primary source documents:

- `azure_policy_lens/README.md`
- `.github/workflows/policy-documentation.yml`
- `.github/actions/templates/policyDocDiscovery/action.yml`
- `.github/actions/templates/policyDocGenerateWiki/action.yml`
- `azure_policy_lens/scripts/pipelines/policy-documentation/environment-discovery.ps1`
- `azure_policy_lens/scripts/pipelines/policy-documentation/generate-wiki-pages.ps1`

## Objective

Keep the local implementation aligned with `Azure/AzPolicyLens` while preserving reusable overlays and team-specific config values.

## Local Overlays

Preserve these behaviors unless maintainers explicitly change them:

- Config-driven environment selection rather than hard-coded environment names.
- OIDC-based Azure login with client, tenant, and subscription IDs.
- `workflow_dispatch` as the default trigger posture until a schedule is explicitly approved.
- Local script and module path conventions under `azure_policy_lens/`.
- Configurable wiki push behavior for both external wiki repos and built-in wiki targets.

## AI Sync Procedure

1. Identify the upstream target baseline.
2. Record the candidate upstream SHA or tag before making changes.
3. Compare local files against upstream equivalents.
4. Apply upstream improvements first.
5. Re-apply required local overlays deliberately.
6. Update [README.md](README.md) when the config contract or maintenance guidance changes.
7. Run validation checks or provide exact commands if execution is not possible.

## Suggested Comparison Map

- Upstream `.github/workflows/policy-documentation.yml` -> Local `.github/workflows/policy-documentation.yml`
- Upstream `.github/actions/templates/policyDocDiscovery/action.yml` -> Local `.github/actions/templates/policyDocDiscovery/action.yml`
- Upstream `.github/actions/templates/policyDocGenerateWiki/action.yml` -> Local `.github/actions/templates/policyDocGenerateWiki/action.yml`
- Upstream `scripts/environment-discovery.ps1` -> Local `azure_policy_lens/scripts/pipelines/policy-documentation/environment-discovery.ps1`
- Upstream `scripts/generate-wiki-pages.ps1` -> Local `azure_policy_lens/scripts/pipelines/policy-documentation/generate-wiki-pages.ps1`
- Upstream `scripts/github-policy-doc-parse-config-file.ps1` -> Local `azure_policy_lens/scripts/pipelines/policy-documentation/github-policy-doc-parse-config-file.ps1`

## PR Output Expectations

Every AI-generated maintenance PR should include upstream baseline metadata, a change classification, risk notes, and validation evidence.

## Guardrails

- Do not remove local overlays unless maintainers explicitly request it.
- Do not assume conflict resolution preserved behavior; inspect auth, trigger, and script args carefully.
- Prefer small, reviewable commits during large syncs.
- Keep markdown docs in sync with implementation changes in the same PR.

## Quick Prompt Template for Future AI Runs

Use this prompt pattern when asking an AI agent to perform a sync:

"Sync local AzPolicyLens implementation with upstream `Azure/AzPolicyLens` at a SHA or tag. Preserve the reusable overlays documented in [README.md](README.md). Update workflow/templates/scripts as needed, then refresh the config contract and validation notes. Provide a concise validation report for discovery, parse config matrix, and wiki generation behavior."
