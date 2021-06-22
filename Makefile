.PHONY: all clean

TOP=$(PWD)
SRC=$(TOP)/src
INCLUDE_DIR=/usr/local/openresty/luajit/include/luajit-2.1/

CFLAGS = -g3 -O2 -Wall -I$(INCLUDE_DIR) 
SHARED = -fPIC --shared

all: ikcp.so

ikcp.so: $(SRC)/c/ikcp.h  $(SRC)/c/ikcp.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@  

all:
	-rm -rf $(TOP)/*.a $(TOP)/*.o

clean:
	-rm -rf *.o *.a *.so
