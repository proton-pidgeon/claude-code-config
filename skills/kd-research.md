# Deep Research Assistant Skill

name: kd:research
description: Autonomous multi-source research tool that synthesizes findings into structured reports with BLUF, key concepts, and citations. Fire-and-forget workflow with OneDrive integration for mobile access.

---

## Overview

The `/research` skill is a fully autonomous research assistant that:
- Accepts a research prompt from the user
- Optionally uses contextual notes from your Notes Input folder
- Conducts multi-source research (web, code, documentation)
- Intelligently selects MCP tools based on research type
- Generates structured reports with BLUF and one-sentence key concepts
- Saves reports to OneDrive for mobile accessibility
- Returns immediately (fire-and-forget workflow)

## Quick Start

### Basic Usage

```
/research "What are the latest trends in LLM architecture?"
```

### With Specific Notes

```
/research --notes "AI-Research-Jan2026" "Expand on transformer architectures"
```

---

## How It Works

### 1. Invoke the Skill

You provide a research prompt:

```
/research "Compare Rust async/await with Python asyncio for high-concurrency systems"
```

### 2. Auto-Detect Notes Context (Optional)

The skill scans your `C:\Users\kevdu\OneDrive\Documents\Notes Input` folder and:
- Finds the most recently modified file or folder
- Asks for confirmation: "Using notes from: [filename]? (Y/n)"
- Proceeds with confirmed notes as research context

You can also manually specify notes:

```
/research --notes "backend-research.md" "research prompt here"
```

### 3. Analyze Research Type

The skill analyzes your prompt to determine research type:

| Trigger Words | Research Type | MCP Tools Used |
|---|---|---|
| "latest", "current", "2025", "trends" | Web Research | Tavily Web Search |
| "implementation", "how does", "codebase" | Code Analysis | Filesystem + Code Tools |
| "guide", "tutorial", "docs" | Documentation | Documentation Search |
| "previous", "past", "what did" | Historical Context | Serena Context |
| Complex prompts | Hybrid Research | Multiple tools in sequence |

### 4. Conduct Research

The skill:
- Launches a background research agent
- Selects and orchestrates appropriate MCP tools
- Gathers information from multiple sources
- Synthesizes findings into structured format
- Returns to you immediately ✓

### 5. Report Generation

While you continue working, the research agent:
- Creates a comprehensive report with sections:
  - **BLUF**: 2-3 sentence executive summary
  - **Key Concepts**: One-sentence summaries of critical findings
  - **Detailed Findings**: Full analysis organized by topic
  - **Methodology**: How the research was conducted
  - **Sources**: Complete citations with URLs
  - **Metadata**: Timestamp, research depth, confidence level
- Saves to: `C:\Users\kevdu\OneDrive\Documents\Research\YYYY-MM-DD-HH-MM-SS-topic.md`
- File syncs to OneDrive automatically (accessible on mobile)

---

## Report Format

### Example Report Structure

```markdown
# Research Report: Rust vs Python Async Performance

## BLUF
Rust's async/await provides superior performance (2-5x faster) for I/O-bound workloads with lower memory overhead, while Python's asyncio offers faster development velocity. Choice depends on whether raw performance or development speed is your priority.

## Key Concepts
- **Async/Await Syntax**: Rust uses `async/await` keywords with `Future` trait; Python uses `async def` with `await` expressions for cleaner syntax.
- **Performance Characteristics**: Rust achieves 2-5x throughput improvement on high-concurrency workloads due to zero-cost abstractions and memory efficiency.
- **Ecosystem Maturity**: Python's asyncio has broader library support; Rust's tokio runtime is rapidly catching up with specialized high-performance use cases.
- **Learning Curve**: Python asyncio easier to learn; Rust requires understanding ownership and lifetimes but catches more bugs at compile time.

## Detailed Findings

### Performance Analysis
[Full detailed analysis...]

### Syntax and Developer Experience
[Full detailed analysis...]

### Production Readiness
[Full detailed analysis...]

## Methodology
Conducted web research on recent benchmarks and performance studies, analyzed GitHub repositories and documentation, evaluated community feedback on Stack Overflow and Reddit. Used Tavily web search for current 2025 information and GitHub code analysis for real-world implementations.

## Sources & Citations
- [Tokio Runtime Documentation](https://tokio.rs/)
- [Python asyncio Official Documentation](https://docs.python.org/3/library/asyncio.html)
- [Rust vs Python Performance Benchmarks 2025](https://example.com)
- [GitHub: async-std vs tokio comparison](https://github.com/example)

## Metadata
- **Report Generated**: 2026-01-15 10:30:45
- **Research Type**: Hybrid (Web + Code Analysis)
- **Research Depth**: Comprehensive
- **Confidence Level**: High
- **MCP Tools Used**: Tavily Web Search, GitHub Code Analysis, Documentation Search
- **Notes Input Used**: "backend-research.md"
```

---

## Command Reference

### Basic Research

```
/research "What are the latest developments in quantum computing?"
```

### With Custom Notes

```
/research --notes "quantum-notes.md" "Focus on quantum error correction"
/research --notes "crypto-research" "Compare post-quantum cryptography standards"
```

### Complex Research

