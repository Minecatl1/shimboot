. ./common.sh
. ./image_utils.sh
. ./shim_utils.sh
assert_root
assert_deps "cpio binwalk pcregrep realpath cgpt mkfs.ext4 mkfs.ext2 fdisk lz4"
assert_args "$3"
parse_args "$@"
export data_dir="$HOME/workspaces/shimboot/data"
export board="cyan"
export shim_bin="$data_dir/shim_$board.bin"
export reco_bin="$data_dir/reco_$board.bin"
export rootfs_dir="$data_dir/rootfs_$board"
export arch="amd64"
export distro="debian"
export release="trixie"
export quiet="0"
export luks="0"
export final_image="$data_dir/shimboot_$board.bin"
tools="cpio binwalk pcregrep cgpt e2fsprogs fdisk lz4 cryptsetup"
sudo apt-get update
sudo apt-get install $tools -y
print_info "reading the shim image"
initramfs_dir=/tmp/shim_initramfs
kernel_img=/tmp/kernel.img
rm -rf "$initramfs_dir" "$kernel_img"
extract_initramfs_full "$shim_path" "$initramfs_dir" "$kernel_img" "$arch"

print_info "patching initramfs"
patch_initramfs "$initramfs_dir"

print_info "creating disk image"
rootfs_size="$(du -sm $rootfs_dir | cut -f 1)"
rootfs_part_size="$(($rootfs_size * 12 / 10 + 5))"
#create a 20mb bootloader partition
#rootfs partition is 20% larger than its contents
create_image "$output_path" 20 "$rootfs_part_size" "$bootloader_part_name"

print_info "creating loop device for the image"
image_loop="$(create_loop ${output_path})"

print_info "creating partitions on the disk image"
create_partitions "$image_loop" "$kernel_img" "$luks_enabled" "$crypt_password"

print_info "copying data into the image"
populate_partitions "$image_loop" "$initramfs_dir" "$rootfs_dir" "$quiet" "$luks_enabled"
rm -rf "$initramfs_dir" "$kernel_img"
