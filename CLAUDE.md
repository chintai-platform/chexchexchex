# Security Requirements

## Input Validation
- Validate ALL user inputs (type, length, format, range)
- Use allowlists over blocklists
- Sanitize data before processing or storage
- Reject invalid input early

## Database Access
- ALWAYS use parameterized queries or prepared statements
- NEVER concatenate user input into SQL/query strings
- Use ORM methods that auto-parameterize
- Apply principle of least privilege to database users

## Authentication & Authorization
- Verify permissions on EVERY endpoint and operation
- Never rely on client-side validation alone
- Use established, audited libraries (don't implement custom auth)
- Validate JWT signatures and claims properly

## Secrets
- NEVER hardcode credentials, API keys, or private keys
- Use environment variables or secrets manager (AWS Secrets Manager)
- Never commit secrets to version control
- Don't log secrets, tokens, or PII

## Error Handling
- Never expose stack traces, internal paths, or system details to clients
- Log errors server-side with sufficient context for debugging
- Return generic error messages to users

## Dependencies
- Review packages before adding them to the project
- Scan for known vulnerabilities regularly
- Prefer actively maintained, widely-used packages
- Keep dependencies updated
