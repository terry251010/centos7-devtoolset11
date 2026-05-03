FROM centos:7

# 替换为Vault归档仓库
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum clean all && \
    yum makecache

# 手动创建SCL仓库配置文件
RUN echo '[centos-sclo-sclo]' > /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    echo 'name=CentOS-7 - SCLo scl' >> /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    echo 'baseurl=http://vault.centos.org/centos/7/sclo/x86_64/sclo/' >> /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    echo 'gpgcheck=0' >> /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    echo '' >> /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    echo '[centos-sclo-rh]' > /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    echo 'name=CentOS-7 - SCLo rh' >> /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    echo 'baseurl=http://vault.centos.org/centos/7/sclo/x86_64/rh/' >> /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    echo 'gpgcheck=0' >> /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    echo 'enabled=1' >> /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    yum clean all && \
    yum makecache

# 安装Devtoolset 11
RUN yum install -y devtoolset-11 git gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel curl-devel expat-devel \
                   texinfo wget gettext && \
    yum groupinstall "Development Tools" -y && \
    yum clean all

# 设置环境变量，永久启用Devtoolset 11
ENV PATH=/opt/rh/devtoolset-11/root/usr/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-11/root/usr/lib64:/opt/rh/devtoolset-11/root/usr/lib:$LD_LIBRARY_PATH
ENV CC=/opt/rh/devtoolset-11/root/usr/bin/gcc
ENV CXX=/opt/rh/devtoolset-11/root/usr/bin/g++

# 3. 下载、解压、编译并安装 Git
RUN wget https://github.com/git/git/archive/refs/tags/v2.39.0.tar.gz -O /tmp/git.tar.gz && \
    tar -xf /tmp/git.tar.gz -C /tmp && \
    cd /tmp/git-2.39.0 && \
    make configure && \
    ./configure --prefix=/usr/local && \
    make all && \
    make install && \
    rm -rf /tmp/*

# 步骤 4：下载、解压、配置、编译并安装 ncurses 静态库
RUN wget https://github.com/mirror/ncurses/archive/refs/tags/v6.4.tar.gz -O /tmp/ncurse.tar.gz && \
    tar -xf /tmp/ncurse.tar.gz -C /tmp && \
    cd /tmp/ncurses-6.4 && \
    ./configure \
        --prefix=/usr/local \
        --without-shared \
        --with-normal \
        --enable-widec \
        --with-termlib && \
    make -j$(nproc) && \
    make install && \
    # 清理源码文件以减小镜像体积
    rm -rf /tmp/*   

# 验证安装
RUN gcc --version && g++ --version && git --version

# 设置工作目录
WORKDIR /app

# 默认命令
CMD ["/bin/bash"]