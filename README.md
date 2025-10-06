# DevopsPetCat
A Python server to fetch random images from S3 using Nginx, Prometheus, Grafana, Nginx Exporter
# Run app
```commandline
 uvicorn app.app:app --host 0.0.0.0 --port 5000 --workers 4

```

# Run app from Docker
```commandline
docker run -d -p 8080:80 -p 5000:5000 devops-kitty-cat
```


# See cats on if instance is running
```commandline
http://http://54.172.220.31:5000/random-image
 ```

# Grafana
```commandline
http://54.172.220.31:3000/
```

# A list of metrics can be seen in the Devops Kitty Cat Dashboard
- nginx_connections_accepted
- nginx_connections_active
- nginx_connections_handled
- nginx_connections_reading
- nginx_connections_waiting
- nginx_connections_writing
- nginx_http_requests_total
- nginx_up


# Prometheus
```commandline
http://54.172.220.31:9090/
```

# Nginx Exporter
```commandline
http://54.172.220.31:9113/
```
