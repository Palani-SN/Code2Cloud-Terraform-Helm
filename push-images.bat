@echo off
SETLOCAL EnableDelayedExpansion
:: Variables
set PROJECT_ID=<some_project>
set REGION=us-central1
set REPO_NAME=c2c-artifacts
set TAG=latest

:: Authenticate Docker with Artifact Registry
echo Authenticating Docker with Artifact Registry...
cmd /c gcloud auth configure-docker %REGION%-docker.pkg.dev

:: Get a list of services from docker-compose.yml
for /f "tokens=*" %%S in ('docker-compose config --services') do (
    @REM echo %%S 
    set SERVICE=%%S
    set LOCAL_IMAGE=%REPO_NAME%-%%S:%TAG%
    set ARTIFACT_IMAGE=%REGION%-docker.pkg.dev/%PROJECT_ID%/%REPO_NAME%/%%S:%TAG%

    :: Tag the local image for Artifact Registry
    echo Tagging !LOCAL_IMAGE! as !ARTIFACT_IMAGE!...
    docker tag !LOCAL_IMAGE! !ARTIFACT_IMAGE!

    :: Push the tagged image to Artifact Registry
    echo Pushing !ARTIFACT_IMAGE! to Artifact Registry...
    docker push !ARTIFACT_IMAGE!
)

echo All images have been pushed successfully!
