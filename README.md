# uLogger Upload Action - Example Repository

This repository demonstrates how to use the [ulogger_upload](https://github.com/ulogger-ai/ulogger_upload) GitHub Action to automatically upload firmware files to the uLogger platform as part of your CI/CD pipeline.

## Overview

The uLogger Upload Action enables automated firmware uploads to uLogger, making it easy to:
- Track firmware versions across builds
- Link firmware to git commits and branches
- Automate uploads as part of your build pipeline
- Manage firmware deployment through GitHub Actions

This example shows a complete working implementation that you can adapt for your own projects.

## Quick Start

### Prerequisites

Before using this action, you need:
1. A uLogger account with API access
2. MQTT certificates for authentication (obtain from uLogger platform)
3. Your Customer ID, Application ID, and Device Type from uLogger

### 1. Fork or Clone This Repository

Start by creating your own copy:

```bash
git clone https://github.com/ulogger-ai/example_upload.git
cd example_upload
```

### 2. Configure GitHub Secrets

To keep your credentials secure, store them as GitHub repository secrets:

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add each of the following:

#### Required Secrets

| Secret Name | Description | Example Value |
|------------|-------------|---------------|
| `ULOGGER_CUSTOMER_ID` | Your uLogger customer ID | `12345` |
| `ULOGGER_APPLICATION_ID` | Your uLogger application ID | `67890` |
| `ULOGGER_DEVICE_TYPE` | Device type identifier | `"my-device-v1"` |
| `ULOGGER_CERT_DATA` | MQTT client certificate (PEM format) | See format below |
| `ULOGGER_KEY_DATA` | MQTT private key (PEM format) | See format below |

#### Certificate Format

Copy your certificate and key files **exactly as-is**, including the BEGIN/END markers:

**Certificate Example:**
```
-----BEGIN CERTIFICATE-----
MIIDdzCCAl+gAwIBAgIEAgAAuTANBgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJJ
E4xVj5cGsgCBImkNEyBJmNNJ22ACbhh0w1IhFghFu6S7x8kPX3HHkCGLHkNDLdda
...
-----END CERTIFICATE-----
```

**Private Key Example:**
```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7VJTUt9Us8cKj
MzEfYyjiWA4R4/M2bS1+fWIcnXe7W8jH0T3BhLvmQkW3+KqBKJo4T3J3Y8N8...
...
-----END PRIVATE KEY-----
```

> **Security Note:** Never commit certificates or keys to your repository. Always use GitHub Secrets or another secure secret management solution.

### 3. Add Your Firmware File

This repository includes a sample AXF file for testing. To use your own firmware:

**Option A - Use Sample for Testing:**
```bash
# The repository includes sample_firmware.axf - no changes needed
```

**Option B - Integrate with Your Build Process:**
Edit `.github/workflows/build-and-upload.yml` to run your actual build commands instead of copying the sample file.

### 4. Test the Workflow

The workflow automatically triggers on:
- **Push** to `main` or `develop` branches
- **Pull requests** to `main`
- **Manual trigger** via the Actions tab

#### Run Your First Upload

1. Navigate to the **Actions** tab in your GitHub repository
2. Select the "Build and Upload Firmware" workflow
3. Click **Run workflow**
4. Select the branch (e.g., `main`)
5. Click the green **Run workflow** button

The workflow will execute and upload the firmware to uLogger!

## Repository Structure

```
example_upload/
├── .github/
│   └── workflows/
│       └── build-and-upload.yml    # GitHub Actions workflow
├── sample_firmware.axf              # Sample AXF file for testing
├── CONFIG.md                        # Configuration notes
├── README.md                        # This file
└── .gitignore                       # Ensures secrets are never committed
```

## How It Works

### Workflow Overview

The GitHub Actions workflow (`.github/workflows/build-and-upload.yml`) automates the entire process:

1. **Checkout Code** - Retrieves your repository code
2. **Set Up Environment** - Creates build directory
3. **Build Firmware** - Runs your build process (or copies sample file)
4. **Extract Version** - Determines version from git tags or generates development version
5. **Upload to uLogger** - Calls the `ulogger_upload` action with your firmware
6. **Store Artifacts** - Saves firmware as GitHub artifact for download

### Key Workflow Features

#### Automatic Versioning
```yaml
# Extracts version from git tags (e.g., v1.0.0 → 1.0.0)
# Falls back to dev version: 0.0.0-dev-abc1234
if [[ "${{ github.ref }}" == refs/tags/* ]]; then
  VERSION="${GITHUB_REF#refs/tags/v}"
else
  VERSION="0.0.0-dev-$(git rev-parse --short HEAD)"
fi
```

#### uLogger Upload Step
```yaml
- name: Upload firmware to uLogger
  uses: ulogger-ai/ulogger_upload@v1
  with:
    customer_id: ${{ secrets.ULOGGER_CUSTOMER_ID }}
    application_id: ${{ secrets.ULOGGER_APPLICATION_ID }}
    device_type: ${{ secrets.ULOGGER_DEVICE_TYPE }}
    version: ${{ steps.version.outputs.VERSION }}
    git_hash: ${{ github.sha }}
    branch: ${{ github.ref_name }}
    file: 'build/firmware.axf'
    cert_data: ${{ secrets.ULOGGER_CERT_DATA }}
    key_data: ${{ secrets.ULOGGER_KEY_DATA }}
    timeout: '60'
```

## Adapting for Your Project

### Option 1: Replace the Build Step

Edit `.github/workflows/build-and-upload.yml` to run your actual build commands:

```yaml
- name: Build firmware
  run: |
    # Replace this with your actual build commands
    make clean
    make all
    # Ensure output is at build/firmware.axf
    cp output/my_firmware.axf build/firmware.axf
```

### Option 2: Use Your Build System

If you have existing build scripts:

```yaml
- name: Build firmware
  run: |
    chmod +x build.sh
    ./build.sh
    # Ensure output is at build/firmware.axf
```

### Option 3: Integrate with Existing CI

Add the upload step to your existing workflow:

```yaml
- name: Upload firmware to uLogger
  uses: ulogger-ai/ulogger_upload@v1
  with:
    customer_id: ${{ secrets.ULOGGER_CUSTOMER_ID }}
    application_id: ${{ secrets.ULOGGER_APPLICATION_ID }}
    device_type: ${{ secrets.ULOGGER_DEVICE_TYPE }}
    version: ${{ env.MY_VERSION }}
    git_hash: ${{ github.sha }}
    branch: ${{ github.ref_name }}
    file: 'path/to/your/firmware.axf'
    cert_data: ${{ secrets.ULOGGER_CERT_DATA }}
    key_data: ${{ secrets.ULOGGER_KEY_DATA }}
```

## Testing Different Scenarios

### Scenario 1: Version Tagging

Test semantic versioning with git tags:

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

The workflow will extract `1.0.0` as the version and upload to uLogger.

### Scenario 2: Development Builds

Push to any branch without tags:

```bash
git checkout -b feature/new-sensor
git push origin feature/new-sensor
```

The workflow generates a development version like `0.0.0-dev-abc1234` using the git commit hash.

### Scenario 3: Pull Request Testing

Create a pull request to test the workflow before merging:

```bash
git checkout -b test-ulogger-integration
# Make changes
git commit -am "Test uLogger integration"
git push origin test-ulogger-integration
# Create PR on GitHub
```

### Scenario 4: Manual Deployment

Trigger uploads on-demand:
1. Go to **Actions** tab
2. Select "Build and Upload Firmware"
3. Click **Run workflow**
4. Choose branch and click **Run workflow**

## Verifying Your Upload

### Monitor Workflow Execution

1. Navigate to the **Actions** tab in your GitHub repository
2. Click on the running or completed workflow
3. View the job details and expand steps to see logs
4. Look for the "Upload firmware to uLogger" step

**Success indicators:**
- ✅ Green checkmark on the workflow run
- Log message: "Successfully uploaded firmware to uLogger"
- Artifact uploaded to GitHub (available for 30 days)

### Verify in uLogger Platform

After a successful upload, check the uLogger platform:

1. Log into your uLogger dashboard
2. Navigate to your application
3. Check the Build Analyzer - your new version should appear
4. Verify the metadata:
   - **Version**: Should match your git tag or dev version
   - **Git Hash**: Should match the commit SHA
   - **Branch**: Should show the source branch name
   - **Upload Time**: Should be recent

## Troubleshooting

### Common Issues and Solutions

#### ❌ Authentication Errors

**Error:** MQTT authentication failed

**Solutions:**
- Verify all secrets are correctly configured in **Settings** → **Secrets and variables** → **Actions**
- Check that certificate and key include the `-----BEGIN...-----` and `-----END...-----` markers
- Ensure certificates haven't expired (check expiration date)
- Verify Customer ID and Application ID are correct (should be numbers, not strings)
- Make sure there are no extra spaces or newlines in the secret values

#### ❌ File Not Found

**Error:** Cannot find firmware file

**Solutions:**
- Confirm `sample_firmware.axf` exists in the repository root
- Check the build step completed successfully (review logs)
- Verify the file path in the workflow matches your build output location
- Ensure the build step creates the `build/` directory

#### ❌ Timeout Errors

**Error:** Upload timeout after 60 seconds

**Solutions:**
- Increase the `timeout` parameter in the workflow:
  ```yaml
  timeout: '120'  # Increase to 120 seconds
  ```
- Check that GitHub Actions runners can access the internet
- Verify the uLogger MQTT broker is accessible (check status page)
- Try the upload again - temporary network issues may resolve

#### ❌ Version Format Errors

**Error:** Invalid version format

**Solutions:**
- Ensure version follows semantic versioning (e.g., `1.0.0`, `2.1.3`)
- Check that git tags are formatted as `v1.0.0` (with 'v' prefix)
- Verify the version extraction logic in the workflow

#### ❌ Workflow Not Triggering

**Problem:** Workflow doesn't run on push

**Solutions:**
- Check that you pushed to `main` or `develop` branch
- Verify the workflow file is in `.github/workflows/` directory
- Ensure the YAML syntax is valid
- Check repository **Actions** settings - workflows may be disabled

## Action Parameters Reference

Complete list of available parameters for the `ulogger_upload` action:

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `customer_id` | ✅ Yes | Your uLogger customer ID | `12345` |
| `application_id` | ✅ Yes | Your uLogger application ID | `67890` |
| `device_type` | ✅ Yes | Device type identifier | `my-device-v1` |
| `version` | ✅ Yes | Firmware version string | `1.0.0` |
| `file` | ✅ Yes | Path to AXF firmware file | `build/firmware.axf` |
| `cert_data` | ✅ Yes | MQTT certificate (PEM format) | From secrets |
| `key_data` | ✅ Yes | MQTT private key (PEM format) | From secrets |
| `git_hash` | ⚪ No | Git commit SHA | `${{ github.sha }}` |
| `branch` | ⚪ No | Git branch name | `${{ github.ref_name }}` |
| `timeout` | ⚪ No | Upload timeout in seconds | `60` |

## Security Best Practices

✅ **DO:**
- Store all credentials in GitHub Secrets
- Use the `.gitignore` to exclude certificate files
- Rotate certificates periodically
- Limit repository access to trusted team members
- Use separate certificates for different environments
- Review workflow logs for sensitive data before sharing

❌ **DON'T:**
- Commit certificates or keys to the repository
- Share secret values in issue comments or PRs
- Use production certificates in public repositories
- Include secrets in workflow files directly
- Log or echo secret values in build scripts

## Advanced Configuration

### Multiple Environments

Create separate workflows for different environments:

```yaml
# .github/workflows/upload-production.yml
on:
  push:
    tags: ['v*']

# Use production secrets
with:
  customer_id: ${{ secrets.PROD_ULOGGER_CUSTOMER_ID }}
  cert_data: ${{ secrets.PROD_ULOGGER_CERT_DATA }}
```

```yaml
# .github/workflows/upload-staging.yml
on:
  push:
    branches: ['develop']

# Use staging secrets
with:
  customer_id: ${{ secrets.STAGING_ULOGGER_CUSTOMER_ID }}
  cert_data: ${{ secrets.STAGING_ULOGGER_CERT_DATA }}
```

### Custom Version Schemes

Modify the version extraction logic:

```yaml
# Use package.json version
VERSION=$(jq -r .version package.json)

# Use build date
VERSION="1.0.0-$(date +%Y%m%d)"

# Use branch and commit
VERSION="${GITHUB_REF_NAME}-$(git rev-parse --short HEAD)"
```

### Conditional Uploads

Only upload on specific conditions:

```yaml
- name: Upload firmware to uLogger
  if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/')
  uses: ulogger-ai/ulogger_upload@v1
```

## Next Steps

### For Testing
- ✅ Configure your GitHub Secrets
- ✅ Run the workflow manually to verify setup
- ✅ Check the uLogger platform for your uploaded firmware
- ✅ Test with different branches and tags

### For Production Use
- 🔧 Replace sample firmware with your actual build process
- 🔧 Customize version numbering strategy
- 🔧 Add code quality checks and tests before upload
- 🔧 Configure branch protection rules
- 🔧 Set up notifications for failed uploads

## Resources

### Documentation
- [uLogger Upload Action Repository](https://github.com/ulogger-ai/ulogger_upload)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

### Support
- **Action Issues**: [GitHub Issues](https://github.com/ulogger-ai/ulogger_upload/issues)
- **uLogger Support**: support@ulogger.ai
- **Documentation**: https://docs.ulogger.ai

## Contributing

Found an issue or want to improve this example? Contributions are welcome!
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This example repository is provided as-is for demonstration purposes.
