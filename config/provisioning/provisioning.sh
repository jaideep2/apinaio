#!/bin/false

# This file will be sourced in init.sh
printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
function download() {
    wget -q --show-progress -e dotbytes="${3:-4M}" -O "$2" "$1"
}

## Set paths
nodes_dir=/opt/ComfyUI/custom_nodes
models_dir=/opt/ComfyUI/models
checkpoints_dir=${models_dir}/checkpoints
vae_dir=${models_dir}/vae
controlnet_dir=${models_dir}/controlnet
loras_dir=${models_dir}/loras
upscale_dir=${models_dir}/upscale_models

### Install custom nodes

# ComfyUI-Manager
this_node_dir=${nodes_dir}/ComfyUI-Manager
if [[ ! -d $this_node_dir ]]; then
    git clone https://github.com/ltdrdata/ComfyUI-Manager $this_node_dir
else
    (cd $this_node_dir && git pull)
fi

# ComfyUI-AnimateDiff-Evolved
this_node_dir=${nodes_dir}/ComfyUI-AnimateDiff-Evolved
if [[ ! -d $this_node_dir ]]; then
    git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved $this_node_dir
else
    (cd $this_node_dir && git pull)
fi

# ComfyUI-Advanced-ControlNet
this_node_dir=${nodes_dir}/ComfyUI-Advanced-ControlNet
if [[ ! -d $this_node_dir ]]; then
    git clone https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet $this_node_dir
else
    (cd $this_node_dir && git pull)
fi

# ComfyUI_FizzNodes
this_node_dir=${nodes_dir}/ComfyUI_FizzNodes
if [[ ! -d $this_node_dir ]]; then
    git clone https://github.com/FizzleDorf/ComfyUI_FizzNodes $this_node_dir
else
    (cd $this_node_dir && git pull && micromamba run -n comfyui ${PIP_INSTALL} -r requirements.txt)
fi

# comfyui_controlnet_aux
this_node_dir=${nodes_dir}/comfyui_controlnet_aux
if [[ ! -d $this_node_dir ]]; then
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux $this_node_dir
else
    (cd $this_node_dir && git pull && micromamba run -n comfyui ${PIP_INSTALL} -r requirements.txt)
fi

# ComfyUI-VideoHelperSuite
this_node_dir=${nodes_dir}/ComfyUI-VideoHelperSuite
if [[ ! -d $this_node_dir ]]; then
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite $this_node_dir
else
    (cd $this_node_dir && git pull)
fi

## Standard
# v1-5-pruned-emaonly
#model_file=${checkpoints_dir}/v1-5-pruned-emaonly.ckpt
#model_url=https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt
#if [[ ! -e ${model_file} ]]; then
#    printf "Downloading Stable Diffusion 1.5...\n"
#    download ${model_url} ${model_file}
#fi

# revAnimated_v11.safetensors
model_file=${checkpoints_dir}/revAnimated_v11.safetensors
model_url=https://huggingface.co/nergaldarski/RevAnimated/resolve/main/revAnimated_v11.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "revAnimated_v11.safetensors...\n"
    download ${model_url} ${model_file}
fi

# sd-vae-ft-mse-original
model_file=${vae_dir}/vae-ft-mse-840000-ema-pruned.safetensors
model_url=https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "sd-vae-ft-mse-original...\n"
    download ${model_url} ${model_file}
fi

## AnimatedDiff Models
animated_models_dir=${nodes_dir}/ComfyUI-AnimateDiff-Evolved/models

# mm_sd_v14
model_file=${animated_models_dir}/mm_sd_v14.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v14.ckpt
if [[ ! -e ${model_file} ]]; then
    printf "mm_sd_v14.ckpt...\n"
    download ${model_url} ${model_file}
fi

# mm_sd_v15
model_file=${animated_models_dir}/mm_sd_v15.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15.ckpt
if [[ ! -e ${model_file} ]]; then
    printf "mm_sd_v15.ckpt...\n"
    download ${model_url} ${model_file}
fi

# mm_sd_v15_v2
model_file=${animated_models_dir}/mm_sd_v15_v2.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt
if [[ ! -e ${model_file} ]]; then
    printf "mm_sd_v15_v2.ckpt...\n"
    download ${model_url} ${model_file}
fi

# mm-Stabilized_mid Stabilized finetunes of mm_sd_v14
model_file=${animated_models_dir}/mm-Stabilized_mid.pth
model_url=https://huggingface.co/manshoety/AD_Stabilized_Motion/resolve/main/mm-Stabilized_mid.pth
if [[ ! -e ${model_file} ]]; then
    printf "mm-Stabilized_mid.pth...\n"
    download ${model_url} ${model_file}
fi

# mm-Stabilized_high Stabilized finetunes of mm_sd_v15
model_file=${animated_models_dir}/mm-Stabilized_high.pth
model_url=https://huggingface.co/manshoety/AD_Stabilized_Motion/resolve/main/mm-Stabilized_high.pth
if [[ ! -e ${model_file} ]]; then
    printf "mm-Stabilized_high.pth...\n"
    download ${model_url} ${model_file}
