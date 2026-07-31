# 🚀 Day 06 – Read & Write Text Files in Linux

## 📌 Objective
Learn how to create, write, append, and read text files using basic Linux commands.

---

## 1. Create a File

```bash
touch notes.txt
```

Creates an empty file named `notes.txt`.

---

## 2. Write Text to a File

```bash
echo "Line 1" > notes.txt
```

Writes text to the file (overwrites existing content).

---

## 3. Append Text to a File

```bash
echo "Line 2" >> notes.txt
```

Adds a new line to the end of the file without removing existing content.

---

## 4. Append Using `tee`

```bash
echo "Line 3" | tee -a notes.txt
```

Displays the text on the terminal and appends it to the file.

---

## 5. View File Contents

```bash
cat notes.txt
```

Displays the complete contents of the file.

---

## 6. View the First Lines

```bash
head -n 2 notes.txt
```

Shows the first 2 lines of the file.

---

## 7. View the Last Lines

```bash
tail -n 2 notes.txt
```

Shows the last 2 lines of the file.

---

## ✅ Summary

| Command | Purpose |
|---------|---------|
| `touch` | Create a new empty file |
| `>` | Write and overwrite file contents |
| `>>` | Append new content to a file |
| `tee -a` | Display and append output to a file |
| `cat` | View the entire file |
| `head` | View the beginning of a file |
| `tail` | View the end of a file |

### 🎯 Key Learning
Linux provides simple yet powerful commands to create, edit, append, and read text files, making file management efficient for everyday DevOps tasks.