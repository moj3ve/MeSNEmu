/*****************************************************************************\
     Snes9x - Portable Super Nintendo Entertainment System (TM) emulator.
                This file is licensed under the Snes9x License.
   For further information, consult the LICENSE file in the root directory.
\*****************************************************************************/

// Abstract the details of reading from zip files versus FILE *'s.

#include <string>
#ifdef UNZIP_SUPPORT
#  ifdef SYSTEM_ZIP
#    include <minizip/unzip.h>
#  else
#    include "unzip.h"
#  endif
#endif
#include "snes9x.h"
#include "reader.h"


// Generic constructor/destructor

Reader::Reader (void)
{
	return;
}

Reader::~Reader (void)
{
	return;
}

// Generic getline function, based on gets. Reimlpement if you can do better.

char * Reader::getline (void)
{
	bool		eof;
	std::string	ret;

	ret = getline(eof);
	if (ret.size() == 0 && eof)
		return (NULL);

	return (strdup(ret.c_str()));
}

std::string Reader::getline (bool &eof)
{
	char		buf[1024];
	std::string	ret;

	eof = false;
	ret.clear();

	do
	{
		if (gets(buf, sizeof(buf)) == NULL)
		{
			eof = true;
			break;
		}

		ret.append(buf);
	}
	while (*ret.rbegin() != '\n');

	return (ret);
}

size_t Reader::pos_from_origin_offset(uint8 origin, int32 offset)
{
    size_t position = 0;
    switch (origin)
    {
        case SEEK_SET:
            position = offset;
            break;
        case SEEK_END:
            position = size() + offset;
            break;
        case SEEK_CUR:
            position = pos() + offset;
            break;
    }
    return position;
}

// snes9x.h STREAM Reader

fReader::fReader (STREAM f)
{
	fp = f;
}

fReader::~fReader (void)
{
	return;
}

int fReader::get_char (void)
{
	return (GETC_STREAM(fp));
}

char * fReader::gets (char *buf, size_t len)
{
	return (GETS_STREAM(buf, len, fp));
}

size_t fReader::read (void *buf, size_t len)
{
	return (READ_STREAM(buf, len, fp));
}

size_t fReader::write (void *buf, size_t len)
{
    return (WRITE_STREAM(buf, len, fp));
}

size_t fReader::pos (void)
{
    return (FIND_STREAM(fp));
}

size_t fReader::size (void)
{
    size_t sz;
    REVERT_STREAM(fp,0L,SEEK_END);
    sz = FIND_STREAM(fp);
    REVERT_STREAM(fp,0L,SEEK_SET);
    return sz;
}

int fReader::revert (uint8 origin, int32 offset)
{
    return (REVERT_STREAM(fp, offset, origin));
}

void fReader::closeStream()
{
    CLOSE_STREAM(fp);
    delete this;
}

// unzip Reader

#ifdef UNZIP_SUPPORT

unzReader::unzReader(unzFile &v)
{
	file = v;
    pos_in_buf = 0;
    buf_pos_in_unzipped = unztell(file);
    bytes_in_buf = 0;

    // remember start pos for seeks
    unzGetFilePos(file, &unz_file_start_pos);
}

unzReader::~unzReader (void)
{
	return;
}

size_t unzReader::buffer_remaining()
{
    return bytes_in_buf - pos_in_buf;
}

void unzReader::fill_buffer()
{
    buf_pos_in_unzipped = unztell(file);
    bytes_in_buf = unzReadCurrentFile(file, buffer, unz_BUFFSIZ);
    pos_in_buf = 0;
}

int unzReader::get_char (void)
{
	unsigned char	c;

	if (buffer_remaining() <= 0)
	{
        fill_buffer();
		if (bytes_in_buf <= 0)
			return (EOF);
	}

	c = *(buffer + pos_in_buf);
    pos_in_buf++;

	return ((int) c);
}

char * unzReader::gets (char *buf, size_t len)
{
	size_t	i;
	int		c;

	for (i = 0; i < len - 1; i++)
	{
		c = get_char();
		if (c == EOF)
		{
			if (i == 0)
				return (NULL);
			break;
		}

		buf[i] = (char) c;
		if (buf[i] == '\n')
			break;
	}

	buf[i] = '\0';

	return (buf);
}

size_t unzReader::read (void *buf, size_t len)
{
	if (len == 0)
		return (len);

	size_t	to_read = len;
    uint8 *read_to = (uint8 * )buf;
    do
    {
        size_t in_buffer = buffer_remaining();
        if (to_read <= in_buffer)
        {
            memcpy(read_to, buffer + pos_in_buf, to_read);
            pos_in_buf += to_read;
            to_read = 0;
            break;
        }

        memcpy(read_to, buffer + pos_in_buf, in_buffer);
        to_read -= in_buffer;
        fill_buffer();
    } while (bytes_in_buf);

	return (len - to_read);
}