fi

# mm-p_0.5 Finetunes of mm_sd_v15_v2
model_file=${animated_models_dir}/mm-p_0.5.pth
model_url=https://huggingface.co/manshoety/beta_testing_models/resolve/main/mm-p_0.5.pth
if [[ ! -e ${model_file} ]]; then
    printf "mm-p_0.5.pth...\n"
    download ${model_url} ${model_file}
fi

# mm-p_0.75 Finetunes of mm_sd_v15_v2
model_file=${animated_models_dir}/mm-p_0.75.pth
model_url=https://huggingface.co/manshoety/beta_testing_models/resolve/main/mm-p_0.75.pth
if [[ ! -e ${model_file} ]]; then
    printf "mm-p_0.75.pth...\n"
    download ${model_url} ${model_file}
fi

# temporaldiff-v1-animatediff Higher resolution finetune
model_file=${animated_models_dir}/temporaldiff-v1-animatediff.safetensors
model_url=https://huggingface.co/CiaraRowles/TemporalDiff/resolve/main/temporaldiff-v1-animatediff.safetensors
if [[ ! -e ${model_file} ]]; then
    printf "temporaldiff-v1-animatediff.safetensors...\n"
    download ${model_url} ${model_file}
fi

## AnimatedDiff MotionLORAS
animated_motion_lora_dir=${nodes_dir}/ComfyUI-AnimateDiff-Evolved/motion_lora

# v2_lora_PanLeft
model_file=${animated_motion_lora_dir}/v2_lora_PanLeft.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_PanLeft.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_PanLeft...\n"
    download ${model_url} ${model_file}
fi

# v2_lora_PanRight
model_file=${animated_motion_lora_dir}/v2_lora_PanRight.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_PanRight.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_PanRight...\n"
    download ${model_url} ${model_file}
fi

# v2_lora_RollingAnticlockwise.ckpt
model_file=${animated_motion_lora_dir}/v2_lora_RollingAnticlockwise.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_RollingAnticlockwise.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_RollingAnticlockwise...\n"
    download ${model_url} ${model_file}
fi

# v2_lora_RollingClockwise.ckpt
model_file=${animated_motion_lora_dir}/v2_lora_RollingClockwise.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_RollingClockwise.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_RollingClockwise...\n"
    download ${model_url} ${model_file}
fi

# v2_lora_TiltDown.ckpt
model_file=${animated_motion_lora_dir}/v2_lora_TiltDown.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_TiltDown.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_TiltDown...\n"
    download ${model_url} ${model_file}
fi

# v2_lora_TiltUp.ckpt
model_file=${animated_motion_lora_dir}/v2_lora_TiltUp.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_TiltUp.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_TiltUp...\n"
    download ${model_url} ${model_file}
fi

# v2_lora_ZoomIn.ckpt
model_file=${animated_motion_lora_dir}/v2_lora_ZoomIn.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_ZoomIn.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_ZoomIn...\n"
    download ${model_url} ${model_file}
fi

# v2_lora_ZoomOut.ckpt
model_file=${animated_motion_lora_dir}/v2_lora_ZoomOut.ckpt
model_url=https://huggingface.co/guoyww/animatediff/resolve/main/v2_lora_ZoomOut.ckpt

if [[ ! -e ${model_file} ]]; then
    printf "v2_lora_ZoomOut...\n"
    download ${model_url} ${model_file}
fi

## AnimatedDiff Interesting Loras

# toonyou_beta3.safetensors
#https://civitai.com/api/download/models/78775

# lyriel_v16.safetensors
#https://civitai.com/api/download/models/72396

# rcnzCartoon3d_v10.safetensors
#https://civitai.com/api/download/models/71009

# majicmixRealistic_v5Preview.safetensors
#https://civitai.com/api/download/models/79068

# realisticVisionV51_v20Novae.safetensors
#https://civitai.com/api/download/models/29460

# TUSUN.safetensors
#https://civitai.com/api/download/models/97261
# leosamsHelloworldSDXLModel_reality20.safetensors
#https://civitai.com/api/download/models/50705

# FilmVelvia2.safetensors
#https://civitai.com/api/download/models/90115
# leosamsHelloworldSDXLModel_filmGrain10.safetensors
#https://civitai.com/api/download/models/92475

# Pyramid lora_Ghibli_n3.safetensors
#https://civitai.com/api/download/models/102828
# CounterfeitV30_v30.safetensors
#https://civitai.com/api/download/models/57618

# CarDos Anime 2.0 full
# https://civitai.com/api/download/models/43825?type=Model&format=SafeTensor&size=full&fp=fp16

# CarDos Animated 3.0 pruned
# https://civitai.com/api/download/models/101966?type=Model&format=SafeTensor&size=pruned&fp=fp16