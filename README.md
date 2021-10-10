# Shi Kong Xing Shou MSU-1

## Patch

The patch sources are located in patches/. Requires RGBDS. Asar is required to compile patches/msu1/.

## Music

The music project files are located in bgm/ and can be compiled as well. You may [download](https://drive.google.com/drive/folders/1o_kU5zsulEEl-SHqNjIcfzZyM0v33l6L?usp=sharing) them or [listen to them on YouTube](https://www.youtube.com/watch?v=1qBSv4IAjbE&list=PLM18Dljg9YX7hMjbeyENYP9bWk5zDF66R&index=1).

**Dependencies**:
* FL Studio 12.5 or higher
* Python 3
* Wine (if on unix-likes)
* [SGM v2.01.sf2](https://archive.org/details/SGM-V2.01)
* Edirol Orchestral VST

## Linux

The `WINEPREFIX` and `WINEDRIVELETTER` variables in the Makefile should be changed.

`WINEDRIVELETTER` is the Wine mount point for /.

`FLSTUDIO` should point to the Windows location for the 32-bit FL Studio binary.

The Makefile cannot be run concurrently.

**Please ensure that before doing a make that NO FL STUDIO WINDOWS ARE OPEN!**

## Windows

The `WINE` variable should be emptied.

(NOT TESTED YET)