// not supported
size_t unzReader::write (void *buf, size_t len)
{
    return (0);
}

size_t unzReader::pos (void)
{
    return buf_pos_in_unzipped + pos_in_buf;
}

size_t unzReader::size (void)
{
    unz_file_info	info;
    unzGetCurrentFileInfo(file,&info,NULL,0,NULL,0,NULL,0);
    return info.uncompressed_size;
}

int unzReader::revert (uint8 origin, int32 offset)
{
    size_t target_pos = pos_from_origin_offset(origin, offset);

    // new pos inside buffered data
    if (target_pos >= buf_pos_in_unzipped && target_pos < buf_pos_in_unzipped + bytes_in_buf)
    {
        pos_in_buf = target_pos - buf_pos_in_unzipped;
    }
    else // outside of buffer, reset file and read until pos
    {
        unzGoToFilePos(file, &unz_file_start_pos);
        unzOpenCurrentFile(file); // necessary to reopen after seek
        int times_to_read = target_pos / unz_BUFFSIZ + 1;
        for( int i = 0; i < times_to_read; i++)
        {
            fill_buffer();
        }
        pos_in_buf = target_pos % unz_BUFFSIZ;
    }
    return 0;
}

void unzReader::closeStream()
{
    unzClose(file);
    delete this;
}

#endif

// memory Stream

memStream::memStream (uint8 *source, size_t sourceSize)
{
	mem = head = source;
    msize = remaining = sourceSize;
    readonly = false;
}

memStream::memStream (const uint8 *source, size_t sourceSize)
{
	mem = head = const_cast<uint8 *>(source);
    msize = remaining = sourceSize;
    readonly = true;
}

memStream::~memStream (void)
{
	return;
}

int memStream::get_char (void)
{
    if(!remaining)
        return EOF;

    remaining--;
	return *head++;
}

char * memStream::gets (char *buf, size_t len)
{
    size_t	i;
	int		c;

	for (i = 0; i < len - 1; i++)
	{
		c = get_char();
		if (c == EOF)
		{
			if (i == 0)
				return (NULL);
			break;
		}

		buf[i] = (char) c;
		if (buf[i] == '\n')
			break;
	}

	buf[i] = '\0';

	return (buf);
}

size_t memStream::read (void *buf, size_t len)
{
    size_t bytes = len < remaining ? len : remaining;
    memcpy(buf,head,bytes);
    head += bytes;
    remaining -= bytes;

	return bytes;
}

size_t memStream::write (void *buf, size_t len)
{
    if(readonly)
        return 0;

    size_t bytes = len < remaining ? len : remaining;
    memcpy(head,buf,bytes);
    head += bytes;
    remaining -= bytes;

	return bytes;
}

size_t memStream::pos (void)
{
    return msize - remaining;
}

size_t memStream::size (void)
{
    return msize;
}

int memStream::revert (uint8 origin, int32 offset)
{
    size_t pos = pos_from_origin_offset(origin, offset);

    if(pos > msize)
        return -1;

    head = mem + pos;
    remaining = msize - pos;

    return 0;
}

void memStream::closeStream()
{
    delete [] mem;
    delete this;
}

// dummy Stream

nulStream::nulStream (void)
{
	bytes_written = 0;
}

nulStream::~nulStream (void)
{
	return;
}

int nulStream::get_char (void)
{
    return 0;
}

char * nulStream::gets (char *buf, size_t len)
{
	*buf = '\0';
	return NULL;
}

size_t nulStream::read (void *buf, size_t len)
{
	return 0;
}

size_t nulStream::write (void *buf, size_t len)
{
    bytes_written += len;
	return len;
}

size_t nulStream::pos (void)
{
    return 0;
}

size_t nulStream::size (void)
{
    return bytes_written;
}

int nulStream::revert (uint8 origin, int32 offset)
{
    size_t target_pos = pos_from_origin_offset(origin, offset);
    bytes_written = target_pos;
    return 0;
}

void nulStream::closeStream()
{
    delete this;
}

Reader *openStreamFromSTREAM(const char* filename, const char* mode)
{
    STREAM f = OPEN_STREAM(filename,mode);
    if(!f)
        return NULL;
    return new fReader(f);
}

Reader *reopenStreamFromFd(int fd, const char* mode)
{
    STREAM f = REOPEN_STREAM(fd,mode);
    if(!f)
        return NULL;
    return new fReader(f);
}
