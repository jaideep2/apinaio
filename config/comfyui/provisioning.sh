#!/bin/false

# This file will be sourced in init.sh
printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
function download() {
    wget -q --show-progress -e dotbytes="${3:-4M}" -O "$2" "$1"
    printf "\n"
}

# Set paths
nodes_dir=/opt/ComfyUI/custom_nodes
models_dir=/opt/ComfyUI/models
checkpoints_dir=${models_dir}/checkpoints
vae_dir=${models_dir}/vae
embeddings_dir=${models_dir}/embeddings
controlnet_dir=${models_dir}/controlnet
loras_dir=${models_dir}/loras
upscale_dir=${models_dir}/upscale_models
animated_models_dir=${nodes_dir}/ComfyUI-AnimateDiff-Evolved/models
animated_motion_lora_dir=${nodes_dir}/ComfyUI-AnimateDiff-Evolved/motion_lora

# Install custom nodes
NODES_CSV=/opt/ai-dock/bin/nodes.csv
count=$(awk 'END { print NR }' ${NODES_CSV})
printf "Found ${count} custom nodes\n"

# Read in node names, urls, and directories
for (( i=1; i<=$count; i++ ))
{
    node_name[$i]=$(awk -F ',' 'NR=='$i' {print $1}' "${NODES_CSV}")
    node_url[$i]=$(awk -F ',' 'NR=='$i' {print $2}' "${NODES_CSV}")
    node_pip[$i]=$(awk -F ',' 'NR=='$i' {print $3}' "${NODES_CSV}")
}

# Download custom nodes
for (( i=1; i<=$count; i++ ))
{
    node_dir=${nodes_dir}/${node_name[$i]}
    if [[ ! -d ${node_dir} ]]; then
        printf "[$i/$count] Installing ${node_name[$i]}...\n"
        git clone ${node_url[$i]} $node_dir
    else
        printf "[$i/$count] ${node_name[$i]} exists, updating...\n"
        (cd $node_dir && git pull)
        if [[ ${node_pip[$i]} == "comfyui" ]]; then
            micromamba run -n comfyui ${PIP_INSTALL} -r $node_dir/requirements.txt
        fi
    fi
}

# Install models
MODEL_CSV=/opt/ai-dock/bin/models.csv
count=$(awk 'END { print NR }' ${MODEL_CSV})
printf "Found ${count} models\n"

# Read in model names, urls, and directories
for (( i=1; i<=$count; i++ ))
{
    model_name[$i]=$(awk -F ',' 'NR=='$i' {print $1}' "${MODEL_CSV}")
    model_url[$i]=$(awk -F ',' 'NR=='$i' {print $2}' "${MODEL_CSV}")
    model_dir[$i]=$(awk -F ',' 'NR=='$i' {print $3}' "${MODEL_CSV}")
}

# Download models
for (( i=1; i<=$count; i++ ))
{
    model_file=${!model_dir[$i]}/${model_name[$i]}
    if [[ ! -e ${model_file} ]]; then
        printf "[$i/$count] Downloading ${model_name[$i]}...\n"
        download ${model_url[$i]} ${model_file}
    else
        printf "[$i/$count] ${model_name[$i]} exists, skipping...\n"
    fi
}