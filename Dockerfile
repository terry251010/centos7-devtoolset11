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
                   texinfo wget gettext vim cmake ninja-build rh-python38 ncurses ncurses-devel && \
    yum groupinstall "Development Tools" -y && \
    yum clean all

# 设置环境变量，永久启用Devtoolset 11
ENV PATH=/opt/rh/devtoolset-11/root/usr/bin:/opt/rh/rh-python38/root/bin:$PATH
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
    
RUN wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.bz2 -O /tmp/gmp.tar.gz && \
    tar -xf /tmp/gmp.tar.gz -C /tmp && \
    cd /tmp/gmp-6.2.1/ && \
    ./configure --prefix=/usr/local --enable-static --disable-shared && \
    make -j$(nproc) && \
    make install && \
    # 清理源码文件以减小镜像体积
    rm -rf /tmp/*
    
RUN wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.bz2 -O /tmp/mpfr.tar.gz && \
    tar -xf /tmp/mpfr.tar.gz -C /tmp && \
    cd /tmp/mpfr-4.1.0 && \
    ./configure --prefix=/usr/local --with-gmp=/usr/local --enable-static --disable-shared && \
    make -j$(nproc) && \
    make install && \
    # 清理源码文件以减小镜像体积
    rm -rf /tmp/*

RUN wget https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz -O /tmp/mpc.tar.gz && \
    tar -xf /tmp/mpc.tar.gz -C /tmp && \
    cd /tmp/mpc-1.2.1 && \
    ./configure --prefix=/usr/local --with-gmp=/usr/local --with-mpfr=/usr/local --enable-static --disable-shared && \
    make -j$(nproc) && \
    make install && \
    # 清理源码文件以减小镜像体积
    rm -rf /tmp/* 
    
RUN wget https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.24.tar.bz2 -O /tmp/isl.tar.gz && \
    tar -xf /tmp/isl.tar.gz -C /tmp && \
    cd /tmp/isl-0.24 && \
    ./configure --prefix=/usr/local --with-gmp=/usr/local --enable-static --disable-shared && \
    make -j$(nproc) && \
    make install && \
    # 清理源码文件以减小镜像体积
    rm -rf /tmp/*     
    
RUN wget https://github.com/Kitware/CMake/archive/refs/tags/v3.31.0.tar.gz -O /tmp/cmake.tar.gz && \
    tar -xf /tmp/cmake.tar.gz -C /tmp && \
    cd /tmp/CMake-3.31.0/ && \
    ./bootstrap --prefix=/usr/local --parallel=10 && \
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