# Project Backup Policy

This repository is the backup source of truth for the FIM project. Project deliverables, named design concepts, documentation, and source changes made for FIM should be recorded here in a focused commit and pushed to the selected GitHub repository whenever practical.

## Current preference

The user requested that future FIM work be backed up to this repository. The FV, FV2, and FV3 logo concepts are the first assets recorded under this policy.

## Backup rules

- Keep backups organized in the project’s existing source, asset, or documentation directories.
- Use descriptive filenames and preserve the original asset when it is a design concept.
- Make small, focused commits with descriptive messages.
- Do not commit passwords, private keys, access tokens, signing files, local machine configuration, or other secrets.
- Do not commit build caches or generated output unless the project explicitly requires that artifact to be versioned.
- Verify the working tree, staged diff, and push result after each backup commit.
