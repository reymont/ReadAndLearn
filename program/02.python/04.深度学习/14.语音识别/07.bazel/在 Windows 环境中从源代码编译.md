在 Windows 环境中从源代码编译  |  TensorFlow https://tensorflow.google.cn/install/source_windows

我们将从源代码编译 TensorFlow pip 软件包并将其安装在 Windows 设备上。

注意：我们已经针对 Windows 系统提供了经过精密测试的预编译 TensorFlow 软件包。
Windows 设置
安装以下编译工具以配置 Windows 开发环境。

## 安装 Python 和 TensorFlow 软件包依赖项
安装适用于 Windows 的 Python 3.5.x 或 Python 3.6.x 64 位版本。选择 pip 作为可选功能，并将其添加到 %PATH% 环境变量中。

## 安装 TensorFlow pip 软件包依赖项：

    pip3 install six numpy wheel
    pip3 install keras_applications==1.0.6 --no-deps
    pip3 install keras_preprocessing==1.0.5 --no-deps
    

这些依赖项列在 setup.py 文件中的 REQUIRED_PACKAGES 下。

## 安装 Bazel
安装 Bazel，它是用于编译 TensorFlow 的编译工具。设置 Bazel 来编译 C++。

将 Bazel 可执行文件的位置添加到 %PATH% 环境变量中。

## 安装 MSYS2
为编译 TensorFlow 所需的 bin 工具安装 MSYS2。如果 MSYS2 已安装到 C:\msys64 下，请将 C:\msys64\usr\bin 添加到 %PATH% 环境变量中。然后，使用 cmd.exe 运行以下命令：

pacman -S git patch unzip

## 安装 Visual C++ 生成工具 2015
安装 Visual C++ 生成工具 2015。此软件包随附在 Visual Studio 2015 中，但可以单独安装：

转到 Visual Studio 下载页面，
选择“可再发行组件和生成工具”，
下载并安装：
Microsoft Visual C++ 2015 Redistributable 更新 3
Microsoft 生成工具 2015 更新 3
注意：TensorFlow 针对 Visual Studio 2015 更新 3 进行了测试。
安装 GPU 支持（可选）
要安装在 GPU 上运行 TensorFlow 所需的驱动程序和其他软件，请参阅 Windows GPU 支持指南。

## 下载 TensorFlow 源代码
使用 Git 克隆 TensorFlow 代码库（git 随 MSYS2 一起安装）：

    git clone https://github.com/tensorflow/tensorflow.git
    cd tensorflow
    

代码库默认为 master 开发分支。您也可以检出要编译的版本分支：

    git checkout branch_name  # r1.9, r1.10, etc.
    

要点：如果您在使用最新的开发分支时遇到编译问题，请尝试已知可用的版本分支。

## 配置编译系统
通过在 TensorFlow 源代码树的根目录下运行以下命令来配置编译系统：

    python ./configure.py
    

此脚本会提示您指定 TensorFlow 依赖项的位置，并要求指定其他编译配置选项（例如，编译器标记）。以下代码展示了 python ./configure.py 的运行会话示例（您的会话可能会有所不同）：

查看配置会话示例
配置选项
对于 GPU 支持，请指定 CUDA 和 cuDNN 的版本。如果您的系统安装了多个 CUDA 或 cuDNN 版本，请明确设置版本而不是依赖于默认版本。./configure.py 会创建指向系统 CUDA 库的符号链接，因此，如果您更新 CUDA 库路径，则必须在编译之前再次运行此配置步骤。

注意：从 TensorFlow 1.6 开始，二进制文件使用 AVX 指令，这些指令可能无法在旧版 CPU 上运行。
编译 pip 软件包

## Bazel build
仅支持 CPU
使用 bazel 构建仅支持 CPU 的 TensorFlow 软件包编译器：

    bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
    

GPU 支持
要构建支持 GPU 的 TensorFlow 软件包编译器，请运行以下命令：

    bazel build --config=opt --config=cuda --define=no_tensorflow_py_deps=true //tensorflow/tools/pip_package:build_pip_package
    

Bazel build 选项
在编译时使用以下选项，以避免在创建软件包时出现问题：https://github.com/tensorflow/tensorflow/issues/22390

    --define=no_tensorflow_py_deps=true
    

从源代码编译 TensorFlow 可能会消耗大量内存。如果系统内存有限，请使用以下命令限制 Bazel 的内存消耗量：--local_resources 2048,.5,1.0。

如果编译支持 GPU 的 TensorFlow，请添加 --copt=-nvcc_options=disable-warnings 以禁止显示 nvcc 警告消息。

编译软件包
bazel build 命令会创建一个名为 build_pip_package 的可执行文件，此文件是用于编译 pip 软件包的程序。例如，以下命令会在 C:/tmp/tensorflow_pkg 目录中编译 .whl 软件包：

    bazel-bin\tensorflow\tools\pip_package\build_pip_package C:/tmp/tensorflow_pkg
    

尽管可以在同一个源代码树下编译 CUDA 和非 CUDA 配置，但建议您在同一个源代码树中的这两种配置之间切换时运行 bazel clean。

安装软件包
生成的 .whl 文件的文件名取决于 TensorFlow 版本和您的平台。例如，使用 pip3 install 安装软件包：

    pip3 install C:/tmp/tensorflow_pkg/tensorflow-version-cp36-cp36m-win_amd64.whl
    

成功：TensorFlow 现已安装完毕。
使用 MSYS shell 编译
也可以使用 MSYS shell 编译 TensorFlow。做出下面列出的更改，然后按照之前的 Windows 原生命令行 (cmd.exe) 说明进行操作。

停用 MSYS 路径转换
MSYS 会自动将类似 Unix 路径的参数转换为 Windows 路径，此转换不适用于 bazel。（标签 //foo/bar:bin 被视为 Unix 绝对路径，因为它以斜杠开头。）

    export MSYS_NO_PATHCONV=1
    export MSYS2_ARG_CONV_EXCL="*"
    

设置 PATH
将 Bazel 和 Python 安装目录添加到 $PATH 环境变量中。如果 Bazel 安装到了 C:\tools\bazel.exe，并且 Python 安装到了 C:\Python36\python.exe，请使用以下命令设置 PATH：

    # Use Unix-style with ':' as separator
    export PATH="/c/tools:$PATH"
    export PATH="/c/Python36:$PATH"
    

要启用 GPU 支持，请将 CUDA 和 cuDNN bin 目录添加到 $PATH 中：

    export PATH="/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v9.0/bin:$PATH"
    export PATH="/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v9.0/extras/CUPTI/libx64:$PATH"
    export PATH="/c/tools/cuda/bin:$PATH"