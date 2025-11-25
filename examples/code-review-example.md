# Code Review Example 🔍

Demonstrates using the `code-reviewer` agent to review a pull request.

## Scenario

You have a pull request that implements a new user authentication feature. You want to ensure the code is secure, follows best practices, and is maintainable.

## Initial Prompt

```
Review the authentication changes in this PR. Focus on security vulnerabilities
and code quality. The changes are in:
- src/auth/login.js
- src/auth/session.js
- src/middleware/auth-middleware.js
```

## Expected Behavior

The code-reviewer agent will:

1. **Read** all specified files using the Read tool
2. **Analyze** code for security issues (OWASP Top 10)
3. **Check** code quality and best practices
4. **Identify** potential performance issues
5. **Provide** actionable feedback with line references

## Sample Output

```markdown
## Code Review: Authentication Feature

### 🔴 Critical Issues

#### 1. SQL Injection Vulnerability
**File**: `src/auth/login.js:45`

```javascript
// Current (vulnerable)
const query = `SELECT * FROM users WHERE email = '${email}'`;

// Recommended (parameterized)
const query = 'SELECT * FROM users WHERE email = ?';
db.query(query, [email]);
```

**Impact**: Allows arbitrary SQL execution
**Priority**: Fix immediately before merge

#### 2. Weak Password Hashing
**File**: `src/auth/login.js:67`

```javascript
// Current (weak)
const hash = crypto.createHash('md5').update(password).digest('hex');

// Recommended (bcrypt)
const hash = await bcrypt.hash(password, 12);
```

**Impact**: Passwords vulnerable to rainbow table attacks

---

### 🟡 Medium Issues

#### 3. Missing Rate Limiting
**File**: `src/middleware/auth-middleware.js`

No rate limiting on login endpoint. Vulnerable to brute force attacks.

**Recommendation**: Add rate limiting middleware:
```javascript
const rateLimit = require('express-rate-limit');
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts'
});
```

#### 4. Session Token in URL
**File**: `src/auth/session.js:23`

Session tokens passed in URL query parameters are logged and cached.

**Recommendation**: Use HTTP-only cookies or Authorization headers.

---

### 🟢 Code Quality

#### Positive Observations
- ✅ Good separation of concerns
- ✅ Clear function naming
- ✅ Error handling present

#### Improvements
- Consider extracting validation logic to separate module
- Add JSDoc comments for public functions
- Increase test coverage for edge cases

---

### Summary

| Category | Issues |
|----------|--------|
| 🔴 Critical | 2 |
| 🟡 Medium | 2 |
| 🟢 Low | 3 |

**Recommendation**: Address critical issues before merge. Medium issues should be tracked for immediate follow-up.
```

## Tips for Effective Code Reviews

1. **Be Specific**: Always include file paths and line numbers
2. **Explain Why**: Don't just identify issues, explain their impact
3. **Provide Solutions**: Offer concrete fix suggestions
4. **Prioritize**: Focus on security and functionality over style
5. **Be Constructive**: Frame feedback positively

## Related Agents

- [security-analyst](../.claude/agents/security-analyst.md) - For deeper security analysis
- See also: [Security Audit Example](security-audit-example.md)
