# Home-assistant

## Information

In here lies charts for building `home-assistant` with `helm`. Several `Hass.io` `Add-ons` have been ported to `Helm` charts as well

## Running backup

To make a backup (depending on how storage system is configured) use:

```bash
tar -czf backup_$(date +"%m_%d_%y").tar /mnt/home-assistant/config/
```
