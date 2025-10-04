import torch
from monai.networks.nets import UNet
from monai.networks.layers import Norm

def create_model():
    """
    Creates a 3D U-Net model for aneurysm detection.
    """
    # Define the model parameters
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    model = UNet(
        spatial_dims=3,
        in_channels=1,
        out_channels=2,  # for binary classification (aneurysm vs. background)
        channels=(16, 32, 64, 128, 256),
        strides=(2, 2, 2, 2),
        num_res_units=2,
        norm=Norm.BATCH,
    ).to(device)

    return model

if __name__ == '__main__':
    # Example of how to create the model
    model = create_model()
    print("Model created successfully:")
    print(model)

    # Example of a forward pass with a dummy input
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    dummy_input = torch.randn(1, 1, 128, 128, 128).to(device)
    output = model(dummy_input)
    print(f"\nOutput shape: {output.shape}")