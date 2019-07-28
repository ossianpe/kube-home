kubectl delete secret rbpsycamore.duckdns.org -n hass
kubectl create secret tls rbpsycamore.duckdns.org --key /mnt/home-assistant/config/ssl/letsencrypt/rbpsycamore.duckdns.org/privkey.pem --cert /mnt/home-assistant/config/ssl/letsencrypt/rbpsycamore.duckdns.org/fullchain.pem -n hass
