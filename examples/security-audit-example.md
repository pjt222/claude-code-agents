# Security Audit Example 🔒

Demonstrates using the `security-analyst` agent to audit a web application.

## Scenario

You're preparing for a security review of an Express.js web application. You need to identify vulnerabilities, check for compliance with security best practices, and provide remediation guidance.

## Initial Prompt

```
Perform a comprehensive security audit of this Express.js application.
Focus on:
1. OWASP Top 10 vulnerabilities
2. Authentication and session management
3. Dependency vulnerabilities
4. Configuration security

Key files:
- src/app.js
- src/routes/auth.js
- src/middleware/
- package.json
```

## Expected Behavior

The security-analyst agent will:

1. **Scan** source code for security vulnerabilities
2. **Analyze** dependencies for known CVEs
3. **Review** authentication and session handling
4. **Check** security configurations
5. **Generate** a prioritized remediation report

## Sample Output

```markdown
## Security Audit Report 🛡️

**Application**: Express.js Web Application
**Date**: 2025-01-25
**Severity Distribution**: 2 Critical | 3 High | 4 Medium | 2 Low

---

### 🔴 CRITICAL FINDINGS

#### 1. SQL Injection (CWE-89)
**Location**: `src/routes/auth.js:34-38`
**OWASP**: A03:2021 - Injection

```javascript
// VULNERABLE CODE
app.post('/login', (req, res) => {
  const query = `SELECT * FROM users WHERE email = '${req.body.email}'`;
  db.query(query, (err, results) => {
    // ...
  });
});
```

**Attack Vector**:
```
email: admin'--
email: ' OR '1'='1
```

**Remediation**:
```javascript
// SECURE CODE
app.post('/login', (req, res) => {
  const query = 'SELECT * FROM users WHERE email = ?';
  db.query(query, [req.body.email], (err, results) => {
    // ...
  });
});
```

**Priority**: Immediate - actively exploitable

---

#### 2. Hardcoded Secrets (CWE-798)
**Location**: `src/app.js:12`
**OWASP**: A07:2021 - Identification and Authentication Failures

```javascript
// VULNERABLE
const JWT_SECRET = 'super_secret_key_123';
```

**Remediation**:
```javascript
// SECURE - use environment variables
const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
  throw new Error('JWT_SECRET environment variable required');
}
```

**Additional Steps**:
1. Rotate the compromised secret immediately
2. Add `JWT_SECRET` to `.env` (ensure `.env` is in `.gitignore`)
3. Update deployment configurations

---

### 🟠 HIGH FINDINGS

#### 3. Missing Rate Limiting (CWE-307)
**Location**: `src/routes/auth.js`
**OWASP**: A07:2021 - Identification and Authentication Failures

No rate limiting on authentication endpoints allows brute force attacks.

**Remediation**:
```javascript
const rateLimit = require('express-rate-limit');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: { error: 'Too many attempts, try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.post('/login', authLimiter, loginHandler);
app.post('/register', authLimiter, registerHandler);
```

---

#### 4. Insecure Session Configuration (CWE-614)
**Location**: `src/app.js:45-52`
**OWASP**: A07:2021 - Identification and Authentication Failures

```javascript
// CURRENT (insecure)
app.use(session({
  secret: 'keyboard cat',
  cookie: {}
}));
```

**Issues**:
- Weak secret
- Missing `httpOnly` flag
- Missing `secure` flag
- Missing `sameSite` attribute

**Remediation**:
```javascript
app.use(session({
  secret: process.env.SESSION_SECRET,
  name: '__Host-session', // Secure prefix
  cookie: {
    httpOnly: true,      // Prevent XSS access
    secure: true,        // HTTPS only
    sameSite: 'strict',  // CSRF protection
    maxAge: 3600000      // 1 hour
  },
  resave: false,
  saveUninitialized: false
}));
```

---

#### 5. Vulnerable Dependencies
**Location**: `package.json`
**OWASP**: A06:2021 - Vulnerable and Outdated Components

| Package | Current | Vulnerability | Fixed |
|---------|---------|---------------|-------|
| lodash | 4.17.4 | Prototype Pollution (CVE-2019-10744) | 4.17.21 |
| express | 4.16.4 | Open Redirect (CVE-2024-29041) | 4.19.2 |
| jsonwebtoken | 8.5.1 | Algorithm Confusion (CVE-2022-23529) | 9.0.0 |

**Remediation**:
```bash
npm audit fix
# or manually:
npm install lodash@latest express@latest jsonwebtoken@latest
```

---

### 🟡 MEDIUM FINDINGS

#### 6. Missing Security Headers
**Location**: `src/app.js`
**OWASP**: A05:2021 - Security Misconfiguration

Missing security headers expose the application to various attacks.

**Remediation** (using Helmet.js):
```javascript
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));
```

---

#### 7. Information Disclosure in Errors
**Location**: `src/app.js:89-95`
**OWASP**: A05:2021 - Security Misconfiguration

```javascript
// VULNERABLE - exposes stack traces
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.stack });
});
```

**Remediation**:
```javascript
app.use((err, req, res, next) => {
  console.error(err.stack); // Log for debugging
  res.status(500).json({
    error: 'An unexpected error occurred'
  });
});
```

---

### 🟢 LOW FINDINGS

#### 8. Missing CORS Configuration
**Location**: `src/app.js`

No explicit CORS configuration. Default behavior may be too permissive.

#### 9. Debug Mode Enabled
**Location**: `package.json` scripts

Development debug flags present in production scripts.

---

### 📊 Compliance Summary

| Framework | Status | Notes |
|-----------|--------|-------|
| OWASP Top 10 | ⚠️ Partial | 3 of 10 categories have findings |
| PCI DSS | ❌ Fail | Hardcoded secrets, missing encryption |
| NIST 800-53 | ⚠️ Partial | Several controls need attention |

---

### 📋 Remediation Checklist

#### Immediate (0-24 hours)
- [ ] Fix SQL injection in auth.js
- [ ] Rotate and secure JWT secret
- [ ] Update vulnerable dependencies

#### Short-term (1-7 days)
- [ ] Implement rate limiting
- [ ] Secure session configuration
- [ ] Add security headers

#### Medium-term (1-4 weeks)
- [ ] Set up dependency scanning in CI/CD
- [ ] Implement security logging
- [ ] Conduct penetration testing

---

### 🔗 References

- [OWASP Top 10](https://owasp.org/Top10/)
- [Express.js Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [Node.js Security Checklist](https://nodejs.org/en/docs/guides/security/)
```

## Tips for Security Audits

1. **Prioritize by Impact**: Focus on critical and high severity first
2. **Provide Context**: Explain why vulnerabilities matter
3. **Include Proof of Concept**: Show how issues can be exploited
4. **Offer Solutions**: Always provide remediation guidance
5. **Track Compliance**: Map findings to relevant frameworks

## Limitations

- **Static Analysis Only**: Cannot detect runtime vulnerabilities
- **Defensive Focus**: Does not create exploits or attack tools
- **Context Required**: May need additional information for accurate assessment

## Related Agents

- [code-reviewer](../.claude/agents/code-reviewer.md) - For general code quality
- See also: [Best Practices Guide](../docs/best-practices.md)
