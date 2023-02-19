FROM rockylinux:9.1.20221221

# Update rocky linux with latest changes
RUN yum -y update && yum clean all

# Rocky Linux already adds /usr/local/bin in the PATH
# ENV PATH /usr/local/bin:$PATH

ENV LANG C.UTF-8

ENV GPG_KEY E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION 3.9.16

RUN set -eux; \
    \
    dnf -y install 'dnf-command(config-manager)' ; \
    dnf config-manager --set-enabled crb ; \
    yum groupinstall -y "Development Tools"; \
    yum -y install \
		libffi-devel \
		expat-devel \
		openssl-devel \
		readline-devel \
		bzip2-devel \
		gdbm-devel \
		sqlite-devel \
		libuuid-devel \
		; \
    yum -y clean all; \
    rm -rf /var/cache

RUN set -eux; \
    \
	curl -s -o python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
	curl -s -o python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc"; \
	\
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$GPG_KEY"; \
	gpg --batch --verify python.tar.xz.asc python.tar.xz; \
	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" python.tar.xz.asc; \
	\
	mkdir -p /usr/src/python; \
	tar -xJf python.tar.xz --strip-components=1 -C /usr/src/python; \
	rm python.tar.xz; \
	\
    cd /usr/src/python; \
    ./configure \
		--build=$(uname -m)-linux-gnu \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
    ; \
    make -j $(nproc) LDFLAGS="-Wl,--strip-all"; \
    make install; \
	\
    cd /; \
    rm -rf /usr/src/python; \
    find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
		\) -exec rm -rf '{}' + \
	; \
	echo "/usr/local/lib" >/etc/ld.so.conf.d/python3.conf; \
	ldconfig; \
	\
	python3 --version

# make some useful symlinks that are expected to exist ("/usr/local/bin/python" and friends)
RUN set -eux; \
	for src in idle3 pydoc3 python3 python3-config; do \
		dst="$(echo "$src" | tr -d 3)"; \
		[ -s "/usr/local/bin/$src" ]; \
		[ ! -e "/usr/local/bin/$dst" ]; \
		ln -svT "/usr/local/bin/$src" "/usr/local/bin/$dst"; \
	done

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 22.0.4
# https://github.com/docker-library/python/issues/365
ENV PYTHON_SETUPTOOLS_VERSION 58.1.0

# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/d5cb0afaf23b8520f1bbcfed521017b4a95f5c01/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 394be00f13fa1b9aaa47e911bdb59a09c3b2986472130f30aa0bfaf7f3980637

RUN set -eux; \
	\
	curl -L -o get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
		"setuptools==$PYTHON_SETUPTOOLS_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' + \
	; \
	rm -f get-pip.py

CMD ["python3"]
