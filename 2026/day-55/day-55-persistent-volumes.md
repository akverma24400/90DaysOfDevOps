# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)

## Overview

Today I explored why a Pod needs persistent storage and how Kubernetes supplies it through Persistent Volumes (PVs), Persistent Volume Claims (PVCs), and StorageClasses. My manifests are kept in a separate folder, so this README focuses on what each task demonstrates.

## Task 1: Data loss with an ephemeral volume

I mounted an `emptyDir` volume at `/data`. When the Pod started, it wrote a timestamped message to `message.txt`. I deleted and recreated the Pod, then checked the file again.

**Observation:** The new Pod had a different timestamp. An `emptyDir` starts empty for each new Pod, so the original message was lost. A container restart within the *same* Pod would not erase this volume.

## Task 2: Create a static PersistentVolume

I created a 1Gi PV manually, using `ReadWriteOnce`, a `Retain` reclaim policy, and a `hostPath` directory at `/tmp/k8s-pv-data`.

**Observation:** Before a PVC requested it, the PV status was `Available`. `ReadWriteOnce` allows a volume to be mounted read and write by one node at a time. `Retain` means Kubernetes leaves the PV and its underlying data for manual handling after its claim is deleted.

`hostPath` is suitable for this local practice exercise. It refers to a path on one specific node, so it is unsuitable as general shared or production storage.

## Task 3: Create a PersistentVolumeClaim

I created a PVC requesting 500Mi with `ReadWriteOnce`. The 1Gi manual PV could satisfy that request, so the PV and PVC became `Bound`.

**Observation:** The PVC's `VOLUME` column showed the name of the manual PV. I explicitly selected the manual PV and used an empty storage class name, which prevents the cluster's default StorageClass from assigning the claim to dynamically provisioned storage.

## Task 4: Keep data across Pod deletion

I mounted the manual PVC in a Pod and wrote the first message to the volume. After deleting and recreating the Pod, I appended a second message and read the file again.

**Observation:** The file contained messages from both Pod instances. The data belonged to the persistent volume rather than to the Pod's writable container layer.

**Multi-node note:** A `hostPath` PV points to a directory on a node. For this demonstration, both Pod instances must run on the same node; otherwise they may see different directories even though the PVC is bound. Check the assigned node before and after recreation.

## Task 5: Inspect StorageClasses

I inspected the StorageClasses available in my cluster. A StorageClass specifies a storage provisioner, reclaim policy, and volume binding mode. The default class, if one exists, is identified in the cluster's StorageClass listing.

**Record from your own cluster:**

| Detail | Your result |
| --- | --- |
| Default StorageClass | *Fill in from your cluster* |
| Provisioner | *Fill in from your cluster* |
| Reclaim policy | *Fill in from your cluster* |
| Volume binding mode | *Fill in from your cluster* |

The class may be named `standard`, but its name and settings depend on the cluster. With `WaitForFirstConsumer`, provisioning can wait until a Pod uses the claim.

## Task 6: Dynamic provisioning

I created a second PVC that requested an available StorageClass. Its provisioner created a PV for the claim, and a Pod mounted the PVC and wrote a message to it.

**Observation:** The message could be read through the Pod's `/data` mount. The PV bound to the dynamic PVC was created by the provisioner; the earlier manual PV was created from my own PV manifest.

**PV count:** If the cluster had no PVs before this exercise and both claims are still present, there should be two: one manual and one dynamically provisioned. Check the actual cluster listing for the real count. A dynamic PV might appear only after the consuming Pod is created, depending on the class's volume binding mode.

## Task 7: Cleanup and reclaim policies

I deleted the Pods first, followed by the PVCs, then observed the PVs. Deleting the manual PVC left its PV in the `Released` state because its reclaim policy was `Retain`; I then removed the PV object manually.

**Dynamic PV:** If its StorageClass uses `Delete`, the provisioner normally removes the PV and its underlying storage when the PVC is deleted. If it uses `Retain`, the PV remains `Released`. The actual result depends on the StorageClass observed in Task 5.

Deleting a retained PV object does not necessarily erase data in the underlying `hostPath` directory. That directory requires separate cleanup if the data is no longer needed.

## Key takeaways

| Storage | How it is created | Survives Pod deletion? | Behavior after PVC deletion |
| --- | --- | --- | --- |
| `emptyDir` | Defined in the Pod | No | No PVC involved |
| Static PV | Created manually | Yes | `Released` with `Retain` |
| Dynamic PV | Created by a StorageClass provisioner | Yes | Depends on its reclaim policy |

A PVC requests storage and a PV supplies it. Pod deletion and PVC deletion are different events: persistent data survives the first, while the PV's reclaim policy governs the second.
