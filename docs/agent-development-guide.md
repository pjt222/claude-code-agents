# Agent Development Guide 🚀

A complete guide to creating, testing, and deploying Claude Code agents.

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Agent Anatomy](#agent-anatomy)
4. [Step-by-Step Creation](#step-by-step-creation)
5. [Testing Your Agent](#testing-your-agent)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

---

## Introduction

Claude Code agents are specialized AI assistants that extend Claude's capabilities for specific tasks. Each agent is defined in a Markdown file with YAML frontmatter containing metadata and configuration.

### Why Create Custom Agents?

- **Specialization**: Focus Claude on specific domains (security, R development, etc.)
- **Consistency**: Ensure repeatable behavior across sessions
- **Reusability**: Share agents across teams and projects
- **Documentation**: Self-documenting AI workflows

---

## Getting Started

### Prerequisites

- Claude Code CLI installed and configured
- Basic understanding of Markdown and YAML
- Familiarity with the domain your agent will serve

### Quick Start

1. Copy the template:
   ```bash
   cp templates/agent-template.md .claude/agents/my-agent.md
   ```

2. Edit the frontmatter with your agent's details

3. Write comprehensive documentation

4. Test with Claude Code:
   ```bash
   claude code
   # Then use Task tool to invoke your agent
   ```

---

## Agent Anatomy

Every agent consists of two parts:

### 1. YAML Frontmatter (Metadata)

```yaml
---
name: my-agent-name
description: What this agent does (1-2 sentences)
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: claude-3-5-sonnet-20241022
version: "1.0.0"
author: Your Name <email@example.com>
created: 2025-01-25
updated: 2025-01-25
tags: [category, domain, language]
priority: normal
max_context_tokens: 200000
mcp_servers: []
---
```

### 2. Markdown Body (Documentation)

```markdown
# Agent Name

Introduction and overview.

## Purpose
Why this agent exists.

## Capabilities
What the agent can do.

## Usage Scenarios
When to use this agent.

## Examples
Concrete interaction examples.

## Limitations
What the agent cannot do.
```

---

## Step-by-Step Creation

### Step 1: Define the Purpose

Ask yourself:
- What specific problem does this agent solve?
- Who is the target user?
- What makes this agent different from general Claude?

**Good Example**: "Reviews Python code for security vulnerabilities following OWASP guidelines"

**Bad Example**: "Helps with code stuff"

### Step 2: Choose the Name

Follow kebab-case naming:
- ✅ `python-security-reviewer`
- ✅ `data-pipeline-builder`
- ❌ `myAgent`
- ❌ `Helper_1`

### Step 3: Select Tools

Only include tools your agent actually needs:

| Tool | Use Case |
|------|----------|
| `Read` | Reading files, code analysis |
| `Write` | Creating new files |
| `Edit` | Modifying existing files |
| `Bash` | Running commands, tests, builds |
| `Grep` | Searching file contents |
| `Glob` | Finding files by pattern |
| `WebFetch` | Fetching documentation, CVE data |
| `Task` | Delegating to sub-agents |

### Step 4: Write the Description

Your frontmatter description should be:
- 1-2 sentences maximum
- Specific about capabilities
- Active voice

```yaml
# Good
description: Analyzes Python code for security vulnerabilities and suggests fixes following OWASP Top 10 guidelines

# Bad
description: Helps with security things
```

### Step 5: Document Capabilities

Be specific and group related capabilities:

```markdown
## Capabilities

### Security Analysis
- **SQL Injection Detection**: Identifies unsafe query patterns
- **XSS Prevention**: Scans for unescaped outputs
- **Authentication Review**: Validates session handling

### Code Quality
- **Complexity Analysis**: Identifies high cyclomatic complexity
- **Duplication Detection**: Finds copy-paste code patterns
```

### Step 6: Provide Examples

Show real interactions:

```markdown
### Example: Security Vulnerability Detection

**User**: Review auth.py for security issues

**Agent**: Found 2 critical issues in auth.py:

1. **SQL Injection** (line 45)
   ```python
   # Vulnerable
   query = f"SELECT * FROM users WHERE id = {user_id}"

   # Fixed
   cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
   ```

2. **Weak Password Hashing** (line 67)
   - Current: MD5 (broken)
   - Recommended: bcrypt or Argon2
```

### Step 7: Document Limitations

Be honest about what the agent cannot do:

```markdown
## Limitations

- Cannot execute code for dynamic analysis
- Limited to static pattern matching
- May miss context-dependent vulnerabilities
- Requires manual verification of findings
```

---

## Testing Your Agent

### Manual Testing Checklist

- [ ] Agent loads without YAML parsing errors
- [ ] Description accurately reflects capabilities
- [ ] All listed tools are actually used
- [ ] Examples produce expected behavior
- [ ] Edge cases are handled gracefully
- [ ] Error messages are helpful

### Test Scenarios

1. **Happy Path**: Test the primary use case
2. **Edge Cases**: Test boundary conditions
3. **Error Handling**: Test with invalid input
4. **Tool Integration**: Verify each tool works correctly

### Validation Script

Use the provided validation script:

```bash
./scripts/validate-agents.sh
```

---

## Deployment

### Local Installation

```bash
# Copy to Claude Code agents directory
cp .claude/agents/my-agent.md ~/.claude/agents/

# Verify installation
ls ~/.claude/agents/
```

### Team Sharing

1. Add agent to this repository
2. Submit a pull request
3. After merge, team members can:
   ```bash
   git pull
   cp .claude/agents/* ~/.claude/agents/
   ```

### Version Management

Follow semantic versioning:
- **1.0.0** → **1.0.1**: Bug fixes, typos
- **1.0.0** → **1.1.0**: New features (backward compatible)
- **1.0.0** → **2.0.0**: Breaking changes

Update the `version` and `updated` fields when making changes.

---

## Troubleshooting

### Common Issues

#### YAML Parsing Errors

**Symptom**: Agent fails to load

**Solution**: Validate YAML syntax
```bash
yamllint .claude/agents/my-agent.md
```

#### Agent Not Found

**Symptom**: Claude doesn't recognize the agent

**Solution**:
1. Check file location (`~/.claude/agents/`)
2. Verify file extension (`.md`)
3. Check filename matches `name` field

#### Tools Not Working

**Symptom**: Agent can't perform expected actions

**Solution**:
1. Verify tools are listed in frontmatter
2. Check tool names are spelled correctly
3. Ensure tools are appropriate for the task

#### MCP Server Not Connected

**Symptom**: MCP-dependent features fail

**Solution**:
1. Verify MCP server is installed
2. Check MCP server is running
3. Confirm `mcp_servers` field is correct

---

## Resources

- [Configuration Schema](configuration-schema.md) - Full schema reference
- [Best Practices](best-practices.md) - Quality guidelines
- [MCP Integration](mcp-integration.md) - MCP server setup
- [Agent Template](../templates/agent-template.md) - Starting template

---

**Happy agent building!** 🎉

*Questions? Open an issue on GitHub or check existing agents for inspiration.*
