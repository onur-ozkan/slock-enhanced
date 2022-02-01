# slock - simple screen locker
# See LICENSE file for copyright and license details.
.SILENT:

include config.mk

SRC = slock.c ${COMPATSRC}
OBJ = ${SRC:.c=.o}

all: options slock

options:
	@echo slock build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	@echo CC $<
	@${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk arg.h util.h

config.h:
	@echo creating $@ from config.h
	@cp config.h $@

slock: ${OBJ}
	@echo CC -o $@
	@${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	@echo cleaning
	@rm -f slock ${OBJ} slock-${VERSION}.tar.gz

dist: clean
	@echo creating dist tarball
	@mkdir -p slock-${VERSION}
	@cp -R LICENSE Makefile README slock.1 config.mk \
		${SRC} explicit_bzero.c config.h arg.h util.h slock-${VERSION}
	@tar -cf slock-${VERSION}.tar slock-${VERSION}
	@gzip slock-${VERSION}.tar
	@rm -rf slock-${VERSION}

install: all
	@echo installing executable file to ${DESTDIR}${PREFIX}/bin
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f slock ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/slock
	@chmod u+s ${DESTDIR}${PREFIX}/bin/slock
	@echo installing manual page to ${DESTDIR}${MANPREFIX}/man1
	@mkdir -p ${DESTDIR}${MANPREFIX}/man1
	@sed "s/VERSION/${VERSION}/g" <slock.1 >${DESTDIR}${MANPREFIX}/man1/slock.1
	@chmod 644 ${DESTDIR}${MANPREFIX}/man1/slock.1

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	@rm -f ${DESTDIR}${PREFIX}/bin/slock
	@echo removing manual page from ${DESTDIR}${MANPREFIX}/man1
	@rm -f ${DESTDIR}${MANPREFIX}/man1/slock.1

indent:
	indent --blank-lines-after-procedures --brace-indent0 --indent-level4 \
		--no-space-after-casts --no-space-after-function-call-names \
		--dont-break-procedure-type --format-all-comments \
		--line-length100 --comment-line-length100 --tab-size4 *.{c,h}

check-indentation:
	$(eval SOURCES := $(shell ls *.{c,h}))
	for i in $(SOURCES); do \
		export DIFFS=$$(diff $$i <(indent -st -bap -bli0 -i4 -ncs -npcs -npsl -fca -l100 -lc100 -ts4 $$i)); \
		if [ -z "$$DIFFS" ]; then echo -e "\033[0;32mValid indentation format -> $$i\033[0m"; else echo -e "\033[0;31mInvalid indentation format -> $$i\033[0m"; fi \
	done

check:
	@echo Checking indentation standards
	$(MAKE) check-indentation

.PHONY: all options clean dist install uninstall indent check-indentation check
