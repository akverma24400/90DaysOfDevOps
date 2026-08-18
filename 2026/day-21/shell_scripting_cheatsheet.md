# Day 21 – Shell Scripting Cheat Sheet

A practical quick-reference guide for Bash scripting, focused on everyday DevOps tasks.

---

## Quick Reference Table

| Topic | Key Syntax | Example |
|---|---|---|
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Argument | `$1`, `$2` | `./script.sh arg1` |
| If | `if [ condition ]; then` | `if [ -f file ]; then` |
| For loop | `for i in list; do` | `for i in 1 2 3; do` |
| Function | `name() { ... }` | `greet() { echo "Hi"; }` |
| Grep | `grep pattern file` | `grep -i "error" log.txt` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt` |
| Read | `read VAR` | `read -p "Name: " name` |
| Case | `case "$x" in` | `case "$x" in start) ... ;; esac` |
| Exit code | `$?` | `command; echo $?` |
| Loop | `while condition; do` | `while read line; do ...; done` |
| File test | `[ -f file ]` | `if [ -f app.log ]; then` |

---

## 1. Basics

### Shebang

The shebang tells the operating system which interpreter should execute the script.

```bash
#!/bin/bash

echo "Hello, DevOps!"
```

### Running a Script

```bash
chmod +x script.sh
./script.sh
```

You can also run it directly with Bash:

```bash
bash script.sh
```

### Comments

Use `#` for comments. Comments are ignored by the shell.

```bash
# This is a comment
echo "Hello"  # Inline comment
```

### Variables

Assign values without spaces around `=`.

```bash
NAME="Akash"
echo "$NAME"
```

Quoting behaves differently:

```bash
VAR="DevOps"

echo $VAR       # DevOps
echo "$VAR"     # DevOps; preserves spaces safely
echo '$VAR'     # Prints literal $VAR
```

**Best practice:** Prefer `"$VAR"` when expanding variables.

### Reading User Input

```bash
read -p "Enter your name: " name
echo "Hello, $name"
```

### Command-Line Arguments

```bash
#!/bin/bash

echo "Script: $0"
echo "First argument: $1"
echo "Arguments count: $#"
echo "All arguments: $@"
echo "Previous command exit code: $?"
```

Example:

```bash
./script.sh DevOps Linux
```

- `$0` → script name
- `$1`, `$2` → first and second arguments
- `$#` → number of arguments
- `$@` → all arguments
- `$?` → exit status of the previous command

---

## 2. Operators and Conditionals

### String Comparisons

```bash
a="DevOps"
b="Cloud"

[ "$a" = "$b" ]    # Equal
[ "$a" != "$b" ]   # Not equal
[ -z "$a" ]        # Empty string
[ -n "$a" ]        # Non-empty string
```

### Integer Comparisons

```bash
a=10
b=20

[ "$a" -eq "$b" ]  # Equal
[ "$a" -ne "$b" ]  # Not equal
[ "$a" -lt "$b" ]  # Less than
[ "$a" -gt "$b" ]  # Greater than
[ "$a" -le "$b" ]  # Less than or equal
[ "$a" -ge "$b" ]  # Greater than or equal
```

### File Test Operators

```bash
[ -f file ]  # Regular file
[ -d dir ]   # Directory
[ -e path ]  # Exists
[ -r file ]  # Readable
[ -w file ]  # Writable
[ -x file ]  # Executable
[ -s file ]  # Exists and has size greater than zero
```

Example:

```bash
if [ -f "app.log" ]; then
    echo "Log file exists"
fi
```

### If / Elif / Else

```bash
if [ "$1" -gt 80 ]; then
    echo "High"
elif [ "$1" -gt 50 ]; then
    echo "Medium"
else
    echo "Low"
fi
```

### Logical Operators

```bash
[ "$age" -ge 18 ] && echo "Adult"
[ "$status" = "failed" ] || echo "Not failed"
[ ! -f "app.log" ] && echo "File missing"
```

- `&&` → run next command if previous succeeds
- `||` → run next command if previous fails
- `!` → negate a condition

### Case Statement

Useful when handling multiple fixed choices.

```bash
case "$1" in
    start)
        echo "Starting service"
        ;;
    stop)
        echo "Stopping service"
        ;;
    restart)
        echo "Restarting service"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        ;;
esac
```

---

## 3. Loops

### For Loop – List Based

```bash
for city in Delhi Mumbai Pune; do
    echo "$city"
done
```

### For Loop – C Style

```bash
for ((i=1; i<=5; i++)); do
    echo "$i"
done
```

### While Loop

Runs while the condition is true.

```bash
count=1

while [ "$count" -le 5 ]; do
    echo "$count"
    ((count++))
done
```

### Until Loop

Runs until the condition becomes true.

```bash
count=1

until [ "$count" -gt 5 ]; do
    echo "$count"
    ((count++))
done
```

### Break

