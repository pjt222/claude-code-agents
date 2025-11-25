# Claude Code Agents

*Stars are shining bright* ⭐

A comprehensive collection of sub-agent definitions for Claude Code, enabling specialized AI assistance for various development tasks.

## Overview

This repository provides a structured way to define and manage Claude Code sub-agents. Each agent is specialized for specific tasks like code review, R package development, security analysis, and more.

## Quick Start

1. Clone this repository
2. Copy desired agents to your Claude Code agents directory:
   ```bash
   cp .claude/agents/* ~/.claude/agents/
   ```
3. Use agents in Claude Code with the Task tool

## Repository Structure

```
claude-code-agents/
├── .claude/agents/          # Agent definitions
├── docs/                    # Documentation & guides
├── examples/                # Usage examples & demos
├── scripts/                 # Validation & utility scripts
├── templates/               # Agent templates
├── .github/workflows/       # CI/CD automation
├── README.md                # This file
└── LICENSE                  # MIT License
```

## Available Agents

### Core Development Agents
- **code-reviewer**: Reviews code changes, pull requests, and provides detailed feedback on code quality, security, and best practices
- **r-developer**: Specialized for R package development, data analysis, and statistical computing with MCP integration
- **security-analyst**: Security auditing, vulnerability assessment, and defensive security practices (OWASP, NIST, ISO 27001)

## Agent Structure

Each agent follows a standardized format:

```markdown
---
name: agent-name
description: Brief description of the agent's purpose
tools: [list, of, available, tools]
model: claude-3-5-sonnet-20241022
version: "1.0.0"
author: Philipp Thoss
---

# Agent Name

Detailed description of what this agent does and how to use it.

## Capabilities
- List of specific capabilities
- What the agent excels at

## Usage Examples
Practical examples of how to use this agent.
```

## Creating Custom Agents

1. Start with the base template in `templates/agent-template.md`
2. Define your agent's metadata in the YAML frontmatter
3. Write clear descriptions and usage examples
4. Test your agent with Claude Code
5. Submit a PR to share with the community

## Integration with MCP Servers

These agents are designed to work seamlessly with MCP servers:
- **r-mcptools**: For R development tasks
- **hf-mcp-server**: For Hugging Face model integration
- Custom MCP servers for specialized tools

## Documentation

- [Agent Development Guide](docs/agent-development-guide.md) - Complete guide to creating agents
- [Configuration Schema](docs/configuration-schema.md) - YAML frontmatter specification
- [Best Practices](docs/best-practices.md) - Guidelines for high-quality agents
- [MCP Integration](docs/mcp-integration.md) - Model Context Protocol server setup

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your agent following the established format
4. Update documentation as needed
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Philipp Thoss** (pjt222)
- Email: ph.thoss@gmx.de
- ORCID: 0000-0002-4672-2792
- GitHub: [@pjt222](https://github.com/pjt222)

---

*Empowering development workflows with specialized AI agents* ⭐