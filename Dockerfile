FROM centos:7

# 替换为Vault归档仓库（CentOS 7已EOL）
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum clean all && \
    yum makecache

# 安装SCL仓库（使用归档源）
RUN yum install -y centos-release-scl && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    yum clean all && \
    yum makecache

# 安装Devtoolset 11
RUN yum install -y devtoolset-11 && \
    yum clean all

RUN echo "source /opt/rh/devtoolset-11/enable" >>/etc/profile

# 验证安装
RUN gcc --version && g++ --version

# 设置工作目录
WORKDIR /app

# 默认命令
CMD ["/bin/bash"]