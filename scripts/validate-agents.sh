#!/bin/bash
# validate-agents.sh - Validates Claude Code agent definitions
# Usage: ./scripts/validate-agents.sh [agent-file]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0

print_header() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Claude Code Agent Validator${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Validate a single agent file
validate_agent() {
    local file="$1"
    local filename=$(basename "$file")
    local errors=0
    local warns=0

    echo -e "${BLUE}Validating:${NC} $filename"
    echo "────────────────────────────────────────────"

    # Check file exists
    if [[ ! -f "$file" ]]; then
        echo -e "  ${RED}✗${NC} File not found: $file"
        return 1
    fi

    # Check for frontmatter markers
    if ! head -1 "$file" | grep -q "^---$"; then
        echo -e "  ${RED}✗${NC} No YAML frontmatter found (must start with ---)"
        return 1
    fi

    # Extract and validate required fields
    # name
    local name=$(grep "^name:" "$file" | head -1 | sed 's/name: *//')
    if [[ -z "$name" ]]; then
        echo -e "  ${RED}✗${NC} Missing required field: name"
        ((errors++))
    elif [[ ! "$name" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]] && [[ ! "$name" =~ ^[a-z0-9]$ ]]; then
        echo -e "  ${RED}✗${NC} Invalid name format: '$name' (must be kebab-case)"
        ((errors++))
    else
        echo -e "  ${GREEN}✓${NC} name: $name"
    fi

    # description
    local description=$(grep "^description:" "$file" | head -1 | sed 's/description: *//')
    if [[ -z "$description" ]]; then
        echo -e "  ${RED}✗${NC} Missing required field: description"
        ((errors++))
    else
        local desc_len=${#description}
        if [[ $desc_len -lt 10 ]]; then
            echo -e "  ${RED}✗${NC} Description too short ($desc_len chars, min 10)"
            ((errors++))
        elif [[ $desc_len -gt 200 ]]; then
            echo -e "  ${YELLOW}⚠${NC} Description may be too long ($desc_len chars)"
            ((warns++))
        else
            echo -e "  ${GREEN}✓${NC} description: $desc_len chars"
        fi
    fi

    # tools
    local tools=$(grep "^tools:" "$file" | head -1 | sed 's/tools: *//')
    if [[ -z "$tools" ]]; then
        echo -e "  ${RED}✗${NC} Missing required field: tools"
        ((errors++))
    elif [[ "$tools" == "[]" ]]; then
        echo -e "  ${RED}✗${NC} Tools list is empty"
        ((errors++))
    else
        echo -e "  ${GREEN}✓${NC} tools: $tools"
    fi

    # model
    local model=$(grep "^model:" "$file" | head -1 | sed 's/model: *//')
    if [[ -z "$model" ]]; then
        echo -e "  ${RED}✗${NC} Missing required field: model"
        ((errors++))
    else
        echo -e "  ${GREEN}✓${NC} model: $model"
    fi

    # version
    local version=$(grep "^version:" "$file" | head -1 | sed 's/version: *"\{0,1\}//' | sed 's/"\{0,1\}$//')
    if [[ -z "$version" ]]; then
        echo -e "  ${RED}✗${NC} Missing required field: version"
        ((errors++))
    elif [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "  ${YELLOW}⚠${NC} Version not in semver format: $version"
        ((warns++))
    else
        echo -e "  ${GREEN}✓${NC} version: $version"
    fi

    # author
    local author=$(grep "^author:" "$file" | head -1 | sed 's/author: *//')
    if [[ -z "$author" ]]; then
        echo -e "  ${RED}✗${NC} Missing required field: author"
        ((errors++))
    else
        echo -e "  ${GREEN}✓${NC} author: $author"
    fi

    # Optional: Check for recommended sections
    echo ""
    echo "  Sections:"

    if grep -q "^## Purpose" "$file"; then
        echo -e "  ${GREEN}✓${NC} Purpose section present"
    else
        echo -e "  ${YELLOW}⚠${NC} Missing: ## Purpose"
        ((warns++))
    fi

    if grep -q "^## Capabilities" "$file"; then
        echo -e "  ${GREEN}✓${NC} Capabilities section present"
    else
        echo -e "  ${YELLOW}⚠${NC} Missing: ## Capabilities"
        ((warns++))
    fi

    if grep -q "^## Examples" "$file"; then
        echo -e "  ${GREEN}✓${NC} Examples section present"
    else
        echo -e "  ${YELLOW}⚠${NC} Missing: ## Examples"
        ((warns++))
    fi

    if grep -q "^## Limitations" "$file"; then
        echo -e "  ${GREEN}✓${NC} Limitations section present"
    else
        echo -e "  ${YELLOW}⚠${NC} Missing: ## Limitations"
        ((warns++))
    fi

    # Summary for this file
    echo ""
    if [[ $errors -eq 0 ]]; then
        if [[ $warns -eq 0 ]]; then
            echo -e "  ${GREEN}Result: PASSED${NC}"
        else
            echo -e "  ${YELLOW}Result: PASSED with $warns warning(s)${NC}"
        fi
        echo ""
        return 0
    else
        echo -e "  ${RED}Result: FAILED ($errors error(s), $warns warning(s))${NC}"
        echo ""
        return 1
    fi
}

# Main execution
main() {
    print_header

    local agents_dir=".claude/agents"
    local target_files=()

    # Determine which files to validate
    if [[ $# -gt 0 ]]; then
        target_files=("$@")
    elif [[ -d "$agents_dir" ]]; then
        for file in "$agents_dir"/*.md; do
            [[ -f "$file" ]] && target_files+=("$file")
        done
    else
        echo -e "${RED}Error: No agent files found${NC}"
        echo "Usage: $0 [agent-file...]"
        exit 1
    fi

    if [[ ${#target_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No agent files to validate${NC}"
        exit 0
    fi

    echo "Found ${#target_files[@]} agent file(s) to validate"
    echo ""

    # Validate each file
    for file in "${target_files[@]}"; do
        ((TOTAL++))
        if validate_agent "$file"; then
            ((PASSED++))
        else
            ((FAILED++))
        fi
    done

    # Final summary
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Summary${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  Total:  $TOTAL"
    echo -e "  ${GREEN}Passed: $PASSED${NC}"
    echo -e "  ${RED}Failed: $FAILED${NC}"
    echo ""

    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}All agents validated successfully! ✨${NC}"
        echo ""
        exit 0
    else
        echo -e "${RED}Validation failed for $FAILED agent(s)${NC}"
        echo ""
        exit 1
    fi
}

main "$@"
