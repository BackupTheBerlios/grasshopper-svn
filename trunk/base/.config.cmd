deps_config := \
	target/generic/Config.in \
	target/device/x86/Config.in \
	target/device/Via/Config.in \
	target/device/Soekris/Config.in \
	target/device/Sharp/Config.in \
	target/device/jp/Config.in \
	target/device/In-Circuit/Config.in \
	target/device/Hitachi/Config.in \
	target/device/Atmel/Config.in \
	target/device/Arm/Config.in \
	target/device/AMD/Config.in \
	target/device/Config.in \
	target/u-boot/Config.in \
	target/powerpc/yaboot/Config.in \
	target/x86/syslinux/Config.in \
	target/x86/grub/Config.in \
	target/iso9660/Config.in \
	target/cpio/Config.in \
	target/tar/Config.in \
	target/squashfs/Config.in \
	target/jffs2/Config.in \
	target/ext2/Config.in \
	target/cloop/Config.in \
	target/cramfs/Config.in \
	target/Config.in \
	package/tcl/Config.in \
	package/ruby/Config.in \
	package/python/Config.in \
	package/microperl/Config.in \
	package/zlib/Config.in \
	package/lzma/Config.in \
	package/lzo/Config.in \
	package/gzip/Config.in \
	package/rxvt/Config.in \
	package/rdesktop/Config.in \
	package/dillo/Config.in \
	package/metacity/Config.in \
	package/freetype/Config.in \
	package/fontconfig/Config.in \
	package/gtk2-engines/Config.in \
	package/libgtk2/Config.in \
	package/libgtk12/Config.in \
	package/libglib2/Config.in \
	package/libglib12/Config.in \
	package/pango/Config.in \
	package/cairo/Config.in \
	package/atk/Config.in \
	package/tinyx/Config.in \
	package/xorg/Config.in \
	package/fbv/Config.in \
	package/sawman/Config.in \
	package/qtopia4/Config.in \
	package/qte/Config.in \
	package/tiff/Config.in \
	package/sdl/Config.in \
	package/libpng/Config.in \
	package/jpeg/Config.in \
	package/directfb/Config.in \
	package/dialog/Config.in \
	package/slang/Config.in \
	package/newt/Config.in \
	package/ncurses/Config.in \
	package/alsa-utils/Config.in \
	package/alsa/tools/Config.in \
	package/alsa/lib-plugin/Config.in \
	package/alsa-lib/Config.in \
	package/alsa/driver/Config.in \
	package/alsa/Config.in \
	package/fusionsound/Config.in \
	package/libvorbis/Config.in \
	package/mpg123/Config.in \
	package/madplay/Config.in \
	package/libsndfile/Config.in \
	package/libmad/Config.in \
	package/libid3tag/Config.in \
	package/asterisk/Config.in \
	package/xfsprogs/Config.in \
	package/wipe/Config.in \
	package/usbutils/Config.in \
	package/usbmount/Config.in \
	package/udev/Config.in \
	package/smartmontools/Config.in \
	package/sfdisk/Config.in \
	package/setserial/Config.in \
	package/raidtools/Config.in \
	package/pcmcia/Config.in \
	package/pciutils/Config.in \
	package/mtd/Config.in \
	package/mkdosfs/Config.in \
	package/memtester/Config.in \
	package/mdadm/Config.in \
	package/lvm2/Config.in \
	package/libusb/Config.in \
	package/libraw1394/Config.in \
	package/iostat/Config.in \
	package/hwdata/Config.in \
	package/hotplug/Config.in \
	package/hdparm/Config.in \
	package/hal/Config.in \
	package/e2fsprogs/Config.in \
	package/dmraid/Config.in \
	package/dm/Config.in \
	package/dbus-glib/Config.in \
	package/dbus/Config.in \
	package/acpid/Config.in \
	package/wireless-tools/Config.in \
	package/wget/Config.in \
	package/vtun/Config.in \
	package/udhcp/Config.in \
	package/ttcp/Config.in \
	package/tn5250/Config.in \
	package/thttpd/Config.in \
	package/tftpd/Config.in \
	package/tcpdump/Config.in \
	package/stunnel/Config.in \
	package/socat/Config.in \
	package/samba/Config.in \
	package/rsync/Config.in \
	package/proftpd/Config.in \
	package/pppd/Config.in \
	package/portmap/Config.in \
	package/openswan/Config.in \
	package/openvpn/Config.in \
	package/openssl/Config.in \
	package/openssh/Config.in \
	package/openntpd/Config.in \
	package/ntp/Config.in \
	package/nfs-utils/Config.in \
	package/netsnmp/Config.in \
	package/netplug/Config.in \
	package/netkittelnet/Config.in \
	package/netkitbase/Config.in \
	package/netcat/Config.in \
	package/ncftp/Config.in \
	package/nbd/Config.in \
	package/mrouted/Config.in \
	package/lrzsz/Config.in \
	package/links/Config.in \
	package/lighttpd/Config.in \
	package/libpcap/Config.in \
	package/libcgicc/Config.in \
	package/libcgi/Config.in \
	package/l2tp/Config.in \
	package/iptables/Config.in \
	package/ipsec-tools/Config.in \
	package/iproute2/Config.in \
	package/iperf/Config.in \
	package/irda-utils/Config.in \
	package/hostap/Config.in \
	package/haserl/Config.in \
	package/ethtool/Config.in \
	package/dropbear/Config.in \
	package/dnsmasq/Config.in \
	package/dhcp/Config.in \
	package/curl/Config.in \
	package/bridge/Config.in \
	package/bind/Config.in \
	package/boa/Config.in \
	package/avahi/Config.in \
	package/argus/Config.in \
	package/kaffe/Config.in \
	package/rs232_proxy/Config.in \
	package/which/Config.in \
	package/util-linux/Config.in \
	package/uemacs/Config.in \
	package/tinylogin/Config.in \
	package/sysvinit/Config.in \
	package/sysklogd/Config.in \
	package/sudo/Config.in \
	package/strace/Config.in \
	package/sqlite/Config.in \
	package/psmisc/Config.in \
	package/procps/Config.in \
	package/portage/Config.in \
	package/nano/Config.in \
	package/modutils/Config.in \
	package/module-init-tools/Config.in \
	package/microcom/Config.in \
	package/ltt/Config.in \
	package/ltrace/Config.in \
	package/ltp-testsuite/Config.in \
	package/lsof/Config.in \
	package/lockfile-progs/Config.in \
	package/libsysfs/Config.in \
	package/liblockfile/Config.in \
	package/libfloat/Config.in \
	package/libevent/Config.in \
	package/libelf/Config.in \
	package/less/Config.in \
	package/kexec/Config.in \
	package/file/Config.in \
	package/dash/Config.in \
	package/customize/Config.in \
	package/bsdiff/Config.in \
	package/berkeleydb/Config.in \
	package/at/Config.in \
	package/xerces/Config.in \
	package/valgrind/Config.in \
	package/readline/Config.in \
	package/pkgconfig/Config.in \
	package/mpatrol/Config.in \
	package/m4/Config.in \
	package/libtool/Config.in \
	package/mpfr/Config.in \
	package/gmp/Config.in \
	package/gettext/Config.in \
	package/fakeroot/Config.in \
	package/expat/Config.in \
	package/dmalloc/Config.in \
	package/distcc/Config.in \
	package/cvs/Config.in \
	toolchain/ccache/Config.in.2 \
	package/bison/Config.in \
	package/automake/Config.in \
	package/autoconf/Config.in \
	package/tar/Config.in \
	package/sed/Config.in \
	package/patch/Config.in \
	package/make/Config.in \
	package/grep/Config.in \
	toolchain/gcc/Config.in.2 \
	package/gawk/Config.in \
	package/flex/Config.in \
	package/findutils/Config.in \
	package/ed/Config.in \
	package/diffutils/Config.in \
	package/coreutils/Config.in \
	package/bzip2/Config.in \
	package/bash/Config.in \
	package/busybox/Config.in \
	package/Config.in \
	toolchain/gdb/Config.in.2 \
	toolchain/external-toolchain/Config.in \
	toolchain/sstrip/Config.in \
	toolchain/mklibs/Config.in \
	toolchain/elf2flt/Config.in \
	toolchain/gdb/Config.in \
	toolchain/ccache/Config.in \
	toolchain/gcc/Config.in \
	toolchain/binutils/Config.in \
	toolchain/uClibc/Config.in \
	toolchain/kernel-headers/Config.in \
	toolchain/Config.in.2 \
	toolchain/Config.in \
	package/gnuconfig/Config.in \
	Config.in

.config include/config.h: $(deps_config)

$(deps_config):
