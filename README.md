# scratch-linux-container

🛠️ A minimal Linux container built entirely **from scratch**, using `FROM scratch` in Docker/Podman and statically compiled tools like `bash` and `coreutils` using `musl`.

This project is designed to demonstrate:

- How to build a fully custom Linux userspace
- Static compilation of essential tools
- Container creation without relying on a base image
- The internal structure of Linux root filesystems

> 📚 This container is for **educational purposes only**. It is not intended for production use.

## 🧱 Project Structure

```text
scratch-linux-container/
├── .gitignore         # Ignore build artifacts
├── Dockerfile         # Defines scratch-based image
├── LICENSE            # MIT License
├── README.md          # This file
├── build.sh           # Build script (downloads, compiles, assembles rootfs)
```
## How to run the dev environment.

### Start the local dev container for the build

```text
podman run -it --rm --name ubuntu1 -v .:/root/scratch-linux -w /root/scratch-linux ubuntu
```
and then

> $ ./build.sh