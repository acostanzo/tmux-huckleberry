Create a conventional commit for the current staged and unstaged changes.

Steps:

1. Run `git status` to see all changed and untracked files.
2. Run `git diff` and `git diff --cached` to review the actual changes.
3. Stage the relevant files by specific path (`git add <file>` — never use `git add -A` or `git add .`).
4. Determine the conventional commit type from: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
5. Pick a short scope if appropriate (e.g., `scripts`, `readme`).
6. Write a subject line in the format `type(scope): description` — imperative mood, lowercase, no trailing period, under 72 characters.
7. Commit with the message and the co-author trailer:
   `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
8. Show the resulting `git log --oneline -1` to confirm.
