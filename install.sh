#!/bin/sh

. ./config

COOKIE_FILENAME=$TARTARUS_HOME/.erlang.cookie
HOSTS_FILENAME=$TARTARUS_HOME/.hosts.erlang

/usr/sbin/useradd -m -d $TARTARUS_HOME $TARTARUS_USER

if [ ! -d $TARTARUS_HOME ]; then
    echo "error: $TARTARUS_HOME doesn't exist"
    exit 1
fi

if [ -f $COOKIE_FILENAME ]; then
    echo "$COOKIE_FILENAME already exists; not overwriting"
else
    install -m 400 -o $TARTARUS_USER -g $TARTARUS_USER erlang.cookie $COOKIE_FILENAME
fi

if [ -f $HOSTS_FILENAME ]; then
    echo "$HOSTS_FILENAME already exists; not overwriting"
else
    install -m 400 -o $TARTARUS_USER -g $TARTARUS_USER hosts.erlang $HOSTS_FILENAME
fi

if [ ! -d $TARTARUS_LOG_DIR ]; then
    echo "creating $TARTARUS_LOG_DIR"
    mkdir -p $TARTARUS_LOG_DIR
    chown $TARTARUS_USER.$TARTARUS_USER $TARTARUS_LOG_DIR
fi

# fix complaints that this file is missing
OTP_RELEASE=`$ERL -noshell -eval "io:format(erlang:system_info(otp_release))." -s erlang halt`
SYSCONFIG=/usr/local/lib/erlang/releases/$OTP_RELEASE/sys.config
if [ ! -f $SYSCONFIG ]; then
    echo "creating $SYSCONFIG"
    echo "[]." > $SYSCONFIG
fi

# config files and init script
[ -d /etc/tartarus ] || mkdir /etc/tartarus
if [ -f /etc/tartarus/config ]; then
    echo "/etc/tartarus/config already exists; not overwriting"
else
    install -m 644 config /etc/tartarus
fi
install -m 755 start /etc/tartarus
install -m 755 stop /etc/tartarus
install -m 755 init /etc/init.d/tartarus
/usr/sbin/update-rc.d -f tartarus remove
/usr/sbin/update-rc.d tartarus defaults 99 01

