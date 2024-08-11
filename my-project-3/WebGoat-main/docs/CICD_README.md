# CI/CD Pipeline for WebGoat

This repository contains the CI/CD pipeline configuration for the WebGoat project. The pipeline is designed to automate the build, security scanning, and deployment processes using GitHub Actions.

## Pipeline Overview

The CI/CD pipeline is triggered by the following events:
- Push to the `main` branch
- Pull request to the `main` branch
- Approval of a pull request

### Jobs

1. **Build**
   - Checks out the code
   - Sets up JDK 17
   - Builds the project using Maven

2. **Security Scans**
   - **Static Application Security Testing (SAST)**: Uses CodeQL to analyze the source code for security vulnerabilities.
   - **Dependency Checking**: Uses OWASP Dependency-Check to scan for vulnerable dependencies.
   - **Password Scanning**: Uses Gitleaks to check for hardcoded passwords and sensitive information.
   - **Container Scanning**: Uses Trivy to scan Docker images for known vulnerabilities.

3. **Deploy**
   - Deploys the front-end and back-end to the specified servers using SSH.

## Configuration

### Secrets

The following secrets must be configured in the GitHub repository settings:

- `FRONTEND_SSH_USER`: SSH user for the front-end server
- `FRONTEND_SSH_HOST`: SSH host for the front-end server
- `BACKEND_SSH_USER`: SSH user for the back-end server
- `BACKEND_SSH_HOST`: SSH host for the back-end server

### Scripts

The deployment scripts should be located in the `scripts` directory:

- `scripts/deploy_frontend.sh`: Script to deploy the front-end
- `scripts/deploy_backend.sh`: Script to deploy the back-end

## Usage

To trigger the pipeline, push changes to the `main` branch, create a pull request to the `main` branch, or approve a pull request. The pipeline will automatically run the build, security scans, and deployment jobs.

## Scan Report Management

The CI/CD pipeline generates detailed scan reports for each security scanning process. These reports are stored in a designated directory within the application source code repository and are uploaded as artifacts in the GitHub Actions workflow.

### Accessing Scan Reports

1. Navigate to the Actions tab in your GitHub repository.
2. Select the workflow run you are interested in.
3. Scroll down to the "Artifacts" section.
4. Download the `scan-reports` artifact to access the detailed scan reports.

### Tools Used

- **GitHub Actions**: For CI/CD automation
- **Maven**: For building the project
- **CodeQL**: For static application security testing
- **OWASP Dependency-Check**: For dependency checking
- **Gitleaks**: For password scanning
- **Trivy**: For container scanning

## License

This project is licensed under the MIT License. See the LICENSE file for details.