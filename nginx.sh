#Change working directory to home directory
cd

#Update system
apt update && apt full-upgrade -y

#Install build dependencies
apt install -y \
  ca-certificates \
  wget \
  curl \
  git \
  bzip2 \
  xz-utils \
  build-essential \
  xsltproc \
  uuid-dev \
  zlib1g-dev \
  libxslt1-dev \
  libpcre3-dev \
  libgd-dev \
  libgeoip-dev \
  libperl-dev \
  | tee build-deps.txt

#Update CA Certificates
update-ca-certificates

#Backup Redis configuration files
if [ -f "/etc/redis/redis.conf" ];then
  mv -f /etc/redis/redis.conf /etc/redis/redis.conf_backup
fi

#Backup Nginx configuration files
if [ -f "/usr/share/nginx/html/index.html" ];then
  mv -f /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html_backup
fi
if [ -f "/usr/share/nginx/html/50x.html" ];then
  mv -f /usr/share/nginx/html/50x.html /usr/share/nginx/html/50x.html_backup
fi
if [ -d "/etc/nginx/html" ];then
  mv -f /etc/nginx/html /etc/nginx/html_backup
fi
if [ -f "/etc/nginx/nginx.conf" ];then
  mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf_backup
fi
if [ -d "/etc/nginx/conf.d/" ];then
  find /etc/nginx/conf.d -name "*.conf" | grep -q ".conf"
  if [ $? -eq 0 ];then
    cd /etc/nginx/conf.d
    rename -f "s/.conf/.conf_backup/" *.conf
    cd
  fi
fi

