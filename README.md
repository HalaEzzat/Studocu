# StuDocu CI/CD Engineer Take-Home Assignment

## Table of Contents

- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Tech Stack & Tools](#tech-stack--tools)
- [Pipeline: Step-by-Step](#pipeline-step-by-step)
- [Development Environment (Nix)](#development-environment-nix)
- [How to Use](#how-to-use)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Set Up the Development Environment](#2-set-up-the-development-environment)
  - [3. Build & Run Locally](#3-build--run-locally)
  - [4. Build & Run Container Locally](#4-build--run-container-locally)
  - [5. Automated Pipeline & CI/CD](#5-automated-pipeline--cicd)
- [Design Decisions & Rationale](#design-decisions--rationale)
- [Authentication & Secrets](#authentication--secrets)
- [Troubleshooting](#troubleshooting)
- [Contributors](#contributors)

---

## Project Overview

This repository demonstrates a robust, automated, and reproducible CI/CD pipeline for a simple TypeScript HTTP server. The solution transpiles TypeScript to ES5 JavaScript, builds a container image **programmatically** (no Dockerfile), and automates deployment to [GitHub Container Registry (GHCR)](https://ghcr.io) using GitHub Actions. It ensures reproducibility across machines via [Nix](https://nixos.org/) and provides clear, actionable documentation.

---

## Repository Structure

```plaintext
.
├── .github/
│   └── workflows/
│       └── main.yml           # GitHub Actions pipeline
├── dist/                    # Transpiled JavaScript (generated)
├── scripts/
│   └── pipeline.py          # Main build, transpile, containerize, and push script
├── src/
│   └── server.ts            # TypeScript HTTP server source
├── .env.example             # Example environment variables
├── flake.nix                # Nix-based development environment
├── package.json             # Node.js project definition
├── package-lock.json        # Node.js lockfile (for `npm ci`)
├── README.md                # This documentation
├── requirements.txt         # Python dependencies (for Dagger)
└── tsconfig.json            # TypeScript compiler configuration
```

---

## Tech Stack & Tools

- **TypeScript**: Strongly-typed HTTP server in `src/server.ts`
- **Node.js & npm**: JavaScript runtime and dependency manager
- **TypeScript Compiler (`tsc`)**: Transpiles TS to ES5
- **[@types/node](https://www.npmjs.com/package/@types/node)**: Node.js type definitions for TypeScript
- **Python 3.11+**: For scripting the pipeline
- **[Dagger](https://dagger.io/)**: Programmatic, Dockerfile-free container builds/push (via Python SDK)
- **GitHub Actions**: CI/CD pipeline automation
- **GHCR**: Container registry for image storage and deployment
- **Nix**: Declarative, reproducible development environment

---

## Pipeline: Step-by-Step

1. **Install Dependencies**  
   Uses `npm ci` for deterministic Node.js package installation (requires `package-lock.json`).

2. **Transpile TypeScript**  
   Converts `src/server.ts` to ES5 JavaScript in `dist/` using `tsc`.

3. **Containerize**  
   Uses Dagger (Python) to:
   - Build a minimal Node.js container image.
   - Copy only required files, install prod dependencies, add compiled output.
   - Set correct entrypoint (`node dist/server.js`), no Dockerfile needed.

4. **Push to GHCR**  
   Authenticates and pushes the image to `ghcr.io/halaezzat/studocu:latest`.

5. **CI/CD Integration**  
   The above is automated in `.github/workflows/main.yml` on every push to `main`.

---

## Development Environment (Nix)

[Nix](https://nixos.org/) ensures all contributors have the same versions of Node.js, Python, and dependencies.  
To enter the dev environment, run:

```bash
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
```

This provides:
- Node.js 22
- Python 3.11
- Pip & Dagger
- All Node.js and Python dependencies auto-installed

---

## How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/halaezzat/Studocu.git
cd Studocu
```

### 2. Set Up the Development Environment

**With Nix (Recommended):**
```bash
nix develop
```

**Without Nix (Manual):**
```bash
npm ci
pip install -r requirements.txt
```

### 3. Build & Run Locally

#### Transpile TypeScript

```bash
npm run build
```

#### Start the Server

```bash
npm start
```
This runs the server on [localhost:8080](http://localhost:8080).

### 4. Build & Run Container Locally

#### Build & Push Image (with Dagger)

```bash
# Set environment variables
export IMAGE_REPO=ghcr.io/halaezzat/studocu
export IMAGE_TAG=latest

# Run the pipeline
python scripts/pipeline.py
```

#### Run Container

```bash
docker run -p 8080:8080 ghcr.io/halaezzat/studocu:latest
```
Visit [localhost:8080](http://localhost:8080) in your browser.

### 5. Automated Pipeline & CI/CD

On push to `main`, GitHub Actions will:
- Install dependencies
- Transpile TypeScript
- Build and push container image to GHCR

**Workflow file:** `.github/workflows/main.yml`

---

## Design Decisions & Rationale

- **TypeScript + Node.js:** Standard, well-supported ecosystem for HTTP servers.
- **`tsc` for Transpilation:** Ensures strict typing and ES5 compatibility.
- **Dagger for Containerization:** Programmatic builds, no Dockerfile needed, portable and repeatable.
- **GitHub Actions:** Seamless CI/CD integration with GHCR support.
- **Nix:** Eliminates "works on my machine" issues, fast onboarding, true reproducibility.

---

## Authentication & Secrets

- **GHCR Authentication:**  
  - In main, uses `${{ secrets.GHCR_PAT }}` for push access.
  - Locally, create a Personal Access Token with `write:packages` scope and login with:
    ```bash
    echo <YOUR_TOKEN> | docker login ghcr.io -u <your-username> --password-stdin
    ```
- **Environment Variables:**  
  - Copy `.env.example` to `.env` and fill in required values if running locally.

---

## Troubleshooting

**Q: `npm ci` fails, missing lockfile**  
A: Run `npm install` to generate `package-lock.json`, commit it, and try again.

**Q: TypeScript "Cannot find module 'http'"**  
A: Install Node.js types:  
```bash
npm install --save-dev @types/node
```

**Q: Dagger/Python errors**  
A: Ensure you’re in the Nix shell or have installed dependencies from `requirements.txt`.


---

## Contributors

- [HalaEzzat](https://github.com/HalaEzzat)  
- [alirezamirsepassi](https://github.com/alirezamirsepassi) (collaborator)
- [samuelnorbury](https://github.com/samuelnorbury) (collaborator)


---

## License

This project is for technical assessment purposes only.  
Contact [hala.elhamahmy@gmail.com] for questions or clarifications.
