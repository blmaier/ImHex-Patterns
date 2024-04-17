#include <std/string.pat>
#include <std/mem.pat>
#include <std/io.pat>


};

//struct cpio_archive {
//	while (1) {
//		cpio_header cpio;
//		if (cpio.filename == "TRAILER!!!") {
//			break;
//		}
//	};
//	//cpio_header cpio1;
//	//cpio_header cpio2;
//	//cpio_header cpio3;
//	//cpio_header cpio4;
//};
//
//cpio_archive cpio @ 0x00;

//while (1) {
for (u8 i = 0, i < 10, i = i + 1) {
	cpio_header cpio;
	if (cpio.filename == "TRAILER!!!") {
		break;
	}
};
