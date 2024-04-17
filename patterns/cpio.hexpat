#pragma author WerWolv
#pragma description Old Binary CPIO Format

// spec: https://man.freebsd.org/cgi/man.cgi?query=cpio&sektion=5

import type.base;
import type.magic;

import std.time;
import std.core;
import std.sys;
import std.mem;

#pragma MIME application/x-cpio

fn next_archive() {
    while (!std::mem::eof() && $[$] == 0x0)
        $ += 1;
    std::print("Ptr: {:x}\n", $);
    return !std::mem::eof();
};

namespace old_binary {

    using Time = u32 [[format("old_binary::format_time")]];

    fn swap_32bit(u32 value) {
        return ((value >> 16) & 0xFFFF) | ((value & 0xFFFF) << 16);
    };

    fn format_time(u32 value) {
        return std::time::format(std::time::to_utc(swap_32bit(value)));
    };

    using SwappedU32 = u32 [[transform("old_binary::swap_32bit"), format("old_binary::swap_32bit")]];

    bitfield Mode {
        x           : 3;
        w           : 3;
        r           : 3;
        sticky      : 1;
        sgid        : 1;
        suid        : 1;
        file_type   : 4;
    };

    struct CpioHeader {
        type::Oct<u16> magic;
        if (magic == be u16(0o070707))
            std::core::set_endian(std::mem::Endian::Big);
        else if (magic == le u16(0o070707))
            std::core::set_endian(std::mem::Endian::Little);
        else
            std::error("Invalid CPIO Magic!");

        u16 dev;
        u16 ino;
        Mode mode;
        u16 uid;
        u16 gid;
        u16 nlink;
        u16 rdev;
        Time mtime;
        u16 namesize;
        SwappedU32 filesize;
    };

    struct Cpio {
        CpioHeader header;
        char pathname[header.namesize % 2 == 0 ? header.namesize : header.namesize + 1];
        u8 data[header.filesize % 2 == 0 ? header.filesize : header.filesize + 1];

        if (pathname == "TRAILER!!!\x00\x00")
            break;
    };

}

namespace new_ascii {
    struct CpioHeader {
            type::Magic<"070701"> c_magic;
            char c_ino[8];
            char c_mode[8];
            char c_uid[8];
            char c_gid[8];
            char c_nlink[8];
            char c_mtime[8]; //TODO format
            char c_filesize[8];
            char c_devmajor[8];
            char c_devminor[8];
            char c_rdevmajor[8];
            char c_rdevminor[8];
            char c_namesize[8];
            char c_check[8];
    };

    struct Cpio {
        std::mem::AlignTo<4>;

        CpioHeader header;
        char filename[std::math::max(std::string::parse_int(header.c_namesize, 16) - 1, 0)];
        // filename NULL-terminator
        if (std::string::length(filename))
            $ += 1;

        std::mem::AlignTo<4>;

        if (filename == "TRAILER!!!")
            break;

        u8 data[std::string::parse_int(header.c_filesize, 16)];
    };

    struct CpioArchive {
        std::print("Scanning at {:x}", $);
        Cpio archive[while(true)];
        std::print("Scanned");
    };

    struct InitramfsEntry {
        CpioArchive cpio;
    };

    // https://www.kernel.org/doc/html/latest/driver-api/early-userspace/buffer-format.html
    struct Initramfs {
        CpioArchive archive[while(next_archive())];
        //CpioArchive archive;
        //while (true) {
        //    u8 padding[while(!$[0])];
        //    CpioArchive cpio;
        //}
        //std::mem::MagicSearch<"070701", CpioArchive> cpio [[inline]];
    };
}

new_ascii::Initramfs cpio @ 0x00;
//old_binary::Cpio cpio[while(true)] @ 0x00;
//std::mem::MagicSearch<"070701", CpioFile> cpio @ 0x00
//new_ascii::Cpio cpio[7] @ 0x00;
