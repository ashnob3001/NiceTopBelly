#!/bin/sh

set -eu

PORT="${PORT:-8080}"
UUID="$(cat /proc/sys/kernel/random/uuid)"

WS_PATH="/xray"

mkdir -p /etc/xray

cat > /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },

  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",

      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "email": "railway"
          }
        ],
        "decryption": "none"
      },

      "streamSettings": {
        "network": "ws",
        "security": "none",

        "wsSettings": {
          "path": "${WS_PATH}",
          "headers": {
            "Host": ""
          }
        }
      }
    }
  ],

  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

echo
echo "========================================"
echo " Xray started"
echo "========================================"
echo "UUID: ${UUID}"
echo "PORT: ${PORT}"
echo "WS PATH: ${WS_PATH}"
echo
echo "VLESS:"
echo "vless://${UUID}@YOUR-RAILWAY-DOMAIN:443?encryption=none&security=tls&type=ws&host=YOUR-RAILWAY-DOMAIN&path=%2Fxray&sni=YOUR-RAILWAY-DOMAIN#Railway-Xray"
echo "========================================"
echo

exec /usr/local/bin/xray run -config /etc/xray/config.json
