file_name=$1 #YYMMDD-HHMM_camX_fruit_sessionY
scratch_input=$2 #src_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/input
scratch_output=$3 #dest_path=${SCRATCH_HOME}/${PROJECT_NAME}/data/output
mkdir -p "${scratch_input}/${file_name}"
tar -xf "${scratch_input}/${file_name}.tar" -C "${scratch_input}/"

python segment.py \
      --video_dir="${scratch_input}/${file_name}" \
      --model_cfg="configs/sam2.1_hiera_l.yaml" \
      --checkpoint="${scratch_input}/checkpoints/sam2.1_hiera_large.pt" \
      --annotations="${scratch_input}/${file_name}/${file_name}.csv" \
      --experiment_name="${file_name}" \
      --output_destination="${scratch_output}"