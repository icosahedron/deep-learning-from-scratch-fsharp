FROM jupyter/scipy-notebook:latest

# Run as root in the container for scipy-notebook for debugging purposes
# docker run -e GRANT_SUDO=yes -p 8888:8888 --user=root jupyter/scipy-notebook
# Recipe https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html?highlight=sudo#using-sudo-within-a-container

# Most of this is a mix from 
# Recipe taken from https://github.com/dotnet/dotnet-docker/blob/e19c1fbbc0b02bb87acb294bc4cb2480ca7e2cd4/src/sdk/5.0/focal/amd64/Dockerfile
# and https://github.com/shanselman/NightscoutDashboard/blob/master/Dockerfile which is outdated.

# Install .NET CLI dependencies

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

WORKDIR ${HOME}

USER root
RUN apt-get update
RUN apt-get install -y curl

# # Install .NET CLI dependencies
# RUN apt-get install -y --no-install-recommends \
#         libc6 \
#         libgcc1 \
#         libgssapi-krb5-2 \
#         libicu66 \
#         libssl1.1 \
#         libstdc++6 \
#         zlib1g 

ENV \
    # Do not generate certificate
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false \
    # SDK version
    DOTNET_SDK_VERSION=5.0.402 \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # PowerShell telemetry for docker image usage
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetSDK-Ubuntu-20.04

RUN apt-get install -y --no-install-recommends \
        curl \
        git \
        procps \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK 5.0.400
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && dotnet_sha512='6b2937ad1f026fd91d0c8e6101b0422a8d19ead022055021b55a722c34dcc3697b592592eacc6def8748981bd996bc2a511d7c3f05b0ae431c00ede0376deacc' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -oxzf dotnet.tar.gz \
    && rm dotnet.tar.gz

# COPY dotnet.tar.gz $HOME
# RUN dotnet_sha512='4d1a92e0885ade03de0fdb41c27cfd948ab749a2f3e686c4a9dee314888c19d76efa6f8663a7aa7eb56cf36f508638c1a1f01c845d1acb19d8662d6ae365d572' \
#     && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
#     && mkdir -p /usr/share/dotnet \
#     && tar -C /usr/share/dotnet -oxzf dotnet.tar.gz

# set the path to find the dotnet command
ENV PATH="$PATH:/usr/share/dotnet"

RUN dotnet help

# Install powershell here. Have to graft in the instructions from the Powershell Docker Github repo for Ubuntu 20.04 (https://github.com/PowerShell/PowerShell-Docker)
# This installs via the package manager, so not sure what the effect will be when SxS a manual dotnet installation
# RUN curl -SL --output powershell_7.1.4.deb https://github.com/PowerShell/PowerShell/releases/download/v7.1.4/powershell_7.1.4-1.ubuntu.20.04_amd64.deb
#     && dpkg -i powershell_7.1.4.deb
#     && apt-get install -f

# make sure that the directoru user ids match (1000 is the default user for WSL 2)
RUN chown -R ${NB_UID} ${HOME}

# switch back to the normal user for installing the tool(s)
USER ${USER}

# Recipe taken from https://github.com/dotnet/interactive/blob/main/docs/NotebookswithJupyter.md
RUN dotnet tool install -g --version 1.0.255305 --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive 
# RUN dotnet tool install --global Microsoft.dotnet-interactive --version 1.0.255305

# add the interactive tool to the path
ENV PATH="$PATH:/home/jovyan/.dotnet/tools"

# Install the kernels in Jupyter
RUN dotnet interactive jupyter install

# Enable telemetry once we install jupyter for the image
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Set root to notebooks
WORKDIR ${HOME}/notebooks/
