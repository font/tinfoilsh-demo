# Demo
## Background
Some info for background.

### modelpack
- This is to create an immutable disk image from hugginfface model weights.
- Specifically, it builds reproducible dm-verity EROFS images of Hugging Face models.

### dm-verity
DM-Verity, or device-mapper verity, is a Linux kernel feature that provides
integrity checking for block devices, like partitions on a disk. It ensures
that data read from these devices hasn't been tampered with, which is crucial
for maintaining system security and preventing unauthorized modifications.
Essentially, it verifies the data on a disk against a cryptographic hash,
preventing unauthorized changes to the system, especially useful in read-only
file systems. 

While dm-verity focuses on verifying data integrity, EROFS focuses on efficient
storage and access of read-only data. 

### tinfoil-config.yml

The “tinfoil config file” is always called tinfoil-config.yml and placed at the
root of a deployment repo. The private image builder action parses this file to
create an attested deployment config and includes the SHA256 hash of the entire
file as a kernel command line parameter to provide a cryptographic link to the
running enclave.

## Setup
```bash
export HF_TOKEN=<token_value>
```

## Demo Steps

```bash
# Immutable disk image
vi Makefile
make pack meta-llama/Llama-3.2-1B
# See notes above
vi tinfoil-config.yml
git tag v0.2
git push origin v0.2
```

#### Show
- Show GitHub Actions https://github.com/font/tinfoilsh-demo/actions
- Show [tinfoil cmvimage binaries](https://github.com/tinfoilsh/cvmimage/releases)

### Lifecycle
To run a model on Tinfoil, we first build the model into a deployment
configuration, deploy it on our infrastructure, then verify it’s integrity on
the client device.

### CPU-GPU Chain of Trust
Once the CVM verifies the integrity of the disks, it in turn queries the GPU to
ensure it’s also configured correctly by NVIDIA. This creates a link between
the CPU and GPU attestations. If the CPU fails to verify the GPU’s attestation,
it aborts the boot process and returns an error.

### Verifier
- Web verifier https://tinfoil.sh/verifier (JS) also standalone app (Go)
    - Shows GitHub repository path
    - URL of the enclave hostname

#### 3 step verification process
1. Enclave Runtime Check
    - Verify the enclave is running in secure hardware by validating
      attestations from AMD or NVIDIA
2. Code Integrity Check
    - Verify the source code was built correctly by checking GitHub Actions and
      Sigstore signatures
3. Binary Consistency Check
    - Ensure the code running in the enclave matches the published open-source
      code

- Key elements
    - Source: The measurement from GitHub’s build process
    - Enclave: The measurement from the running enclave
    - Certificate fingerprint: The TLS certificate bound to the enclave
    - Matching measurements: Source and Enclave values are identical

### SDK
- [tinfoil sdk](https://docs.tinfoil.sh/sdk/overview)
- Drop-in replacements for OpenAI clients with built-in security verification.
  Many language options and start building with confidential AI in minutes.

# Cleanup
## Delete github release v0.2
```bash
git tag -d v0.2
git push --delete origin v0.2
gh release delete v0.2
```
- Refresh verifier web app
