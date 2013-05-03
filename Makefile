CC          = gcc
CCLD_SHARED = gcc -shared
CFLAGS      = -O2 -fPIC
LDFLAGS     =

ROOT        = /
PKGVER      = 0.1
PKGNAME     = gtk3-thickice-$(PKGVER)

GTKPREFIX   = `pkg-config --variable=prefix gtk+-3.0`
GTKLIB      = `pkg-config --variable=libdir gtk+-3.0`

TAR         = tar
TARXFORM    = --xform 's!^!$(PKGNAME)/!'
# for BSD tar:
#TARXFORM    = -s '!^!$(PKGNAME)/!'
# for a tarbomb:
#TARXFORM    =

.PHONY: all clean clean-all install uninstall tarball

.SECONDARY:

all: libthickice.so

clean:
	rm -f libthickice.so thickice.o

clean-all: clean
	rm -f thickice.c

tarball: $(PKGNAME).tar.bz2

install: libthickice.so gtk.css
	install -Dm0644 libthickice.so $(ROOT)$(GTKLIB)/gtk-3.0/theming-engines/libthickice.so
	install -Dm0644 gtk.css        $(ROOT)$(GTKPREFIX)/share/themes/ThinIce/gtk-3.0/gtk.css

uninstall:
	rm -f $(ROOT)$(GTKPREFIX)/share/themes/ThinIce/gtk-3.0/gtk.css
	rm -f $(ROOT)$(GTKLIB)/gtk-3.0/theming-engines/libthickice.so
#	rm -rf /usr

TARFILES = thickice.vala thickice.c Makefile README gtk.css

libthickice.so: thickice.o
	$(CCLD_SHARED) $^ -o $@ $(LDFLAGS)

%.tar.gz: $(TARFILES)
	$(TAR) zcf '$@' $(TARXFORM) -- $^

%.tar.bz2: $(TARFILES)
	$(TAR) jcf '$@' $(TARXFORM) -- $^

%.tar.xz: $(TARFILES)
	$(TAR) Jcf '$@' $(TARXFORM) -- $^

%.c: %.vala
	valac -C $< -o $@ --pkg=gtk+-3.0 $(VALAFLAGS)

%.o: %.c
	$(CC) -c $< -o $@ `pkg-config --cflags gtk+-3.0` $(CFLAGS)
