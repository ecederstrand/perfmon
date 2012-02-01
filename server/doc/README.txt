#
# The PerfMon script produces packages of the files necessary for a FreeBSD
# installation. The packages can be copied to an empty disk (fdisk/bsdlabel/
# newfs'd) to create a fully usable FreeBSD installation.
#
# The script is part of the PerfMon set of tools to monitor performance of
# FreeBSD. The tools can be used to set up a fully automated performance 
# testing system.
#
# The script assumes a DHCP server has already been set up, supplying the 
# slaves with an IP address, hostname, TFTP server address (pointing to the 
# pxeboot loader) and NFS root filesystem address (pointing to a minimal 
# FreeBSD system for the installation process), and TFTP + NFS services running
# at the specified addresses. Also, sysutils/fastest_cvsup and devel/ccache 
# must be installed on the machine running this script. The machine must be 
# running FreeBSD versions 7.0 or later. This script must be run as root. 
# Finally, the directory structure and config files necessary for this script 
# must be created in advance.
#
# In addition to the variables supplied here, the build process can be modified
# through the settings in server/conf/make.conf and server/conf/src.conf. A full
# ports tree is required. The ports tree will be updated by portsnap. The 
# script is largely self-contained and should not touch files outside the 
# directory where it is installed. Exceptions are:
#   /root/.ccache
#   /var/db/sup/*
#
# The directory structure necessary for PerfMon:
# ----------------------------------------------
# pxe/boot                      - location of the pxeloader
# pxe/conf                      - config files for diskless slave installation
# pxe/diskless          - minimal distribution for diskless slave installation
# server/bin            - location of this script
# server/conf           - config files for this script and this host
# server/log            - log files produced by this script
# server/obj            - obj directory for make
# server/src            - source files for base system
# slaves/conf           - config files for the slave install
# slaves/ports          - config files for installing ports on the slaves
# slaves/ports/packages - packages pkg_add'ed by slaves
# slaves/src/packages   - distribution tarballs for slave installation
#

