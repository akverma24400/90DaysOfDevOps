# Day 38 – YAML Basics

Completed Day 38 of my **90 Days of DevOps** journey by practicing YAML syntax, writing configuration files, and validating them with `yamllint`.

## Tasks Completed

- Created a personal YAML file with key-value pairs, including strings, a number, and a boolean.
- Added DevOps tools as a block list and hobbies as an inline list.
- Practiced nested objects for server details and database credentials.
- Explored multi-line strings using `|` and `>`.
- Practiced validation and correcting indentation and formatting issues.
- Compared the challenge examples to understand how indentation changes data.

## Learning Notes

### Two ways to write lists

- **Block style:** Each item appears on a separate line, starting with `-`.
- **Inline (flow) style:** Items appear inside square brackets, separated by commas, such as `[Docker, Git, Linux]`.

### Nested objects

Indentation groups related keys under a parent. Database credentials should be a mapping containing `user` and `password`, rather than separate list entries.

### Multi-line strings

| Style | Behavior | Use case |
| --- | --- | --- |
| `\|` | Preserves line breaks | Startup scripts and multi-line commands |
| `>` | Usually folds ordinary line breaks into spaces; blank lines can preserve breaks | Descriptions and paragraphs |

### Validation

Used `yamllint` to check YAML formatting. Tabs cannot be used for indentation. Broken indentation can cause a parsing error or change the meaning of the data; the exact error depends on the edit.

Trailing spaces should also be removed when flagged by the linter. A successful syntax check does not guarantee the file has the intended structure.

### Spot the Difference

Block 1 contains two separate tools: `docker` and `kubernetes`.

In Block 2, the extra indentation before `- kubernetes` makes it a continuation of the first item's text. A YAML parser can read this as **one string: `docker - kubernetes`**, rather than two tools. It is therefore structurally wrong for the task, even though it can be valid YAML.

To fix it, align both list-item dashes at the same indentation level, as shown in Block 1.

## Key Takeaways

- Use consistent spaces for indentation, never tabs.
- Keep a space after the colon in key-value pairs.
- Align sibling keys and list items consistently.
- Use `true` or `false` for clear boolean values.
- Validate both syntax and the resulting data structure.

**Outcome:** Built a foundation for reading and writing YAML-based DevOps configurations and CI/CD workflows.

Reference: [YAML 1.2.2 specification](https://yaml.org/spec/1.2.2/).
