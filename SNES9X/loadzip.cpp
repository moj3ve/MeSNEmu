#ifdef UNZIP_SUPPORT

#include <assert.h>
#include <ctype.h>
#include "unzip/unzip.h"
#include "snes9x.h"
#include "memmap.h"


bool8 LoadZip (const char *zipname, int32 *TotalFileSize, int32 *headers, uint8 *buffer)
{
	*TotalFileSize = 0;
	*headers = 0;

	unzFile	file = unzOpen(zipname);
	if (file == NULL)
		return (FALSE);

	// find largest file in zip file (under MAX_ROM_SIZE) or a file with extension .1
	char	filename[132];
	int		filesize = 0;
	int		port = unzGoToFirstFile(file);

	unz_file_info	info;

	while (port == UNZ_OK)
	{
		char	name[132];
		unzGetCurrentFileInfo(file, &info, name, 128, NULL, 0, NULL, 0);

		if (info.uncompressed_size > CMemory::MAX_ROM_SIZE + 512)
		{
			port = unzGoToNextFile(file);
			continue;
		}

		if ((int) info.uncompressed_size > filesize)
		{
			strcpy(filename, name);
			filesize = info.uncompressed_size;
		}

		int	len = strlen(name);
		if (len > 2 && name[len - 2] == '.' && name[len - 1] == '1')
		{
			strcpy(filename, name);
			filesize = info.uncompressed_size;
			break;
		}

		port = unzGoToNextFile(file);
	}

	if (!(port == UNZ_END_OF_LIST_OF_FILE || port == UNZ_OK) || filesize == 0)
	{
		assert(unzClose(file) == UNZ_OK);
		return (FALSE);
	}

	// find extension
	char	tmp[2] = { 0, 0 };
	char	*ext = strrchr(filename, '.');
	if (ext)
		ext++;
	else
		ext = tmp;

	uint8	*ptr = buffer;
	bool8	more = FALSE;

	unzLocateFile(file, filename, 1);
	unzGetCurrentFileInfo(file, &info, filename, 128, NULL, 0, NULL, 0);

	if (unzOpenCurrentFile(file) != UNZ_OK)
	{
		unzClose(file);
		return (FALSE);
	}

	do
	{
		assert(info.uncompressed_size <= CMemory::MAX_ROM_SIZE + 512);

		int	FileSize = info.uncompressed_size;
		int	l = unzReadCurrentFile(file, ptr, FileSize);

		if (unzCloseCurrentFile(file) == UNZ_CRCERROR)
		{
			unzClose(file);
			return (FALSE);
		}

		if (l <= 0 || l != FileSize)
		{
			unzClose(file);
			return (FALSE);
		}

		FileSize = (int) Memory.HeaderRemove((uint32) FileSize, *headers, ptr);
		ptr += FileSize;
		*TotalFileSize += FileSize;

		int	len;

		if (ptr - Memory.ROM < CMemory::MAX_ROM_SIZE + 512 && (isdigit(ext[0]) && ext[1] == 0 && ext[0] < '9'))
		{
			more = TRUE;
			ext[0]++;
		}
		else
		if (ptr - Memory.ROM < CMemory::MAX_ROM_SIZE + 512)
		{
			if (ext == tmp)
				len = strlen(filename);
			else
				len = ext - filename - 1;

			if ((len == 7 || len == 8) && strncasecmp(filename, "sf", 2) == 0 &&
				isdigit(filename[2]) && isdigit(filename[3]) && isdigit(filename[4]) &&
				isdigit(filename[5]) && isalpha(filename[len - 1]))
			{
				more = TRUE;
				filename[len - 1]++;
			}
		}
		else
			more = FALSE;

		if (more)
		{
			if (unzLocateFile(file, filename, 1) != UNZ_OK ||
				unzGetCurrentFileInfo(file, &info, filename, 128, NULL, 0, NULL, 0) != UNZ_OK ||
				unzOpenCurrentFile(file) != UNZ_OK)
				break;
		}
	} while (more);

	unzClose(file);

	return (TRUE);
}

#endif
