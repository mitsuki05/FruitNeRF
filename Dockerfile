# # ベースイメージ
# ARG UBUNTU_VERSION=22.04
# ARG NVIDIA_CUDA_VERSION=11.8.0
# # ビルド用ステージ
# FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS builder
# # 必要な環境変数
# ENV DEBIAN_FRONTEND=noninteractive
# ENV PATH="/usr/local/cuda-11.8/bin:${PATH}"
# ENV LD_LIBRARY_PATH="/usr/local/cuda-11.8/lib64:${LD_LIBRARY_PATH}"
# ARG CUDA_ARCHITECTURES="90;89;86;80;75;70;61"
# ENV TCNN_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
# # 必要なパッケージのインストール（Python 3.10をインストール）
# RUN apt-get update && apt-get install -y \
#     software-properties-common \
#     wget \
#     git \
#     cmake && \
#     add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get update && apt-get install -y \
#     python3.10 python3.10-venv python3-pip && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*
# # Pythonデフォルトの設定
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
#     update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
# # PyTorchのインストール
# RUN python3 -m pip install --no-cache-dir --upgrade pip && \
#     pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
# # ninjaとtiny-cuda-nnのインストール
# RUN pip install --no-cache-dir ninja && \
#     git clone --recursive https://github.com/nvlabs/tiny-cuda-nn && \
#     cd tiny-cuda-nn && \
#     cmake . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
#     cmake --build build --config RelWithDebInfo -j && \
#     cd bindings/torch && python setup.py install && \
#     cd ../../ && rm -rf tiny-cuda-nn
# # 最終ステージで軽量化されたイメージを作成
# FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}
# # 必要な環境変数
# ENV DEBIAN_FRONTEND=noninteractive
# ENV PATH="/usr/local/cuda-11.8/bin:${PATH}"
# ENV LD_LIBRARY_PATH="/usr/local/cuda-11.8/lib64:${LD_LIBRARY_PATH}"
# # 必要なパッケージのインストール
# RUN apt-get update && apt-get install -y \
#     python3.10 python3-pip git && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*
# # Pythonデフォルトの設定
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
#     update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
# # PyTorchとtiny-cuda-nnをコピー
# COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
# # FruitNeRF環境のセットアップ
# RUN python3 -m pip install --no-cache-dir nerfstudio==0.3.2 viser==0.1.24 tyro==0.8.12

# # # developブランチをクローンしてインストール
# # CMD git clone -b develop https://github.com/mitsuki05/FruitNeRF.git && \
# #     cd FruitNeRF && \
# #     python -m pip install -e . && \
# #     cd .. && rm -rf FruitNeRF && \
# #     apt-get update && \
# #     apt-get install -y libgl1 git && \
# #     /bin/bash

# RUN git clone https://github.com/meyerls/FruitNeRF.git && \
#     cd FruitNeRF && \
#     python -m pip install -e . && \
#      rm -rf FruitNeRF

# # # exportするために必要なパッケージのインストール
# # RUN apt-get update && apt-get install -y libgl1

# # デフォルトのコマンド
# CMD ["/bin/bash"]

# ベースイメージ
ARG UBUNTU_VERSION=22.04
ARG NVIDIA_CUDA_VERSION=11.8.0
# ビルド用ステージ
FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION} AS builder
# 必要な環境変数
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/cuda-11.8/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.8/lib64:${LD_LIBRARY_PATH}"
ARG CUDA_ARCHITECTURES="90;89;86;80;75;70;61"
ENV TCNN_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
# 必要なパッケージのインストール（Python 3.10をインストール）
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    cmake && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
# Pythonデフォルトの設定
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
# # PyTorchのインストール
# RUN python3 -m pip install --no-cache-dir --upgrade pip && \
#     pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# PyTorchのインストール（バージョン指定）
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu118

# ninjaとtiny-cuda-nnのインストール
RUN pip install --no-cache-dir ninja && \
    git clone --recursive https://github.com/nvlabs/tiny-cuda-nn && \
    cd tiny-cuda-nn && \
    cmake . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo && \
    cmake --build build --config RelWithDebInfo -j && \
    cd bindings/torch && python setup.py install && \
    cd ../../ && rm -rf tiny-cuda-nn

# 最終ステージで軽量化されたイメージを作成
FROM nvidia/cuda:${NVIDIA_CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}
# 必要な環境変数
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/cuda-11.8/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.8/lib64:${LD_LIBRARY_PATH}"
# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    python3.10 python3-pip git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
# Pythonデフォルトの設定
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1
# PyTorchとtiny-cuda-nnをコピー
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
# FruitNeRF環境のセットアップ
RUN python3 -m pip install --no-cache-dir nerfstudio==0.3.2 viser==0.1.24 tyro==0.8.12
# exportするために必要なパッケージのインストール
RUN apt-get update && apt-get install -y libgl1
# RUN git clone https://github.com/meyerls/FruitNeRF.git && \
#     cd FruitNeRF && \
#     python -m pip install -e . && \
#     rm -rf FruitNeRF
# # デフォルトのコマンド
# CMD ["/bin/bash"]

CMD git clone -b develop https://github.com/mitsuki05/FruitNeRF.git && \
    cd FruitNeRF && \
    python -m pip install -e . && \
    rm -rf FruitNeRF && \
    cd .. && \
    cd workspace && \
    /bin/bash