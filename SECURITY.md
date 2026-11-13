# Security

## Reporting
If you find a security problem, please open a GitHub issue without exploit details, and I'll get in touch.

## How the online leaderboard is protected
The leaderboard uses [Talo](https://trytalo.com). The game talks to its REST API with a small client (`scripts/net/talo_client.gd`).

- **No secrets in the repository.** The game API key lives in `secrets/` and is git-ignored. It is added to exported builds only.
- **Least privilege.** The game key only needs the Players and Leaderboards scopes.
- **Accounts.**
  - Sign-up uses a nickname, an email and a password. Logins require a code sent to the email.
  - For password accounts, the server always checks the session token, so nobody can post scores as another player.
- **Emails stay private.** The leaderboard and player endpoints available to the game key do not return email addresses (checked against the live API). Nicknames cannot contain `@`.
- **Brute force.**
  - Talo rate-limits auth endpoints to 30 requests per minute per IP.
  - The client also pauses sign-in for 60 s after 5 failed attempts.
- **Spam.**
  - Only registered (`talo` service) accounts are shown on the leaderboard.
  - Scores are sent at most once a minute, and only if taps grew no faster than 20 per second.
  - The leaderboard is fetched at most every 15 s.
  - Talo limits each IP to 300 API requests per minute.
- **Replay protection.** Write requests can be signed (HMAC-SHA256 over a body hash, a random request id and a timestamp), matching Talo's request verification.
- **Stored session.** The refresh token is kept in an encrypted file. Passwords are never stored.

## Known limits
Any key shipped inside a browser game can be extracted. That alone does not allow account takeover or reading emails. A determined player could still post an inflated score for their own account, so such entries are moderated in the Talo dashboard.
