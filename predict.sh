#!/bin/bash
set -e


echo "Starting FLARE25 Task 5 prediction..."
echo "Input directory: inputs/val"
echo "Output directory: outputs/"

# Create output directory if it doesn't exist
mkdir -p outputs/



# Run inference
# echo "Running preprocessing on images..."
# python Data/process/process_ct.py \
#       --json_in inputs/val/val.json \
#       --nifti_dir inputs/val/images \
#       --out_dir inputs/val/val_preprocessed \
#       --out_json inputs



echo "running inference on preprocessed .npy file"
python infer.py \
    --model_name_or_path /workspace/nust1flare/results/baseline \
    --json_path /workspace/nust1flare/inputs/val/val_processed.json \
    --data_root /workspace/nust1flare/inputs/val/val_preprocessed \
    --model_max_length 768 \
    --prompt "simple" \
    --proj_out_num 256


echo "running inference for infer_vqa for"
python infer_vqa.py \
  --model_name_or_path results/baseline \
  --json_path inputs/val/val_processed.json \
  --output_path outputs \
  --model_max_length 512 \
  --data_root inputs/val/val_preprocessed \
  --proj_out_num 256

echo "running final vqa json for "
python eval_vqa.py \
  --pred_csv outputs/predictions.csv \
  --val_json inputs/val/val_processed.json \
  --out_json outputs/vqa.json

echo "Prediction completed!"
echo "Output files:"
ls -la outputs/