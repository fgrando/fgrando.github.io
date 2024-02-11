# ACPI MSDM table (PC windows serial)
11/Feb/2024

To see the saved contents run:

    sudo cat /sys/firmware/acpi/tables/MSDM

Example output:

    MSDMUbLENOVOTP-N2U  PPTECFZGFK-ABCDE-12345-FGHIJ-67890

To get the data as binary:

    sudo acpidump -n MSDM -b >  msdm.dat

*Install "acpica-tools" package to use acpidump*

VirtualBox can use this file in the VM to get the serial directly:

    vboxmanage setextradata "VM name" "VBoxInternal/Devices/acpi/0/Config/CustomTable" /the/path/to/msdm.dat
