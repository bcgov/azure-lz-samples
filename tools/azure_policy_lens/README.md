# AzPolicyLens - Policy Documentation

This directory contains a reusable implementation of [Azure/AzPolicyLens](https://github.com/Azure/AzPolicyLens), an Azure policy documentation generator that discovers Azure Policy assignments and produces wiki pages for one or more environments.

## Directory Structure

```text
azure_policy_lens/
├── configurations/          # Environment config (settings.yml, github-config.jsonc, schema, metadata)
├── ps_modules/              # Vendored PowerShell modules
│   ├── AzPolicyLens.Discovery/
│   └── AzPolicyLens.Wiki/
└── scripts/
    └── pipelines/
        └── policy-documentation/   # Pipeline PowerShell scripts
```

The workflow and composite action templates live under `.github/`:

```text
.github/
├── actions/templates/
│   ├── initiation/
│   ├── policyDocDiscovery/
│   ├── policyDocParseConfig/
│   └── policyDocGenerateWiki/
└── workflows/
    └── policy-documentation.yml
```

---

## Configuration Model

The reusable config lives in [configurations/github-config.jsonc](configurations/github-config.jsonc) and supports multiple environments. Each environment can define one or more wiki targets, so a team can document separate landing zones, subscriptions, or wiki repositories from the same workflow pattern.

Each wiki entry should set:

- `title`
- `gitRepository`
- `gitPlatform` (`github` or `ado`)
- `gitBranch`
- `gitUserName`
- `gitUserEmail`
- either `subscriptionIds` or `childManagementGroupId`

The schema for that file is in [configurations/github-config.schema.json](configurations/github-config.schema.json).

## Supported Wiki Targets

The generator supports two target models:

- External wiki repository pushed over git.
- Built-in GitHub Wiki, when the repository URL points to the wiki remote and `gitPlatform` is `github`.

For Azure DevOps wiki targets, set `gitPlatform` to `ado` and supply the repository path required by the generator.

## Required Secrets

For Azure login, the workflow expects:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

GitHub Actions provides `GITHUB_TOKEN` automatically. If a team pushes to an external repo or needs broader permissions, replace it with a PAT appropriate for that target.

## Customization Checklist

Before reusing this directory, replace the example values in [configurations/github-config.jsonc](configurations/github-config.jsonc) with:

- your environment names
- your management group or subscription scope
- your wiki repository and branch
- your git author identity
- your preferred page style

Review [configurations/additional-policy-metadata-config.jsonc](configurations/additional-policy-metadata-config.jsonc) to decide whether the default compliance frameworks fit your organization.

## Maintenance Notes

Use [README.maintenance-ai.md](README.maintenance-ai.md) to keep this folder aligned with upstream AzPolicyLens while preserving local overlays.

When workflow, script, or config behavior changes, update this README and the schema together so the config contract stays clear.
