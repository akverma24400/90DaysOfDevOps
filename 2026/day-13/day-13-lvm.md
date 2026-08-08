# 🐧 Day 13 – Linux Volume Management (LVM)

## 📌 Objective

As part of my **#90DaysOfDevOps** challenge, I learned and practiced **Linux Logical Volume Management (LVM)**.

The goal was to understand how Linux storage can be managed flexibly using:

- Physical Volumes (PV)
- Volume Groups (VG)
- Logical Volumes (LV)
- Filesystems
- Mount points

I completed all 6 tasks, from checking the available storage to extending the Logical Volume.

---

# 🛠️ Task 1 – Check Current Storage

First, I checked the available disks, partitions, LVM configuration, and filesystem usage.

### Commands Used

```bash
lsblk
pvs
vgs
lvs
df -h
```

These commands helped me understand the current storage configuration.

Since I did not have a spare `/dev/sdb` disk, I used the available NVMe device:

```text
/dev/nvme1n1
```

### 📸 Screenshot

> [Task 1 Output](images/check_current_storage.png)

---

# 💾 Task 2 – Create Physical Volume

The first step in LVM is to create a **Physical Volume (PV)**.

I initialized `/dev/nvme1n1` as a Physical Volume:

```bash
pvcreate /dev/nvme1n1
```

Then I verified it:

```bash
pvs
```

The disk was successfully recognized as an LVM Physical Volume.



---

# 📦 Task 3 – Create Volume Group

Next, I created a Volume Group named `devops-vg`.

```bash
vgcreate devops-vg /dev/nvme1n1
```

Then I verified the Volume Group:

```bash
vgs
```

The Volume Group was successfully created using the Physical Volume.

### 📸 Screenshot

[Task 3 Output](images/extend_volume.png)

---

# 🗂️ Task 4 – Create Logical Volume

Inside the `devops-vg` Volume Group, I created a **500 MB Logical Volume** named `app-data`.

```bash
lvcreate -L 500M -n app-data devops-vg
```

Then I verified the Logical Volume:

```bash
lvs
```

The Logical Volume was successfully created.



---

# 💽 Task 5 – Format and Mount the Logical Volume

After creating the Logical Volume, I formatted it with the **ext4 filesystem**.

```bash
mkfs.ext4 /dev/devops-vg/app-data
```

Then I created a mount point:

```bash
mkdir -p /mnt/app-data
```

I mounted the Logical Volume:

```bash
mount /dev/devops-vg/app-data /mnt/app-data
```

Finally, I checked the filesystem:

```bash
df -h /mnt/app-data
```

The Logical Volume was successfully mounted at:

```text
/mnt/app-data
```

### 📸 Screenshot

> [Task 5 Output](images/format&mount.png)

---

# 📈 Task 6 – Extend the Logical Volume

One of the main advantages of LVM is that storage can be increased when required.

Initially, the Logical Volume was:

```text
500 MB
```

I extended it by **200 MB**:

```bash
lvextend -L +200M /dev/devops-vg/app-data
```

The Logical Volume was now:

```text
500 MB + 200 MB = 700 MB
```

However, increasing the Logical Volume does not automatically resize the ext4 filesystem.

So I resized the filesystem using:

```bash
resize2fs /dev/devops-vg/app-data
```

Finally, I verified the new size:

```bash
df -h /mnt/app-data
```

---

# 🧠 LVM Structure

The complete LVM structure I created is:

```text
Physical Disk
     │
     ▼
Physical Volume (PV)
 /dev/nvme1n1
     │
     ▼
Volume Group (VG)
   devops-vg
     │
     ▼
Logical Volume (LV)
    app-data
     │
     ▼
ext4 Filesystem
     │
     ▼
 /mnt/app-data
```

---

# 📚 What I Learned

### 🔹 Physical Volume (PV)

A Physical Volume is a disk or partition initialized for use with LVM.

```bash
pvcreate /dev/nvme1n1
```

### 🔹 Volume Group (VG)

A Volume Group combines Physical Volumes into a storage pool.

```bash
vgcreate devops-vg /dev/nvme1n1
```

### 🔹 Logical Volume (LV)

A Logical Volume is created from the available space inside a Volume Group.

```bash
lvcreate -L 500M -n app-data devops-vg
```

### 🔹 Extending Storage

LVM allows Logical Volumes to be extended when more storage is required.

```bash
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
```

---

# 🛠️ Important Commands

| Command | Purpose |
|---|---|
| `lsblk` | Display disks and partitions |
| `pvs` | Display Physical Volumes |
| `vgs` | Display Volume Groups |
| `lvs` | Display Logical Volumes |
| `pvcreate` | Create a Physical Volume |
| `vgcreate` | Create a Volume Group |
| `lvcreate` | Create a Logical Volume |
| `mkfs.ext4` | Create an ext4 filesystem |
| `mount` | Mount a filesystem |
| `lvextend` | Extend a Logical Volume |
| `resize2fs` | Resize an ext4 filesystem |
| `df -h` | Check filesystem usage |

---

# ✅ Final Result

I successfully completed all 6 LVM tasks:

- ✅ Checked current storage
- ✅ Created a Physical Volume
- ✅ Created a Volume Group
- ✅ Created a Logical Volume
- ✅ Formatted and mounted the volume
- ✅ Extended the Logical Volume by 200 MB
- ✅ Resized the ext4 filesystem
- ✅ Verified the final storage

---

# 🎯 Key Takeaway

LVM makes Linux storage management more flexible. It allows us to create Logical Volumes from storage pools and increase their size when needed without recreating the entire storage setup.

This is an important concept for **Linux Administration, DevOps, Cloud Infrastructure, and System Administration**.

---

# 🚀 Day 13 Completed!

Another day completed in my **#90DaysOfDevOps** journey.

**Learn → Practice → Document → Share**

