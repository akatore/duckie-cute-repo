CC     = gcc
CFLAGS = -std=c11 -Wall -Wextra -Werror -g
LDLIBS = -lm

all: wavinfo

wavinfo: main.o wav.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

test_wav: test_wav.o wav.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

%.o: %.c wav.h
	$(CC) $(CFLAGS) -c -o $@ $<

test: test_wav
	./test_wav

clean:
	rm -f *.o wavinfo test_wav

.PHONY: all test clean