#Download and install UPX latest version
UPX_VERSION=$(curl -sS --fail https://github.com/upx/upx/releases | \
  grep -o '/upx-[a-zA-Z0-9.]*-amd64_linux[.]tar[.]xz' | \
  sed -e 's~^/upx-~~' -e 's~\-amd64_linux\.tar\.xz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz
xz -d upx-${UPX_VERSION}-amd64_linux.tar.xz
tar -xvf upx-${UPX_VERSION}-amd64_linux.tar
UPX_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*upx-${UPX_VERSION}-amd64_linux*")
cp -f $UPX_DIR/upx /bin

#Download Jemalloc latest version
JEMALLOC_VERSION=$(curl -sS --fail https://github.com/jemalloc/jemalloc/releases | \
  grep -o '/jemalloc-[a-zA-Z0-9.]*[.]tar[.]bz2' | \
  sed -e 's~^/jemalloc-~~' -e 's~\.tar\.bz2$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2
tar -xjvf jemalloc-${JEMALLOC_VERSION}.tar.bz2
JEMALLOC_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*jemalloc-${JEMALLOC_VERSION}*")

#Download Redis latest version
REDIS_VERSION=$(curl -sS --fail https://github.com/antirez/redis/releases | \
  grep -o '/antirez/redis/archive/[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/antirez/redis/archive/~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O redis-${REDIS_VERSION}.tar.gz https://github.com/antirez/redis/archive/${REDIS_VERSION}.tar.gz
tar -xvzf redis-${REDIS_VERSION}.tar.gz
REDIS_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*redis-${REDIS_VERSION}*")

#Download OpenSSL latest version
OPENSSL_VERSION=$(curl -sS --fail https://www.openssl.org/source/ | \
  grep -o 'openssl-[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^openssl-~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
tar -xvzf openssl-${OPENSSL_VERSION}.tar.gz
OPENSSL_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*openssl-${OPENSSL_VERSION}*")

#Download Nginx latest version
NGINX_VERSION=$(curl -sS --fail https://nginx.org/en/download.html | \
  grep -o '/download/nginx-[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/download/nginx-~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
NGINX_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*nginx-${NGINX_VERSION}*")

#Download Nginx Module:JavaScript latest version
NJS_VERSION=$(curl -sS --fail https://github.com/nginx/njs/releases | \
  grep -o '/nginx/njs/archive/[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/nginx/njs/archive/~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O njs-${NJS_VERSION}.tar.gz https://github.com/nginx/njs/archive/${NJS_VERSION}.tar.gz
tar -xvzf njs-${NJS_VERSION}.tar.gz
NJS_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*njs-${NJS_VERSION}*")

#Download Nginx Module:Cache-Purge latest version
NCP_VERSION=$(curl -sS --fail https://github.com/FRiCKLE/ngx_cache_purge/releases | \
  grep -o '/ngx_cache_purge/archive/[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/ngx_cache_purge/archive/~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O ncp-${NCP_VERSION}.tar.gz https://github.com/FRiCKLE/ngx_cache_purge/archive/${NCP_VERSION}.tar.gz
tar -xvzf ncp-${NCP_VERSION}.tar.gz
NCP_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*ngx_cache_purge-${NCP_VERSION}*")

#Download Nginx Module:Brotli latest version
git clone -j`nproc` https://github.com/google/ngx_brotli
NB_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*ngx_brotli*")
cd $NB_DIR
git submodule update --init
cd

#Download Nginx Module:PageSpeed latest version
NPS_VERSION=$(curl -sS --fail https://github.com/apache/incubator-pagespeed-ngx/releases | \
  grep -o '/incubator-pagespeed-ngx/archive/v[a-zA-Z0-9.]*-stable[.]tar[.]gz' | \
  sed -e 's~^/incubator-pagespeed-ngx/archive/v~~' -e 's~\-stable\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O nps-v${NPS_VERSION}-stable.tar.gz https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}-stable.tar.gz
tar -xvzf nps-v${NPS_VERSION}-stable.tar.gz
NPS_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*incubator-pagespeed-ngx-${NPS_VERSION}-stable*")
cd "$NPS_DIR"
[ -e scripts/format_binary_url.sh ] && PSOL_URL=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${PSOL_URL}
tar -xzvf $(basename ${PSOL_URL})
cd

#Download Nginx Module:Redis latest version
NHR_VERSION=$(curl -sS --fail https://www.nginx.com/resources/wiki/modules/redis/ | \
  grep -o '/ngx_http_redis-[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/ngx_http_redis-~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget https://people.freebsd.org/~osa/ngx_http_redis-${NHR_VERSION}.tar.gz
tar -xvzf ngx_http_redis-${NHR_VERSION}.tar.gz
NHR_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*ngx_http_redis-${NHR_VERSION}*")

#Download Nginx Module:Devel-Kit latest version
NDK_VERSION=$(curl -sS --fail https://github.com/simplresty/ngx_devel_kit/releases | \
  grep -o '/ngx_devel_kit/archive/v[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/ngx_devel_kit/archive/v~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O ndk-v${NDK_VERSION}.tar.gz https://github.com/simplresty/ngx_devel_kit/archive/v${NDK_VERSION}.tar.gz
tar -xvzf ndk-v${NDK_VERSION}.tar.gz
NDK_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*ngx_devel_kit-${NDK_VERSION}*")

#Download Nginx Module:Set-Misc latest version
SMNM_VERSION=$(curl -sS --fail https://github.com/openresty/set-misc-nginx-module/releases | \
  grep -o '/set-misc-nginx-module/archive/v[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/set-misc-nginx-module/archive/v~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O smnm-v${SMNM_VERSION}.tar.gz https://github.com/openresty/set-misc-nginx-module/archive/v${SMNM_VERSION}.tar.gz
tar -xvzf smnm-v${SMNM_VERSION}.tar.gz
SMNM_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*set-misc-nginx-module-${SMNM_VERSION}*")

#Download Nginx Module:Echo latest version
ENM_VERSION=$(curl -sS --fail https://github.com/openresty/echo-nginx-module/releases | \
  grep -o '/echo-nginx-module/archive/v[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/echo-nginx-module/archive/v~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O enm-v${ENM_VERSION}.tar.gz https://github.com/openresty/echo-nginx-module/archive/v${ENM_VERSION}.tar.gz
tar -xvzf enm-v${ENM_VERSION}.tar.gz
ENM_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*echo-nginx-module-${ENM_VERSION}*")

#Download Nginx Module:Redis2 latest version
R2NM_VERSION=$(curl -sS --fail https://github.com/openresty/redis2-nginx-module/releases | \
  grep -o '/redis2-nginx-module/archive/v[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/redis2-nginx-module/archive/v~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O r2nm-v${R2NM_VERSION}.tar.gz https://github.com/openresty/redis2-nginx-module/archive/v${R2NM_VERSION}.tar.gz
tar -xvzf r2nm-v${R2NM_VERSION}.tar.gz
R2NM_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*redis2-nginx-module-${R2NM_VERSION}*")

#Download Nginx Module:Srcache latest version
SNM_VERSION=$(curl -sS --fail https://github.com/openresty/srcache-nginx-module/releases | \
  grep -o '/srcache-nginx-module/archive/v[a-zA-Z0-9.]*[.]tar[.]gz' | \
  sed -e 's~^/srcache-nginx-module/archive/v~~' -e 's~\.tar\.gz$~~' | \
  sed '/alpha.*/Id' | \
  sed '/pre.*/Id' | \
  sed '/beta.*/Id' | \
  sed '/rc.*/Id' | \
  sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g | \
  tail -n 1)
wget -O snm-v${SNM_VERSION}.tar.gz https://github.com/openresty/srcache-nginx-module/archive/v${SNM_VERSION}.tar.gz
tar -xvzf snm-v${SNM_VERSION}.tar.gz
SNM_DIR=$(find $HOME -maxdepth 1 -mindepth 1 -type d -name "*srcache-nginx-module-${SNM_VERSION}*")

#Build and install Jemalloc
cd $JEMALLOC_DIR
./configure --prefix=/usr
make -j`nproc`
make install_lib_shared -j`nproc`
strip /usr/lib/libjemalloc*

#Build and install Redis
cd $REDIS_DIR
make -j`nproc`
make PREFIX=/usr install -j`nproc`
strip /usr/bin/redis*
find /usr/bin -name "redis*" -type f | \
  xargs upx 

#Build and install Nginx
cd $NGINX_DIR
./configure \
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --modules-path=/usr/lib/nginx/modules \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx/nginx.pid \
  --lock-path=/var/run/nginx/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_stub_status_module \
  --with-http_auth_request_module \
  --with-http_xslt_module=dynamic \
  --with-http_image_filter_module=dynamic \
  --with-http_geoip_module=dynamic \
  --with-http_perl_module=dynamic \
  --with-threads \
  --with-stream=dynamic \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-stream_realip_module \
  --with-stream_geoip_module=dynamic \
  --with-http_slice_module \
  --with-mail=dynamic \
  --with-mail_ssl_module \
  --with-compat \
  --with-file-aio \
  --with-http_v2_module \
  --add-dynamic-module=$NJS_DIR//nginx \
  --with-ld-opt='-ljemalloc' \
  --with-openssl=$OPENSSL_DIR \
  --add-module=$NCP_DIR \
  --add-dynamic-module=$NB_DIR \
  --add-dynamic-module=$NPS_DIR \
  --add-dynamic-module=$NHR_DIR \
  --add-dynamic-module=$NDK_DIR \
  --add-dynamic-module=$SMNM_DIR \
  --add-dynamic-module=$ENM_DIR \
  --add-dynamic-module=$R2NM_DIR \
  --add-dynamic-module=$SNM_DIR
make -j`nproc`
make install -j`nproc`
strip /usr/sbin/nginx*
strip /usr/lib/nginx/modules/*.so
find /usr/sbin -name "nginx*" -type f | \
  xargs upx
cd

#Config System
ulimit -n 65535
ulimit -u 65535
ulimit -s unlimited
sed -i '/soft nproc.*/d' /etc/security/limits.conf
sed -i '/hard nproc.*/d' /etc/security/limits.conf
sed -i '/soft nofile.*/d' /etc/security/limits.conf
sed -i '/hard nofile.*/d' /etc/security/limits.conf
sed -i '/soft stack.*/d' /etc/security/limits.conf
sed -i '/hard stack.*/d' /etc/security/limits.conf
cat >> /etc/security/limits.conf << \EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
* soft stack unlimited
* hard stack unlimited
root soft nproc 65535
root hard nproc 65535
root soft nofile 65535
root hard nofile 65535
root soft stack unlimited
root hard stack unlimited
EOF
grep -q 'pam_limits.so' /etc/pam.d/login
if [ $? -ne 0 ];then
  echo 'session    required   pam_limits.so' >> /etc/pam.d/login
fi
sed -i '/net.core.somaxconn.*/d' /etc/sysctl.conf
sed -i '/vm.overcommit_memory.*/d' /etc/sysctl.conf
cat >> /etc/sysctl.conf << \EOF
net.core.somaxconn = 1024
vm.overcommit_memory = 1
EOF
sysctl -p
echo never > /sys/kernel/mm/transparent_hugepage/enabled
sed -i '/\/sys\/kernel\/mm\/transparent\_hugepage\/enabled.*/d' /etc/rc.local >/dev/null 2>&1
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local

#Config Redis
adduser  \
  --system  \
  --home /var/lib/redis \
  --shell /bin/false \
  --group \
  --disabled-login \
  --quiet \
  redis
mkdir -p \
  /etc/redis \
  /var/log/redis \
  /var/run/redis
chown redis:adm /var/log/redis
chown redis:redis /var/run/redis
chmod 02750 /var/log/redis
chmod 750 /var/lib/redis
wget -O /lib/systemd/system/redis-server.service https://raw.githubusercontent.com/Xaster/nginx-debian/master/config/lib/systemd/system/redis-server.service
wget -O /etc/redis/redis.conf https://raw.githubusercontent.com/Xaster/nginx-debian/master/config/etc/redis/redis.conf
chown redis:redis /etc/redis/redis.conf
chmod 640 /etc/redis/redis.conf
cp -f /etc/redis/redis.conf /etc/redis/redis.conf.default
systemctl daemon-reload
systemctl enable redis-server

#Config Nginx
adduser \
  --system \
  --home /var/cache/nginx \
  --shell /bin/false \
  --group \
  --disabled-login \
  --quiet \
  nginx
mkdir -p \
  /var/log/nginx \
  /var/run/nginx \
  /etc/nginx/conf.d \
  /usr/share/nginx/html
touch /var/log/nginx/access.log
chmod 640 /var/log/nginx/access.log
chown nginx:adm /var/log/nginx/access.log
touch /var/log/nginx/error.log
chmod 640 /var/log/nginx/error.log
chown nginx:adm /var/log/nginx/error.log
ln -s /usr/lib/nginx/modules /etc/nginx >/dev/null 2>&1
rm -rf /etc/nginx/html
wget -O /lib/systemd/system/nginx.service https://raw.githubusercontent.com/Xaster/nginx-debian/master/config/lib/systemd/system/nginx.service
wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/Xaster/nginx-debian/master/config/etc/nginx/nginx.conf
wget -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/Xaster/nginx-debian/master/config/etc/nginx/conf.d/default.conf
wget -O /usr/share/nginx/html/50x.html https://raw.githubusercontent.com/Xaster/nginx-debian/master/config/usr/share/nginx/html/50x.html
wget -O /usr/share/nginx/html/index.html https://raw.githubusercontent.com/Xaster/nginx-debian/master/config/usr/share/nginx/html/index.html
cp -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default
cp -f /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.default
chown -R nginx:nginx /usr/share/nginx/html
systemctl daemon-reload
systemctl enable nginx

#Backup run dependencies
ldd /usr/lib/libjemalloc* \
  /usr/bin/redis* \
  /usr/sbin/nginx* \
  /usr/lib/nginx/modules/*.so | \
  cut -d ">" -f 2 | \
  cut -d "(" -f 1 | \
  sed '/:.*/d' | \
  sed '/linux-vdso.*/d' | \
  sed '/not a dynamic executable.*/d' | \
  sort -u | \
  xargs tar -cvhpPf run-deps.tar

#Remove build dependencies
apt purge --auto-remove -y $(cat build-deps.txt | grep "Unpacking " | cut -d " " -f 2)
apt install -y tzdata
apt clean

#Restore run dependencies
tar --skip-old-files -xpPf run-deps.tar

#Start Redis
systemctl stop redis
systemctl start redis

#Start Nginx
systemctl stop nginx
systemctl start nginx

#Check Redis status
systemctl status redis | grep -q "active (running)"
if [ $? -eq 0 ];then
  echo -e "\033[92m Redis ${Redis_VERSION} has been installed and working. \033[0m"
else
  echo -e "\033[91m Redis start failed. \033[0m"
fi

#Check Nginx status
systemctl status nginx | grep -q "active (running)"
if [ $? -eq 0 ];then
  echo -e "\033[92m Nginx ${NGINX_VERSION} has been installed and working. \033[0m"
else
  echo -e "\033[91m Nginx start failed. \033[0m"
fi

#Remove temporary files
rm -rf \
  $HOME/upx-${UPX_VERSION}-amd64_linux.tar.xz \
  $HOME/upx-${UPX_VERSION}-amd64_linux.tar.xz.1 \
  $HOME/upx-${UPX_VERSION}-amd64_linux.tar \
  $HOME/upx-${UPX_VERSION}-amd64_linux.tar.1 \
  $HOME/jemalloc-${JEMALLOC_VERSION}.tar.bz2 \
  $HOME/jemalloc-${JEMALLOC_VERSION}.tar.bz2.1 \
  $HOME/redis-${REDIS_VERSION}.tar.gz \
  $HOME/redis-${REDIS_VERSION}.tar.gz.1 \
  $HOME/openssl-${OPENSSL_VERSION}.tar.gz \
  $HOME/openssl-${OPENSSL_VERSION}.tar.gz.1 \
  $HOME/nginx-${NGINX_VERSION}.tar.gz \
  $HOME/nginx-${NGINX_VERSION}.tar.gz.1 \
  $HOME/njs-${NJS_VERSION}.tar.gz \
  $HOME/njs-${NJS_VERSION}.tar.gz.1 \
  $HOME/ncp-${NCP_VERSION}.tar.gz \
  $HOME/ncp-${NCP_VERSION}.tar.gz.1 \
  $HOME/nps-v${NPS_VERSION}-stable.tar.gz \
  $HOME/nps-v${NPS_VERSION}-stable.tar.gz.1 \
  $HOME/ngx_http_redis-${NHR_VERSION}.tar.gz \
  $HOME/ngx_http_redis-${NHR_VERSION}.tar.gz.1 \
  $HOME/ndk-v${NDK_VERSION}.tar.gz \
  $HOME/ndk-v${NDK_VERSION}.tar.gz.1 \
  $HOME/smnm-v${SMNM_VERSION}.tar.gz \
  $HOME/smnm-v${SMNM_VERSION}.tar.gz.1 \
  $HOME/enm-v${ENM_VERSION}.tar.gz \
  $HOME/enm-v${ENM_VERSION}.tar.gz.1 \
  $HOME/r2nm-v${R2NM_VERSION}.tar.gz \
  $HOME/r2nm-v${R2NM_VERSION}.tar.gz.1 \
  $HOME/snm-v${SNM_VERSION}.tar.gz \
  $HOME/snm-v${SNM_VERSION}.tar.gz.1 \
  $HOME/build-deps.txt \
  $HOME/run-deps.tar \
  $UPX_DIR \
  $JEMALLOC_DIR \
  $REDIS_DIR \
  $OPENSSL_DIR \
  $NGINX_DIR \
  $NJS_DIR \
  $NCP_DIR \
  $NB_DIR \
  $NPS_DIR \
  $NHR_DIR \
  $NDK_DIR \
  $SMNM_DIR \
  $ENM_DIR \
  $R2NM_DIR \
  $SNM_DIR \
  /bin/upx \
  /var/lib/apt/lists/* \
  /usr/sbin/nginx.old \
  /usr/lib/nginx/modules/ngx_http_image_filter_module.so.old \
  /usr/lib/nginx/modules/ngx_http_xslt_filter_module.so.old \
  /usr/lib/nginx/modules/ngx_http_geoip_module.so.old \
  /usr/lib/nginx/modules/ngx_http_perl_module.so.old \
  /usr/lib/nginx/modules/ngx_stream_module.so.old \
  /usr/lib/nginx/modules/ngx_stream_geoip_module.so.old \
  /usr/lib/nginx/modules/ngx_mail_module.so.old \
  /usr/lib/nginx/modules/ngx_http_js_module.so.old \
  /usr/lib/nginx/modules/ngx_stream_js_module.so.old \
  /usr/lib/nginx/modules/ngx_http_brotli_static_module.so.old \
  /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so.old \
  /usr/lib/nginx/modules/ngx_pagespeed.so.old \
  /usr/lib/nginx/modules/ngx_http_redis_module.so.old \
  /usr/lib/nginx/modules/ndk_http_module.so.old \
  /usr/lib/nginx/modules/ngx_http_set_misc_module.so.old \
  /usr/lib/nginx/modules/ngx_http_echo_module.so.old \
  /usr/lib/nginx/modules/ngx_http_redis2_module.so.old \
  /usr/lib/nginx/modules/ngx_http_srcache_filter_module.so.old

#Restore Redis configuration files
if [ -f "/etc/redis/redis.conf_backup" ];then
  mv -f /etc/redis/redis.conf_backup /etc/redis/redis.conf
fi
systemctl reload redis

#Restore Nginx configuration files
if [ -f "/usr/share/nginx/html/index.html_backup" ];then
  mv -f /usr/share/nginx/html/index.html_backup /usr/share/nginx/html/index.html
fi
if [ -f "/usr/share/nginx/html/50x.html_backup" ];then
  mv -f /usr/share/nginx/html/50x.html_backup /usr/share/nginx/html/50x.html
fi
if [ -d "/etc/nginx/html_backup" ];then
  mv -f /etc/nginx/html_backup /etc/nginx/html
fi
if [ -f "/etc/nginx/nginx.conf_backup" ];then
  mv -f /etc/nginx/nginx.conf_backup /etc/nginx/nginx.conf
fi
find /etc/nginx/conf.d -name "*.conf_backup" | grep -q ".conf_backup"
if [ $? -eq 0 ];then
  cd /etc/nginx/conf.d
  rm -rf default.conf
  rename -f "s/.conf_backup/.conf/" *.conf_backup
  cd
fi
systemctl reload nginx
