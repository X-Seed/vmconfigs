#!/bin/bash
shopt -s nullglob
for d in /sys/kernel/iommu_groups/*/devices/*; do
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done;

IOMMU Group 53 82:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU106 [GeForce RTX 2070 Rev. A] [10de:1f07] (rev a1)
IOMMU Group 53 82:00.1 Audio device [0403]: NVIDIA Corporation TU106 High Definition Audio Controller [10de:10f9] (rev a1)