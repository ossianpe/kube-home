# Hass (Home Assistant)

*Please note: hass does not appear to work with helm/kubernetes 0.86.2*

### Install with:

helm install --name hass -f values.yaml stable/home-assistant

### Create LB with:

kubectl create -f external-hass.yaml

## Manual way of creating LB (not recommended):

kubectl expose deployment hass-home-assistant --type=LoadBalancer --name=hass-external