Stops the loop immediately.

```bash
for i in 1 2 3 4 5; do
    [ "$i" -eq 3 ] && break
    echo "$i"
done
```

### Continue

Skips the current iteration.

```bash
for i in 1 2 3 4 5; do
    [ "$i" -eq 3 ] && continue
    echo "$i"
done
```

### Looping Over Files

```bash
for file in *.log; do
    echo "Processing: $file"
done
```

For filenames that may contain spaces, prefer a safer pattern such as `find` with `-print0`.

### Looping Over Command Output

```bash
while read -r line; do
    echo "$line"
done < server_list.txt
```

You can also pipe command output:

```bash
printf '%s\n' "Delhi" "Mumbai" "Pune" |
while read -r city; do
    echo "City: $city"
done
```

---

## 4. Functions

### Defining a Function

```bash
greet() {
    echo "Hello, DevOps!"
}
```

### Calling a Function

```bash
greet
```

### Passing Arguments to Functions

Function arguments use `$1`, `$2`, etc.

```bash
greet() {
    echo "Hello, $1"
}

greet "Akash"
```

### `return` vs `echo`

`return` sends an exit status from `0` to `255`; it does not return normal text.

```bash
check_file() {
    [ -f "$1" ]
    return $?
}

if check_file "app.log"; then
    echo "File exists"
fi
```

Use `echo` when you want to produce a value that can be captured:

```bash
get_name() {
    echo "Akash"
}

name=$(get_name)
echo "$name"
```

### Local Variables

Use `local` to keep variables inside a function.

```bash
show_status() {
    local status="Running"
    echo "$status"
}

show_status
```

---

## 5. Text Processing Commands

### `grep`

Search text using patterns.

```bash
grep "ERROR" app.log
grep -i "error" app.log
grep -r "ERROR" /var/log/
grep -c "ERROR" app.log
grep -n "ERROR" app.log
grep -v "INFO" app.log
grep -E "ERROR|WARNING" app.log
```

Useful flags:

- `-i` → case-insensitive
- `-r` → recursive
- `-c` → count matches
- `-n` → show line numbers
- `-v` → invert match
- `-E` → extended regular expressions

### `awk`

Useful for columns, patterns, and structured text.

```bash
awk '{print $1}' access.log
awk -F: '{print $1}' /etc/passwd
awk '$3 > 80 {print $1, $3}' data.txt
```

`BEGIN` runs before input; `END` runs after input.

```bash
awk 'BEGIN {print "Report"} {count++} END {print "Lines:", count}' app.log
```

### `sed`

Search and replace text or edit streams.

```bash
sed 's/old/new/g' file.txt
sed '/ERROR/d' app.log
sed -i 's/foo/bar/g' config.txt
```

- `s/old/new/g` → replace all occurrences per line
- `/pattern/d` → delete matching lines
- `-i` → edit the file in place

### `cut`

Extract fields or character ranges.

```bash
cut -d: -f1 /etc/passwd
cut -d, -f1,3 users.csv
cut -c1-10 file.txt
```

### `sort`

```bash
sort names.txt
sort -n numbers.txt
sort -r names.txt
sort -u names.txt
```

- Default → alphabetical
- `-n` → numerical
- `-r` → reverse
- `-u` → unique

### `uniq`

Usually works best after sorting.

```bash
sort names.txt | uniq
sort names.txt | uniq -c
sort names.txt | uniq -d
```

- `-c` → count occurrences
- `-d` → show only duplicates

### `tr`

Translate or delete characters.

```bash
echo "devops" | tr 'a-z' 'A-Z'
echo "hello 123" | tr -d '0-9'
echo "one,two,three" | tr ',' '\n'
```

### `wc`

Count lines, words, and characters.

```bash
wc -l app.log
wc -w file.txt
wc -c file.txt
```

- `-l` → lines
- `-w` → words
- `-c` → bytes

### `head` / `tail`

```bash
head -n 10 app.log
tail -n 10 app.log
tail -f app.log
```

- `head -n N` → first N lines
- `tail -n N` → last N lines
- `tail -f` → follow a growing log in real time

---

## 6. Useful Patterns and One-Liners

### Find and Delete Files Older Than N Days

```bash
find /path/to/logs -type f -name "*.log" -mtime +7 -delete
```

**Tip:** Run the same command without `-delete` first to verify what will be removed.

### Count Lines in All `.log` Files

```bash
wc -l *.log
```

For a recursive count:

```bash
find . -name "*.log" -type f -exec wc -l {} +
```

### Replace a String Across Multiple Files

```bash
sed -i 's/old_value/new_value/g' *.conf
```

### Check If a Service Is Running

```bash
systemctl is-active --quiet nginx && echo "Running" || echo "Stopped"
```

### Monitor Disk Usage With an Alert

```bash
df -P / | awk 'NR==2 {gsub("%","",$5); if ($5 > 80) print "ALERT: Disk usage is " $5 "%"}'
```

