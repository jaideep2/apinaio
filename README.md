# APInAIo

> **Warning**  
> In development phase.

Ready to work text2video pipeline using [Ollama](https://github.com/jmorganca/ollama) + [ComfyUI](https://github.com/comfyanonymous/ComfyUI) + [ffmpeg](https://ffmpeg.lav.io/) Docker images

## Overview

One click deployment of [most LLMs](https://ollama.ai/library), most [ComfyUI packages](https://github.com/WASasquatch/comfyui-plugins) and [ffmpeg](https://www.ffmpeg.org/) for all your text2video AI needs. All three can be configured under config folder. For example:

- config/ollama/entrypoint.sh for downloading models and serving via [API]()
- config/ollama/modelfiles for defining [custom models]()
- config/comfyui/provisioning.sh for installing custom packages and nodes
- config/comfyui/models.csv for defining [custom models]()
- config/comfyui/nodes.csv for defining [custom nodes]()

## Example run

```bash
docker compose up -d # Will take a while
pip install -r requirements.txt
gradio example.py # Running on local URL:  http://127.0.0.1:7860
```
Tested on: Python 3.10 / Pytorch 2.0.1, NVIDIA CUDA (WSL) (Have not tested others yet)

## Individual Docker images

Rename template.env to .env and define all the environment variables there then launch one or all three containers with docker compose:

```bash
docker-compose up ollama-api -d
docker-compose up comfyui-api -d
docker-compose up ffmpeg-api -d
```

## Ollama-API

### API examples

Check all the available models

```bash
curl http://localhost:11434/api/tags
```

Use midjourney prompt generator model

```bash
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "mj:latest",
  "prompt": "a sports car in the mountains.",
  "stream": false}'
```

View model information

```bash
http://localhost:11434/api/show -d '{
  "name": "mj:latest"
}'
```
## ComfyUI

### API examples

Check all the available models

```bash
curl http://localhost:8188/api/tags
```

### Security

By default, all exposed web services other than the port redirect page are protected by HTTP basic authentication.

The default username is `user` and the password is `password`.

You can set your credentials by passing environment variables as shown above.

The password is stored as a bcrypt hash. If you prefer not to pass a plain text password to the container you can pre-hash and use the variable `WEB_PASSWORD_HASH`.

If you are running the image locally on a trusted network, you may disable authentication by setting the environment variable `WEB_ENABLE_AUTH=false`.

### Provisioning script

It can be useful to perform certain actions when starting a container, such as creating directories and downloading files.

You can use the environment variable `PROVISIONING_SCRIPT` to specify the URL of a script you'd like to run.

The URL must point to a plain text file - GitHub Gists/Pastebin (raw) are suitable options.

> **Warning**  
> Only use scripts that you trust since they will be executed as root.

## FFmpeg-API

### API endpoints

* `GET http://localhost:3000/` - API Readme.
* `GET http://localhost:3000/endpoints` - Service endpoints as JSON.
* `POST http://localhost:3000/convert/audio/to/mp3` - Convert audio file in request body to mp3. Returns mp3-file.
* `POST http://localhost:3000/convert/audio/to/wav` - Convert audio file in request body to wav. Returns wav-file.
* `POST http://localhost:3000/convert/video/to/mp4` - Convert video file in request body to mp4. Returns mp4-file.
* `POST http://localhost:3000/convert/image/to/jpg` - Convert image file to jpg. Returns jpg-file.
* `POST http://localhost:3000/video/extract/audio` - Extract audio track from POSTed video file.
  * Returns audio track as 1-channel wav-file.
  * Query param: `mono=no` - Returns audio track, all channels.
* `POST http://localhost:3000/video/extract/images` - Extract images from POSTed video file as PNG. Default FPS is 1.
  * Returns JSON that includes download links to extracted images.
  * Query param: `compress=zip|gzip` - Returns extracted images as _zip_ or _tar.gz_ (gzip).
  * Query param: `fps=2` - Extract images using specified FPS. 
* `GET http://localhost:3000/video/extract/download/:filename` - Downloads extracted image file and deletes it from server.
  * Query param: `delete=no` - does not delete file.
* `POST http://localhost:3000/probe` - Probe media file, return JSON metadata.

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function


| Open Port             | Service / Description     |
| --------------------- | ------------------------- |
| `11434`               | Ollama web server         |
| `8188`                | ComfyUI Interface         |
| `3000`                | FFmpeg-api web server     |
