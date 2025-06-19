import os
import sys
import subprocess
import dagger
import asyncio

REPO = os.getenv("IMAGE_REPO", "ghcr.io/halaezzat/Studocu").lower()
TAG = os.getenv("IMAGE_TAG", "latest").lower()

def install_node_dependencies():
    subprocess.run(["npm", "ci"], check=True)

def transpile_typescript():
    subprocess.run(["npx", "tsc"], check=True)

async def build_and_push_container():
    # Dagger client context
    async with dagger.Connection() as client:
        src = client.host().directory(".", exclude=["node_modules", "dist"])
        node = (
            client.container()
            .from_("node:22-alpine")
            .with_directory("/app", src)
            .with_workdir("/app")
            .with_exec(["npm", "ci"])
            .with_exec(["npm", "run", "build"])
            .with_entrypoint(["node", "dist/server.js"])
        )

        # Build and push image
        image_ref = f"{REPO}:{TAG}"
        await node.publish(image_ref)
        print(f"Pushed image: {image_ref}")

def main():
    install_node_dependencies()
    transpile_typescript()
    asyncio.run(build_and_push_container())

if __name__ == "__main__":
    main()