### Tail a Log and Filter Errors in Real Time

```bash
tail -f app.log | grep --line-buffered -i "error"
```

### Find the Top 10 IP Addresses in an Access Log

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -n 10
```

### Check HTTP Status Code

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://example.com
```

---

## 7. Error Handling and Debugging

### Exit Codes

`0` normally means success; a non-zero value indicates failure.

```bash
ls /tmp
echo $?
```

Explicit exit:

```bash
echo "Success"
exit 0
```

```bash
echo "Something failed"
exit 1
```

### `set -e`

Exit when a command fails.

```bash
#!/bin/bash
set -e

mkdir /tmp/myapp
cp app.conf /tmp/myapp/
echo "Deployment completed"
```

### `set -u`

Treat unset variables as errors.

```bash
#!/bin/bash
set -u

echo "$NAME"
```

If `NAME` is unset, the script exits with an error.

### `set -o pipefail`

Makes a pipeline fail if any command in it fails.

```bash
set -o pipefail

cat missing.txt | grep "ERROR"
echo $?
```

### `set -x`

Print commands as Bash executes them; useful for debugging.

```bash
#!/bin/bash
set -x

NAME="DevOps"
echo "$NAME"
```

Disable tracing with:

```bash
set +x
```

### `trap`

Run cleanup logic when the script exits.

```bash
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/myapp.lock
}

trap cleanup EXIT
```

A common production pattern:

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    rm -f /tmp/myapp.lock
}

trap cleanup EXIT

touch /tmp/myapp.lock
echo "Running deployment..."
```

---

## 8. Practical DevOps Patterns

### Check Root Privileges

```bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi
```

### Check Command Availability

```bash
if command -v docker >/dev/null 2>&1; then
    echo "Docker is installed"
else
    echo "Docker is not installed"
fi
```

### Create a Timestamp

```bash
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
echo "$timestamp"
```

### Backup a Directory

```bash
tar -czf "backup_$(date +%Y%m%d_%H%M%S).tar.gz" /path/to/data
```

### Count Running Docker Containers

```bash
docker ps -q | wc -l
```

### Check Memory Usage

```bash
free -h
```

### Check Disk Usage

```bash
df -h
```

### Check Running Processes

```bash
ps aux
```

---

## 9. Bash Best Practices

### Use Strict Mode

For many automation scripts:

```bash
set -euo pipefail
```

This combines:

- `-e` → stop on command failure
- `-u` → catch unset variables
- `pipefail` → catch failures inside pipelines

### Quote Variables

Prefer:

```bash
rm -- "$file"
```

instead of:

```bash
rm $file
```

Quoting helps prevent problems with spaces and special characters.

### Use Meaningful Variable Names

Prefer:

```bash
backup_dir="/var/backups"
```

over:

```bash
x="/var/backups"
```

### Validate Inputs

```bash
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi
```

### Make Scripts Fail Clearly

```bash
if ! cp "$source" "$destination"; then
    echo "ERROR: Backup failed" >&2
    exit 1
fi
```

### Use `shellcheck`

If available, run:

```bash
shellcheck script.sh
```

It can catch many common Bash scripting mistakes before they reach production.

---

## 10. Mini Script Template

A useful starting template for DevOps automation:

```bash
#!/bin/bash

set -euo pipefail

cleanup() {
    echo "Cleaning up..."
}

trap cleanup EXIT

usage() {
    echo "Usage: $0 <environment>"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

environment="$1"

echo "Starting task for: $environment"

# Your automation here

echo "Task completed successfully"
exit 0
```

---

## Quick Revision

```text
#!/bin/bash       → Bash interpreter
$0                → Script name
$1, $2            → Arguments
$#                → Argument count
$@                → All arguments
$?                → Last exit status

if / elif / else  → Conditions
case              → Multiple choices
for               → Iterate over items
while             → Loop while condition is true
until             → Loop until condition is true
break             → Exit loop
continue          → Skip iteration

function()        → Define function
local             → Function-local variable
return            → Function exit status
echo              → Print/capture output

grep              → Search text
awk               → Process columns/data
sed               → Stream editing
cut               → Extract fields
sort              → Sort data
uniq              → Remove/count duplicates
tr                → Translate/delete characters
wc                → Count
head/tail         → Inspect beginning/end of files

set -e            → Exit on error
set -u            → Error on unset variables
pipefail          → Catch pipeline failures
set -x            → Trace commands
trap              → Run cleanup/actions on signals or exit
```

---

## Final Takeaway

Shell scripting is one of the most useful automation skills in DevOps. The goal is not to memorize every command, but to know how to combine Bash features, Linux commands, conditions, loops, functions, text-processing tools, and error handling to automate repetitive tasks reliably.

**Day 21 complete — Shell Scripting Cheat Sheet created as a personal DevOps reference.**
