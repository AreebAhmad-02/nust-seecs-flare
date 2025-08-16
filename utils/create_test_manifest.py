#!/usr/bin/env python3
"""
Create a test manifest JSON file from input directory
This script scans the input directory and creates a manifest compatible with your baseline model
"""

import os
import json
import argparse
from pathlib import Path
import nibabel as nib


def create_manifest_entry(image_path, case_id):
    """Create a manifest entry for a single image file"""
    
    # Basic entry structure that matches your baseline expectation
    entry = {
        "image": str(image_path),
        "conversations": [
            {
                "from": "human", 
                "value": "Generate a comprehensive medical report for this CT scan, describing all visible anatomical structures and any abnormalities."
            },
            {
                "from": "gpt",
                "value": "Normal CT scan findings."  # Placeholder - will be generated
            }
        ],
        "case_id": case_id
    }
    
    return entry


def scan_input_directory(input_dir):
    """Scan input directory for medical image files"""
    
    supported_extensions = ['.nii.gz', '.nii', '.dcm']
    image_files = []
    
    input_path = Path(input_dir)
    
    for ext in supported_extensions:
        # Handle .nii.gz specially
        if ext == '.nii.gz':
            pattern = '*.nii.gz'
        else:
            pattern = f'*{ext}'
            
        files = list(input_path.glob(pattern))
        image_files.extend(files)
    
    # Remove duplicates and sort
    image_files = sorted(list(set(image_files)))
    
    print(f"Found {len(image_files)} medical image files")
    for f in image_files:
        print(f"  - {f.name}")
    
    return image_files


def validate_image_file(image_path):
    """Basic validation of image file"""
    try:
        if image_path.suffix.lower() in ['.nii', '.gz']:
            # Try to load NIfTI file
            img = nib.load(image_path)
            data = img.get_fdata()
            print(f"  ✓ {image_path.name}: Shape {data.shape}")
            return True
        else:
            # For other formats, just check if file exists and has reasonable size
            if image_path.exists() and image_path.stat().st_size > 1000:  # > 1KB
                print(f"  ✓ {image_path.name}: Size {image_path.stat().st_size} bytes")
                return True
    except Exception as e:
        print(f"  ✗ {image_path.name}: Validation failed - {e}")
        return False
    
    return False


def main():
    parser = argparse.ArgumentParser(description='Create test manifest from input directory')
    parser.add_argument('--input_dir', required=True, help='Input directory containing medical images')
    parser.add_argument('--output_manifest', required=True, help='Output manifest JSON file path')
    parser.add_argument('--validate', action='store_true', help='Validate image files')
    
    args = parser.parse_args()
    
    print(f"Scanning input directory: {args.input_dir}")
    
    # Scan for image files
    image_files = scan_input_directory(args.input_dir)
    
    if not image_files:
        print("Warning: No medical image files found!")
        print("Supported formats: .nii.gz, .nii, .dcm")
        
        # Create empty manifest
        manifest_data = []
    else:
        # Validate files if requested
        if args.validate:
            print("Validating image files...")
            validated_files = []
            for img_file in image_files:
                if validate_image_file(img_file):
                    validated_files.append(img_file)
            image_files = validated_files
        
        # Create manifest entries
        manifest_data = []
        for i, image_file in enumerate(image_files):
            case_id = f"test_case_{i:04d}"
            entry = create_manifest_entry(image_file, case_id)
            manifest_data.append(entry)
    
    # Save manifest
    print(f"Creating manifest with {len(manifest_data)} entries...")
    
    with open(args.output_manifest, 'w') as f:
        json.dump(manifest_data, f, indent=2, default=str)
    
    print(f"Manifest saved to: {args.output_manifest}")
    
    # Print summary
    print("\nManifest Summary:")
    print(f"  Total cases: {len(manifest_data)}")
    if manifest_data:
        print(f"  First case ID: {manifest_data[0]['case_id']}")
        print(f"  Last case ID: {manifest_data[-1]['case_id']}")


if __name__ == "__main__":
    main()