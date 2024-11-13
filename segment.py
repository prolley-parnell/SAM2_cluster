import os
# if using Apple MPS, fall back to CPU for unsupported ops
os.environ["PYTORCH_ENABLE_MPS_FALLBACK"] = "1"
import numpy as np
import torch
# Initialise the video predictor
from sam2.build_sam import build_sam2_video_predictor
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--video_dir", type=str, required=True, help="Relative path of folder with video frames")
parser.add_argument("--model_cfg", type=str, required=True, help="SAM2 Model Config", default="configs/sam2.1/sam2.1_hiera_l.yaml")
parser.add_argument("--checkpoint", type=str, required=True, help="SAM2 Checkpoint ends in '.pt'", default="../checkpoints/sam2.1_hiera_large.pt")
parser.add_argument("--annotation", type=str, required=True, help="Path of annotations for this file. CSV format", default="annotations.csv")
parser.add_argument("--experiment_name", type=str, required=True, help="Name of the experiment for saving output files", default="000000-0000_cam0_session0")
parser.add_argument("--output_destination", type=str, required=True, help="Name of the folder to deposit results of experiment", default="")


def main(args):

    # select the device for computation
    if torch.cuda.is_available():
        device = torch.device("cuda")
    elif torch.backends.mps.is_available():
        device = torch.device("mps")
    else:
        device = torch.device("cpu")
    print(f"using device: {device}")

    if device.type == "cuda":
        # use bfloat16 for the entire notebook
        torch.autocast("cuda", dtype=torch.bfloat16).__enter__()
        # turn on tfloat32 for Ampere GPUs (https://pytorch.org/docs/stable/notes/cuda.html#tensorfloat-32-tf32-on-ampere-devices)
        if torch.cuda.get_device_properties(0).major >= 8:
            torch.backends.cuda.matmul.allow_tf32 = True
            torch.backends.cudnn.allow_tf32 = True
    elif device.type == "mps":
        print(
            "\nSupport for MPS devices is preliminary. SAM 2 is trained with CUDA and might "
            "give numerically different outputs and sometimes degraded performance on MPS. "
            "See e.g. https://github.com/pytorch/pytorch/issues/84936 for a discussion."
        )

    #--- Extract data from folder
    # `video_dir` a directory of JPEG frames with filenames like `<frame_index>.jpg`
    video_dir = args.video_dir #"./videos/bedroom"

    # scan all the JPEG frame names in this directory
    frame_names = [
        p for p in os.listdir(video_dir) #This code struggles if the folder contains hidden .jpeg files after unzipping.
        if not p.startswith('.') and os.path.splitext(p)[-1] in [".jpg", ".jpeg", ".JPG", ".JPEG"]
    ]
    frame_names.sort(key=lambda p: int(os.path.splitext(p)[0]))


    #--- Initialise predictor
    predictor = build_sam2_video_predictor(args.model_cfg, args.checkpoint, device=device)
    inference_state = predictor.init_state(video_path=video_dir, offload_video_to_cpu=True, offload_state_to_cpu=False)

    #--- Load Video Annotations
    csv_x, csv_y, csv_flag, csv_frame = np.loadtxt(
    args.annotation, delimiter=",", comments='#', dtype=float, unpack=True)

    frame_idx = csv_frame.astype(int)
    labels = csv_flag.astype(int)
    points = np.column_stack((csv_x, csv_y)).astype(np.float32)

    unique_frames = np.unique(frame_idx)
    for u in unique_frames:
        #--- Add annotations to predictor
        _, _, out_mask_logits = predictor.add_new_points_or_box(
            inference_state=inference_state,
            frame_idx=u,
            obj_id=1,
            points=points[frame_idx == u],
            labels=labels[frame_idx == u],
        )

    #--- Propagate through video

    # run propagation throughout the video and collect the results in a dict
    video_segments = {}  # video_segments contains the per-frame segmentation results
    for out_frame_idx, out_obj_ids, out_mask_logits in predictor.propagate_in_video(inference_state):
        video_segments[out_frame_idx] = {
            out_obj_id: (out_mask_logits[i] > 0.0).cpu().numpy()
            for i, out_obj_id in enumerate(out_obj_ids)
        }

    frames = [f for f in video_segments]  # This extracts the frame indices
    output_stacked_mask = []
    for f in frames:
        for out_obj_id, out_mask in video_segments[f].items():
            flat_mask = np.flatnonzero(out_mask)
            if len(flat_mask) > 0: #Ensure not to waste space with any empty frames
                output_stacked_mask.append(np.column_stack((np.ones_like(flat_mask) * f, flat_mask)))
    sparse = np.vstack(output_stacked_mask)

    #np.save(f"{args.output_destination}/{args.experiment_name}.npy", video_segments)
    np.savez_compressed(f"{args.output_destination}/{args.experiment_name}", obj_0=sparse )


if __name__ == "__main__":
    args = parser.parse_args()
    main(args)
    print("done!")