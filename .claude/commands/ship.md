# /ship - Document, Commit & Push

Complete the development cycle by documenting changes, committing, and pushing to remote.

## Workflow

1. **Document**: Update CHANGELOG.md with the changes made in this session
   - Check recent commits and current staged/unstaged changes
   - Add new entry with appropriate Phase number
   - Include Summary, Changed/Added sections, and file list

2. **Commit**: Create a well-formatted commit
   - Stage relevant files (exclude settings.local.json, screenshots/)
   - Write descriptive commit message following conventional commits
   - Include Co-Authored-By trailer

3. **Push**: Push to remote repository
   - Push to current branch
   - Report success/failure

## Usage

```
/ship
```

Or with optional description:
```
/ship "Settings page reorganization"
```

## Notes

- Always review staged changes before committing
- CHANGELOG Phase number should increment appropriately (major: +1, minor: +0.1)
- Do NOT commit files like `.claude/settings.local.json` or `screenshots/`
