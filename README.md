# apinaio

> **Warning**  
> In development phase. Help is needed!

Ready to host [Ollama](https://github.com/jmorganca/ollama) + [ComfyUI](https://github.com/comfyanonymous/ComfyUI) + [ffmpeg](https://ffmpeg.lav.io/) Docker images

## Features

One click deployment of [most LLMs](https://ollama.ai/library), most [ComfyUI packages](https://github.com/WASasquatch/comfyui-plugins) and [ffmpeg](https://www.ffmpeg.org/) for all your text2video needs. All three can be configured under config folder. For example:

- config/ollama/entrypoint.sh for downloading models and serving via [API]()
- config/ollama/modelfiles for defining [custom models]()
- config/comfyui/provisioning.sh for installing custom packages and nodes
- config/comfyui/models.csv for defining [custom models]()
- config/comfyui/nodes.csv for defining [custom nodes]()

## Start

Rename template.env to .env and define all the environment variables there then launch one or all three containers with docker compose.

Supported Python versions: 3.10

Supported Pytorch versions: 2.0.1

Supported Platforms: NVIDIA CUDA, CPU (Have not tested others yet)

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function


| Open Port             | Service / Description     |
| --------------------- | ------------------------- |
| `22`                  | SSH server                |
| `1111`                | Port redirector web UI    |
| `1122`                | Log viewer web UI         |
| `8188`                | ComfyUI Interface         |
| `53682`               | Rclone interactive config |
| `11434`               | Ollama web server         |
| `3000`                | FFmpeg-api web server     |

## ComfyUI

### Environment Variables (still updating..)

| Variable              | Description |
| --------------------- | ----------- |
| `CF_TUNNEL_TOKEN`     | Cloudflare zero trust tunnel token - See [documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/). |
| `CF_QUICK_TUNNELS`    | Create ephemeral Cloudflare tunnels for web services (default `false`) |
| `COMFYUI_BRANCH`      | ComfyUI branch/commit hash. Defaults to `master` |
| `COMFYUI_FLAGS`       | Startup flags. eg. `--gpu-only --highvram` |
| `COMFYUI_PORT`        | ComfyUI interface port (default `8188`) |
| `GPU_COUNT`           | Limit the number of available GPUs |
| `PROVISIONING_SCRIPT` | URL of a remote script to execute on init. See [note](#provisioning-script). |
| `RCLONE_*`            | Rclone configuration - See [rclone documentation](https://rclone.org/docs/#config-file) |
| `SKIP_ACL`            | Set `true` to skip modifying workspace ACL |
| `SSH_PORT`            | Set a non-standard port for SSH (default `22`) |
| `SSH_PUBKEY`          | Your public key for SSH |
| `WEB_ENABLE_AUTH`     | Enable password protection for web services (default `true`) |
| `WEB_USER`            | Username for web services (default `user`) |
| `WEB_PASSWORD`        | Password for web services (default `password`) |
| `WORKSPACE`           | A volume path. Defaults to `/workspace/` |
| `WORKSPACE_SYNC`      | Move mamba environments and services to workspace if mounted (default `true`) |

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

If you are running locally you may instead opt to mount a script at `/opt/ai-dock/bin/provisioning.sh`.

>[!NOTE]  
>If configured, `sshd`, `caddy`, `cloudflared`, `rclone`, `port redirector` & `logtail` will be launched before provisioning; Any other processes will launch after.


>[!WARNING]  
>Only use scripts that you trust and which cannot be changed without your consent.

## Ollama

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

## FFmpeg

### API Endpoints

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

### Environment variables

These can be changed in `docker-compose.yml:ffmpeg-api:environment`

* Default log level is _info_. Set log level using environment variable, _LOG_LEVEL_.
* Set log level to debug: `LOG_LEVEL=debug`
* Default maximum file size of uploaded files is 512MB. Use _FILE_SIZE_LIMIT_BYTES_ to change it for example Set max file size to 1MB: `FILE_SIZE_LIMIT_BYTES=1048576`
* All uploaded and converted files are deleted when they've been downloaded. Use _KEEP_ALL_FILES_ to keep all files inside the container /tmp: `KEEP_ALL_FILES=true`
* When running on Docker/Kubernetes, port binding can be different than default 3000. Use _EXTERNAL_PORT_ to set up external port in returned URLs in extracted images JSON: `EXTERNAL_PORT=3001`

### Convert examples

Convert audio/video/image files using the API.

* `curl -F "file=@input.wav" localhost:3000/convert/audio/to/mp3  > output.mp3`
* `curl -F "file=@input.m4a" localhost:3000/convert/audio/to/wav  > output.wav`
* `curl -F "file=@input.mov" localhost:3000/convert/video/to/mp4  > output.mp4`
* `curl -F "file=@input.mp4" localhost:3000/convert/videp/to/mp4  > output.mp4`
* `curl -F "file=@input.tiff" localhost:3000/convert/image/to/jpg  > output.jpg`
* `curl -F "file=@input.png" localhost:3000/convert/image/to/jpg  > output.jpg`

### Extract images examples

Extract images from video using the API.

* `curl -F "file=@input.mov" localhost:3000/video/extract/images`
  * Returns JSON that lists image download URLs for each extracted image.
  * Default FPS is 1.
  * Images are in PNG-format.
  * See sample: link: [extracted_images.json](/config/ffmpeg/samples/extracted_images.json)
* `curl localhost:3000/video/extract/download/ba0f565c-0001.png`
  * Downloads exracted image and deletes it from server.
* `curl localhost:3000/video/extract/download/ba0f565c-0001.png?delete=no`
  * Downloads exracted image but does not deletes it from server.
* `curl -F "file=@input.mov" localhost:3000/video/extract/images?compress=zip > images.zip`
  * Returns ZIP package of all extracted images.
* `curl -F "file=@input.mov" localhost:3000/video/extract/images?compress=gzip > images.tar.gz`
  * Returns GZIP (tar.gz) package of all extracted images.
* `curl -F "file=@input.mov" localhost:3000/video/extract/images?fps=0.5`
  * Sets FPS to extract images. FPS=0.5 is every two seconds, FPS=4 is four images per seconds, etc.

### Extract audio examples

Extract audio track from video using the API.

* `curl -F "file=@input.mov" localhost:3000/video/extract/audio`
  * Returns 1-channel WAV-file of video's audio track.
* `curl -F "file=@input.mov" localhost:3000/video/extract/audio?mono=no`
  * Returns WAV-file of video's audio track, with all the channels as in input video.

### ffprobe examples

Probe audio/video/image files using the API.

* `curl -F "file=@input.mov" localhost:3000/probe`
  * Returns JSON metadata of media file.
  * The same JSON metadata as in ffprobe command: `ffprobe -of json -show_streams -show_format input.mov`.
  * See sample of MOV-video metadata: [probe_metadata.json](/config/ffmpeg-api/samples/probe_metadata.json)


# Docker Register
Coming soon
