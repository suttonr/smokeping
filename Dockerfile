##  Forked from dperson/smokeping

FROM debian:jessie
MAINTAINER Ryan M Sutton <me@ryanmsutton.com>

# Install lighttpd and smokeping
RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends smokeping ssmtp dnsutils \
                fonts-dejavu-core echoping curl lighttpd \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    apt-get clean && \
    mkdir -p /etc/confd/{conf.d,templates} && \
    sed -i '/server.errorlog/s|^|#|' /etc/lighttpd/lighttpd.conf && \
    sed -i '/server.document-root/s|/html||' /etc/lighttpd/lighttpd.conf && \
    sed -i '/^#cgi\.assign/,$s/^#//; /"\.pl"/i \ \t".cgi"  => "/usr/bin/perl",'\
                /etc/lighttpd/conf-available/10-cgi.conf && \
    sed -i -e '/CHILDREN/s/[0-9][0-9]*/16/' \
                -e '/max-procs/a \ \t\t"idle-timeout" => 20,' \
                /etc/lighttpd/conf-available/15-fastcgi-php.conf && \
    grep -q 'allow-x-send-file' \
                /etc/lighttpd/conf-available/15-fastcgi-php.conf || { \
        sed -i '/idle-timeout/a \ \t\t"allow-x-send-file" => "enable",' \
                    /etc/lighttpd/conf-available/15-fastcgi-php.conf && \
        sed -i '/"bin-environment"/a \ \t\t\t"MOD_X_SENDFILE2_ENABLED" => "1",'\
                    /etc/lighttpd/conf-available/15-fastcgi-php.conf; } && \
    lighttpd-enable-mod cgi && \
    lighttpd-enable-mod fastcgi && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    ln -s /usr/share/smokeping/www /var/www/smokeping && \
    ln -s /usr/lib/cgi-bin /var/www/ && \
    ln -s /usr/lib/cgi-bin/smokeping.cgi /var/www/smokeping/

COPY launch.sh /usr/local/bin/
COPY *.tmpl /etc/confd/templates/
COPY *.toml /etc/confd/conf.d/
COPY confd /usr/local/bin/confd

VOLUME ["/etc/smokeping", "/etc/ssmtp", "/var/lib/smokeping"]

EXPOSE 80

ENTRYPOINT ["smokeping.sh"]
