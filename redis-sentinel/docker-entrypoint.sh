#!/bin/sh

if [ "$1" = 'redis-sentinel' ]; then
    # Allow passing in cluster IP by argument or environmental variable
    IP="${2:-$IP}"

    if [ -z "$IP" ]; then # If IP is unset then discover it
        IP=$(hostname -I)
    fi

    echo " -- IP Before trim: '$IP'"
    IP=$(echo ${IP}) # trim whitespaces
    echo " -- IP Before split: '$IP'"
    IP=${IP%% *} # use the first ip
    echo " -- IP After trim: '$IP'"

    if [ -z "$INITIAL_PORT" ]; then # Default to port 7100
      INITIAL_PORT=7100
    fi

    if [ -z "$SLAVES" ]; then # Default to 3 slaves
      SLAVES=2
    fi

    if [ -z "$BIND_ADDRESS" ]; then # Default to any IPv4 address
      BIND_ADDRESS=0.0.0.0
    fi

    max_port=$(($INITIAL_PORT + $SLAVES))

    for port in $(seq $INITIAL_PORT $max_port); do
      mkdir -p /redis-conf/${port}
      mkdir -p /redis-data/${port}

      if [ -e /redis-data/${port}/dump.rdb ]; then
        rm /redis-data/${port}/dump.rdb
      fi

      if [ -e /redis-data/${port}/appendonly.aof ]; then
        rm /redis-data/${port}/appendonly.aof
      fi

      PORT=${port} BIND_ADDRESS=${BIND_ADDRESS} envsubst < /redis-conf/redis.tmpl > /redis-conf/${port}/redis.conf

      IP=${IP} PORT=${INITIAL_PORT} SENTINEL_PORT=$((port + 10000)) envsubst < /redis-conf/sentinel.tmpl > /redis-conf/sentinel-${port}.conf
      cat /redis-conf/sentinel-${port}.conf

    done

    bash /generate-supervisor-conf.sh $INITIAL_PORT $max_port > /etc/supervisor/supervisord.conf
    
    supervisord -c /etc/supervisor/supervisord.conf
    sleep 3

    tail -f /var/log/supervisor/redis*.log
else
  exec "$@"
fi
