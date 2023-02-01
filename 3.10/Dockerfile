FROM rockylinux:9.1.20221221

# Update rocky linux with latest changes
RUN yum -y update && yum clean all

# Rocky Linux already adds /usr/local/bin in the PATH
# ENV PATH /usr/local/bin:$PATH

ENV LANG C.UTF-8

ENV GPG_KEY A035C8C19219BA821ECEA86B64E628F8D684696D
ENV PYTHON_VERSION 3.10.9

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
		--with-lto \
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
ENV PYTHON_PIP_VERSION 22.3.1
# https://github.com/docker-library/python/issues/365
ENV PYTHON_SETUPTOOLS_VERSION 65.5.1

# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/1a96dc5acd0303c4700e02655aefd3bc68c78958/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 d1d09b0f9e745610657a528689ba3ea44a73bd19c60f4c954271b790c71c2653

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
