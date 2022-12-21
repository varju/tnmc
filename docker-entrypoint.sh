#!/bin/bash

if [[ -n "$POSTFIX_ENABLED" ]]; then
  sudo postfix start
fi

exec /usr/sbin/apache2 -DFOREGROUND
