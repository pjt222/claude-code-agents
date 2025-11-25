# MCP Integration Guide 🔌

A comprehensive guide to integrating Model Context Protocol (MCP) servers with Claude Code agents.

## Table of Contents

1. [What is MCP?](#what-is-mcp)
2. [Available MCP Servers](#available-mcp-servers)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Agent Integration](#agent-integration)
6. [Usage Examples](#usage-examples)
7. [Troubleshooting](#troubleshooting)
8. [Creating Custom MCP Servers](#creating-custom-mcp-servers)

---

## What is MCP?

The **Model Context Protocol (MCP)** is a standard for connecting AI models to external tools and data sources. MCP servers extend Claude's capabilities by providing:

- **Direct Tool Access**: Execute code, manage packages, interact with APIs
- **Persistent State**: Maintain session state across interactions
- **Domain Expertise**: Specialized tools for specific domains (R, Python, databases)
- **Real-time Data**: Access live information and external services

### How It Works

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code │────▶│ MCP Server  │────▶│ External    │
│   Agent     │◀────│ (Bridge)    │◀────│ Service/Tool│
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Available MCP Servers

### R Development Servers

#### r-mcptools
**Purpose**: R package management and help system integration

**Capabilities**:
- Install, update, and remove R packages
- Access R documentation and help
- Manage R workspace and variables
- Read/write R data files (.rds, .csv, .xlsx)

**Best For**: Package development, documentation lookup, data file handling

#### r-mcp-server
**Purpose**: Direct R code execution in persistent sessions

**Capabilities**:
- Execute arbitrary R code
- Maintain persistent R environment
- Capture output, errors, and warnings
- Transfer data between R and Claude

**Best For**: Interactive analysis, code testing, statistical computing

### Machine Learning Servers

#### hf-mcp-server
**Purpose**: Hugging Face model integration

**Capabilities**:
- Load and run Hugging Face models
- Text generation, classification, embeddings
- Model discovery and metadata
- Inference API access

**Best For**: ML workflows, NLP tasks, model evaluation

### Utility Servers

#### filesystem-mcp
**Purpose**: Enhanced file system operations

**Capabilities**:
- Advanced file search and filtering
- Batch file operations
- File metadata and analysis
- Directory tree traversal

#### database-mcp
**Purpose**: Database connectivity

**Capabilities**:
- SQL query execution
- Schema introspection
- Connection pooling
- Multiple database support

---

## Installation

### Using Claude Code CLI

```bash
# Add an MCP server
claude mcp add <server-name> <server-path-or-command>

# List installed servers
claude mcp list

# Remove a server
claude mcp remove <server-name>
```

### Example: Installing r-mcptools

```bash
# Install the R package first
R -e "install.packages('mcptools')"

# Add to Claude Code
claude mcp add r-mcptools "R --slave -e 'mcptools::serve()'"

# Verify installation
claude mcp list
```

### Example: Installing r-mcp-server

```bash
# Clone the server repository
git clone https://github.com/user/r-mcp-server.git
cd r-mcp-server

# Install dependencies
npm install

# Add to Claude Code
claude mcp add r-mcp-server "node /path/to/r-mcp-server/index.js"
```

---

## Configuration

### Agent Frontmatter

Declare MCP dependencies in your agent's YAML frontmatter:

```yaml
---
name: r-developer
description: R package development with MCP integration
tools: [Read, Write, Edit, Bash, Grep, Glob]
model: claude-3-5-sonnet-20241022
version: "1.0.0"
mcp_servers: [r-mcptools, r-mcp-server]
---
```

### Server Configuration File

For complex setups, use a configuration file:

```json
// ~/.claude/mcp-config.json
{
  "servers": {
    "r-mcptools": {
      "command": "R",
      "args": ["--slave", "-e", "mcptools::serve()"],
      "env": {
        "R_LIBS_USER": "/path/to/r/libraries"
      }
    },
    "r-mcp-server": {
      "command": "node",
      "args": ["/path/to/r-mcp-server/index.js"],
      "timeout": 30000
    }
  }
}
```

---

## Agent Integration

### Declaring Dependencies

Always list required MCP servers in your agent documentation:

```markdown
## Tool Requirements

- **Required Tools**: Read, Write, Edit, Grep, Glob
- **Optional Tools**: Bash (for R CMD operations)
- **MCP Servers**:
  - **r-mcptools** (required): Package management, help system
  - **r-mcp-server** (optional): Direct code execution
```

### Graceful Degradation

Design agents to work with reduced functionality when MCP servers are unavailable:

```markdown
## Functionality Matrix

| Feature | Without MCP | With r-mcptools | With r-mcp-server |
|---------|-------------|-----------------|-------------------|
| Code Review | ✅ Full | ✅ Enhanced | ✅ Enhanced |
| Package Install | ❌ Manual | ✅ Automated | ✅ Automated |
| Help Lookup | ❌ WebFetch | ✅ Native | ✅ Native |
| Code Execution | ❌ None | ❌ Limited | ✅ Full |
| Data Analysis | ❌ None | ❌ Limited | ✅ Full |
```

### Error Handling

Document how your agent handles MCP failures:

```markdown
## MCP Error Handling

If MCP servers are unavailable, this agent will:
1. Attempt to complete the task using available tools
2. Provide instructions for manual completion
3. Suggest MCP server installation if beneficial
```

---

## Usage Examples

### Example 1: R Package Installation

```markdown
**User**: Install the tidyverse package

**Agent** (with r-mcptools):
Using r-mcptools to install tidyverse...

✅ Successfully installed tidyverse 2.0.0
   Includes: ggplot2, dplyr, tidyr, readr, purrr, tibble, stringr, forcats

**Agent** (without MCP):
To install tidyverse, run this in your R console:
```r
install.packages("tidyverse")
```
```

### Example 2: Interactive R Analysis

```markdown
**User**: Calculate summary statistics for the mtcars dataset

**Agent** (with r-mcp-server):
Executing R code via r-mcp-server...

```r
summary(mtcars)
```

Output:
      mpg             cyl             disp
 Min.   :10.40   Min.   :4.000   Min.   : 71.1
 1st Qu.:15.43   1st Qu.:4.000   1st Qu.:120.8
 Median :19.20   Median :6.000   Median :196.3
 Mean   :20.09   Mean   :6.188   Mean   :230.7
 ...

**Agent** (without MCP):
I've written the analysis code to `analysis.R`. Run it with:
```bash
Rscript analysis.R
```
```

### Example 3: Documentation Lookup

```markdown
**User**: Show me how to use dplyr::filter

**Agent** (with r-mcptools):
Fetching documentation for dplyr::filter...

## filter - Subset rows using column values

### Description
The filter() function is used to subset a data frame, retaining all
rows that satisfy your conditions.

### Usage
filter(.data, ..., .preserve = FALSE)

### Arguments
- `.data`: A data frame
- `...`: Expressions that return a logical value

### Examples
filter(mtcars, cyl == 4)
filter(mtcars, cyl == 4, mpg > 20)
```

---

## Troubleshooting

### Server Won't Start

**Symptom**: MCP server fails to initialize

**Solutions**:
1. Check server command is correct:
   ```bash
   claude mcp list  # Verify configuration
   ```

2. Test server manually:
   ```bash
   R --slave -e "mcptools::serve()"  # Should start without errors
   ```

3. Check dependencies are installed:
   ```r
   # In R console
   library(mcptools)  # Should load without errors
   ```

### Connection Timeout

**Symptom**: Operations hang or timeout

**Solutions**:
1. Increase timeout in configuration:
   ```json
   {
     "timeout": 60000
   }
   ```

2. Check for blocking operations in server

3. Restart the MCP server:
   ```bash
   claude mcp restart <server-name>
   ```

### Permission Errors

**Symptom**: Server can't access files or resources

**Solutions**:
1. Check file permissions
2. Verify server has necessary environment variables
3. Run server with appropriate user permissions

### Data Transfer Issues

**Symptom**: Data corruption or encoding errors

**Solutions**:
1. Use appropriate encoding (UTF-8)
2. Check data size limits
3. Use binary format for large data (.rds instead of .csv)

---

## Creating Custom MCP Servers

### Server Structure

```javascript
// Basic MCP server structure (Node.js)
const { Server } = require('@modelcontextprotocol/sdk');

const server = new Server({
  name: 'my-custom-server',
  version: '1.0.0'
});

// Define tools
server.defineTool({
  name: 'my_tool',
  description: 'What this tool does',
  parameters: {
    type: 'object',
    properties: {
      input: { type: 'string', description: 'Input parameter' }
    },
    required: ['input']
  },
  handler: async (params) => {
    // Tool implementation
    return { result: `Processed: ${params.input}` };
  }
});

server.start();
```

### Best Practices

1. **Clear Tool Names**: Use descriptive, action-oriented names
2. **Comprehensive Descriptions**: Help Claude understand when to use each tool
3. **Input Validation**: Validate all parameters before processing
4. **Error Handling**: Return meaningful error messages
5. **Documentation**: Document all tools and their parameters
6. **Logging**: Include logging for debugging

### Testing

```bash
# Test server standalone
node my-server.js

# Test with Claude Code
claude mcp add my-server "node /path/to/my-server.js"
claude mcp test my-server
```

---

## Resources

- [MCP Specification](https://modelcontextprotocol.io/)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [r-mcptools GitHub](https://github.com/user/r-mcptools)
- [Agent Development Guide](agent-development-guide.md)

---

**Need help?** Open an issue or check existing MCP server implementations for examples! 🛠️
