# apinaio

Ready to host LlaMa LLM Example API

## Requirements

- FastAPI
- Gunicorn
- Uvicorn
- llama-cpp-python
- Docker

## Plan

- [x] Proof of concept Llama API
- [ ] Enable https with domain
- [ ] Update docs
- [ ] Create Admin
- [ ] Create frontend chat application
- [ ] Connect to db (Mongo DB?)
- [ ] Dockerize
- [ ] Add add stable diffusion API

## Current workflow for GCP VM

### Followed this

https://www.slingacademy.com/article/deploying-fastapi-on-ubuntu-with-nginx-and-lets-encrypt/

### Init VM

```
sudo apt update
sudo apt install python3-pip # Install root pip3
sudo apt -y install gunicorn # need to install systemwide
sudo pip install uvicorn
sudo pip install fastapi
```

### download vicuna weights

```
sudo apt-get update
sudo apt-get -y install git-lfs
git lfs install --skip-smudge
git clone https://huggingface.co/eachadea/ggml-vicuna-13b-4bit
cd ggml-vicuna-13b-4bit/
git lfs pull --include=ggml-vicuna-13b-4bit-rev1.bin
```

### install llama api

```
sudo pip3 install llama-cpp-python --no-cache-dir
```

### test api

```
from llama_cpp import Llama
llm = Llama(model_path="/home/jaideep_vancity/ggml-vicuna-13b-4bit/ggml-vicuna-13b-4bit-rev1.bin")
output = llm("Q: Name the planets in the solar system? A: ", max_tokens=64, stop=["Q:", "\n"], echo=True)
print(output)
```

### install llama server

```
sudo pip3 install sse-starlette
mkdir llama-api
get this file https://github.com/abetlen/llama-cpp-python/blob/main/examples/high_level_api/fastapi_server.py
```

### test gunicorn

```
export MODEL=/home/jaideep_vancity/ggml-vicuna-13b-4bit/ggml-vicuna-13b-4bit-rev1.bin
```

Edit vim llama_api/gunicorn_conf.py

```python
from multiprocessing import cpu_count

bind = "127.0.0.1:8000"

# Worker Options
workers = cpu_count() + 1
worker_class = 'uvicorn.workers.UvicornWorker'

# Logging Options
loglevel = 'debug'
accesslog = '/home/jaideep_vancity/llama_api/access_log'
errorlog =  '/home/jaideep_vancity/llama_api/error_log'
```

```
gunicorn fastapi_server:app -k uvicorn.workers.UvicornWorker
```

### Create service

```
sudo vim /etc/systemd/system/llama_api.service
```

```bash
[Unit]
Description=Gunicorn Daemon for FastAPI example
After=network.target

[Service]
User=jaideep_vancity
Group=admin
WorkingDirectory=/home/jaideep_vancity/llama_api
Environment="MODEL=/home/jaideep_vancity/ggml-vicuna-13b-4bit/ggml-vicuna-13b-4bit-rev1.bin"
ExecStart=/usr/bin/gunicorn -c gunicorn_conf.py fastapi_server:app

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl start llama_api
sudo systemctl enable llama_api
sudo systemctl status llama_api
```

### start nginx

```
sudo apt install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

### setup nginx config

```
sudo mv /etc/nginx/sites-enabled/default ./default_backup
```

Edit sudo vim /etc/nginx/sites-available/llama.api

```nginx
server {
        client_max_body_size 64M;
        listen 80 default_server;
	   listen [::]:80 default_server;
        allow IPADDRESS;
        deny all;

        location / {
                proxy_pass             http://127.0.0.1:8000;
                proxy_read_timeout     60;
                proxy_connect_timeout  60;
                proxy_redirect         off;

                # Allow the use of websockets
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
        }

}
```

```
sudo ln -s /etc/nginx/sites-available/llama.api /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### HTTPS

https://www.wpmentor.com/setup-domain-google-cloud-platform/

### Done!

visit http://IPADDRESS/docs to see the OpenAPI API docs
