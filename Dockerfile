FROM ubuntu:20.04 as base

# Set shell to bash with pipefail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install jflex and clean up
RUN apt-get --yes update && \
    apt-get install --yes --no-install-recommends sudo  jflex && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install java jdk 13.0.2
RUN mkdir -p /tmp/debs
# Copy the .deb package from the host to the image
COPY jdk-13.0.2_linux-x64_bin.deb /tmp/debs/
# Install the .deb package
RUN sudo dpkg -i /tmp/debs/jdk-13.0.2_linux-x64_bin.deb
# Clean up by deleting the .deb package
RUN rm /tmp/debs/jdk-13.0.2_linux-x64_bin.deb
# Set java installation path
RUN sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-13.0.2/bin/java 1 && \
    sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-13.0.2/bin/javac 1 && \
    sudo update-alternatives --set java /usr/lib/jvm/jdk-13.0.2/bin/java

ARG USERNAME="jflex"
ARG USER_HOME="/home/${USERNAME}"
ARG WORKDIR="${USER_HOME}/workdir"

# Create and set user
RUN useradd --create-home --home-dir "${USER_HOME}" --shell=/bin/bash --user-group "${USERNAME}" --groups sudo && \
    mkdir -p "${WORKDIR}" && \
    chown "${USERNAME}:${USERNAME}" "${WORKDIR}" && \
    echo "${USERNAME}:jflex" | chpasswd
USER ${USERNAME}

# Set working directory
WORKDIR ${USER_HOME}

# Set default container executable
CMD ["/bin/bash"]