```
/research "Create a comprehensive comparison of Go vs Rust for systems programming, including performance, safety, concurrency, and ecosystem maturity"
```

---

## Output & Notifications

### Immediate Response

```
✓ Research queued: "Compare Rust async/await with Python asyncio..."
✓ Notes context: Using "backend-research.md"
✓ Report will be saved to: C:\Users\kevdu\OneDrive\Documents\Research\
✓ Estimated completion: 2-5 minutes
✓ Check OneDrive on mobile when ready
```

### Report Location

Reports follow this naming convention:

```
YYYY-MM-DD-HH-MM-SS-[topic-slug].md
Example: 2026-01-15-10-30-45-rust-async-performance.md
```

All reports automatically sync to OneDrive and are accessible on your phone/tablet.

---

## Tips & Best Practices

### Effective Research Prompts

**Good**: "Compare Rust async/await with Python asyncio for high-concurrency I/O-bound systems. Include performance metrics, learning curve, and ecosystem maturity as of 2025."

**Avoid**: "Tell me about async" (too vague, won't leverage MCP tools effectively)

### Using Notes for Context

Keep notes in `C:\Users\kevdu\OneDrive\Documents\Notes Input`:
- Collect initial research, hypotheses, or questions
- Use these as foundation for deep research
- Build incrementally with each research session

### Accessing Reports on Mobile

1. Open OneDrive app on phone/tablet
2. Navigate to `Documents > Research`
3. Reports appear within seconds of completion
4. BLUF section provides quick summary on small screens

### Combining Multiple Researches

Run multiple research queries in sequence:

```
/research "Query 1"
/research "Query 2"
/research "Query 3"
```

Each generates a separate timestamped report in your Research folder.

---

## Technical Details

### Supported MCP Tools

The skill automatically selects from:
- **Tavily Web Search**: Current information, trends, news
- **Serena Context**: Historical decisions, past research
- **Filesystem Tools**: Local codebases, documentation
- **GitHub Integration**: Repository analysis, code examples
- **Documentation Parsers**: API docs, guides, specifications

### File Locations

```
Input:
  C:\Users\kevdu\OneDrive\Documents\Notes Input\
  (auto-detected, most recent file/folder used)

Output:
  C:\Users\kevdu\OneDrive\Documents\Research\
  (timestamped reports saved here)
```

### Report Generation

- Research agent runs in background
- No interruption to user workflow
- Estimated completion: 2-5 minutes depending on research scope
- Reports are immediately accessible once synced to OneDrive

---

## Troubleshooting

### Reports Not Appearing

1. **Wait for sync**: OneDrive may take 30-60 seconds to sync
2. **Check path**: Verify `C:\Users\kevdu\OneDrive\Documents\Research\` exists
3. **Manual refresh**: Pull-to-refresh in OneDrive app

### Notes Not Detected

1. **Create Notes Input folder**: `C:\Users\kevdu\OneDrive\Documents\Notes Input\`
2. **Add files**: Place markdown or text files in this folder
3. **Wait for sync**: OneDrive needs to sync the files first

### MCP Tools Unavailable

If a tool isn't available, the skill gracefully falls back:
- Uses alternative tools from available set
- Completes research with reduced scope
- Includes note in Metadata section

---

## Examples

### Example 1: Current Events Research

```
/research "What are the major AI model releases and breakthroughs in January 2026?"
```

**Expected Report**: Uses Tavily web search for latest news, compiles timeline of releases, analyzes implications.

### Example 2: Code Analysis

```
/research "How does the async/await implementation in Tokio runtime work? Include thread pool architecture and task scheduling."
```

**Expected Report**: Analyzes GitHub repositories, reads documentation, synthesizes technical details about internal architecture.

### Example 3: Comparative Analysis

```
/research "Compare React, Vue, and Svelte for 2025. Include developer experience, performance, bundle size, and community ecosystem."
```

**Expected Report**: Web research for current benchmarks and trends, code analysis of example projects, synthesized comparison matrix.

### Example 4: With Context Notes

```
/research --notes "frontend-strategy.md" "Evaluate whether Vue 3 composition API is suitable for our team based on our current React expertise"
```

**Expected Report**: Uses your notes as context, researches Vue 3 adoption stories, provides targeted recommendation.

---

## Integration with Claude Code

This skill is designed to work seamlessly with Claude Code:

- **Fire-and-forget**: Returns immediately, doesn't block your workflow
- **OneDrive sync**: Reports accessible everywhere (desktop, mobile, web)
- **MCP integration**: Leverages all available Claude Code MCP tools
- **Context aware**: Can reference your previous notes and decisions
- **Structured output**: Consistent format enables easy scanning and reference

---

## Keyboard Shortcuts & Aliases

In Claude Code, you can save research queries as snippets:

```
/research "What are the latest {topic} developments in {year}?"
```

Save common prompts for quick research on recurring topics.

---

## Future Enhancements

Planned features:
- Research chains (one report builds on previous)
- Comparative reports (side-by-side analysis)
- Research history and related findings
- Export to PDF for presentations
- Integration with project documentation
- Custom report templates

---

## Questions?

For issues or feedback on the research skill, refer to:
- Claude Code documentation: https://github.com/anthropics/claude-code
- Report issues: https://github.com/anthropics/claude-code/issues

Happy researching! 🔍
