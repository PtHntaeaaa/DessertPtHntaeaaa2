#!/bin/bash

SCRIPT_NAME="DessertPtHntaeaaa-v1.2-"
SCRIPT_VERSION="1.2"
AUTHOR="PtHntaeaaa"
GITHUB_URL="https://github.com/PtHntaeaaa/dessert"
DEPENDENCIES=(wget unzip git)
RECOMMENDED_PKGS=(nmap vim nano htop zsh eza emacs tree curl iproute2 fzf neofetch)

TERMUX_MODE=false
if [[ $(uname -o) == "Android" ]]; then
    TERMUX_MODE=true
    RECOMMENDED_PKGS=(nmap vim nano htop zsh eza emacs tree curl fzf neofetch)
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

error_exit() {
    echo -e "${RED}[错误] $1${NC}" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_dependencies() {
    local missing=()
    for dep in "${DEPENDENCIES[@]}"; do
        if ! command_exists "$dep"; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}正在安装依赖: ${missing[*]}${NC}"
        if $TERMUX_MODE; then
            pkg update -y || error_exit "更新包列表失败"
            pkg install -y "${missing[@]}" || error_exit "依赖安装失败"
        else
            apt update || error_exit "更新包列表失败"
            apt install -y "${missing[@]}" || error_exit "依赖安装失败"
        fi
    fi
}

show_header() {
    clear
    echo -e "${GREEN}"
    echo "   ______        _____)       __        __       _____)    _____       ______)"
    echo "  (, /    )    /          (__/  )   (__/  )    /          (, /   )    (, /"
    echo "    /    /     )__          /         /        )__          /__ /       /"
    echo "  _/___ /_   /           ) /       ) /       /           ) /   \_    ) /"
    echo "(_/___ /    (_____)     (_/       (_/       (_____)     (_/         (_/"
    echo -e "${NC}"
    echo -e "${BLUE}      $SCRIPT_NAME v$SCRIPT_VERSION - 由 $AUTHOR 开发${NC}"
    echo -e "${YELLOW}      GitHub: $GITHUB_URL${NC}"
    if $TERMUX_MODE; then
        echo -e "${RED}      [Termux 模式]${NC}"
    fi
    echo "================================================================"
}

install_recommended() {
    show_header
    echo -e "${GREEN}正在安装九瓷推荐的常用软件包...${NC}"
    
    if $TERMUX_MODE; then
        RECOMMENDED_PKGS+=(python)
    else
        RECOMMENDED_PKGS+=(python3)
    fi
    
    local to_install=()
    for pkg in "${RECOMMENDED_PKGS[@]}"; do
        if ! command_exists "$pkg" && {
            if $TERMUX_MODE; then
                ! pkg list-installed | grep -q "$pkg"
            else
                ! dpkg -s "$pkg" &>/dev/null
            fi
        }; then
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -eq 0 ]; then
        echo -e "${YELLOW}所有推荐软件包已安装！${NC}"
    else
        echo "将安装: ${to_install[*]}"
        
        if $TERMUX_MODE; then
            pkg update -y || error_exit "更新包列表失败"
            pkg upgrade -y
            pkg install -y "${to_install[@]}" || error_exit "软件包安装失败"
        else
            apt update || error_exit "更新包列表失败"
            apt upgrade -y
            apt install -y "${to_install[@]}" || error_exit "软件包安装失败"
        fi
        
        echo -e "${GREEN}安装完成！${NC}"
    fi
    
    if command_exists neofetch; then
        neofetch
    else
        echo -e "${YELLOW}neofetch 未安装，跳过系统信息显示${NC}"
    fi
    
    read -p "按Enter键返回主菜单..."
}

download_dessert() {
    while true; do
        show_header
        echo -e "${GREEN}甜点下载${NC}"
        echo "--------------------------------"
        read -p "请输入甜点版本号 (0-99): " version
        
        if [[ "$version" =~ ^[0-9]{1,2}$ ]]; then
            echo -e "您选择的版本: ${BLUE}$version${NC}"
            break
        else
            echo -e "${RED}错误：请输入两位数字内的有效版本号${NC}"
            sleep 2
        fi
    done
    
    local download_dir="甜点_v$version"
    mkdir -p "$download_dir" || error_exit "无法创建目录"
    cd "$download_dir" || error_exit "无法进入目录"
    
    local filename="milk-$version-.py"
    echo -e "${YELLOW}正在下载甜点版本 $version...${NC}"
    
    if wget --show-progress -q "$GITHUB_URL/blob/main/0/$filename"; then
        echo -e "${GREEN}下载成功！${NC}"
    else
        cd ..
        rm -rf "$download_dir"
        error_exit "下载失败，请检查版本号或网络连接"
    fi
    
    echo -e "${GREEN}甜点已保存到: $(pwd)${NC}"
    cd ..
    read -p "按Enter键返回主菜单..."
}

main_menu() {
    while true; do
        show_header
        echo -e "${GREEN}主菜单${NC}"
        echo "--------------------------------"
        if [ "$EUID" -eq 0 ] || $TERMUX_MODE; then
            echo -e "权限状态: ${RED}高级权限${NC}"
        else
            echo -e "权限状态: ${BLUE}普通用户${NC}"
        fi
        
        echo
        echo "1) 下载甜点"
        echo "2) 安装推荐软件包"
        echo "3) 检查脚本更新"
        echo "4) 退出"
        echo "--------------------------------"
        
        read -p "请输入选项 [1-4]: " choice
        case $choice in
            1) download_dessert ;;
            2) install_recommended ;;
            3) check_updates ;;
            4) 
                echo -e "${GREEN}谢谢先生们使用...${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}无效选项，请重新输入${NC}"
                sleep 1
                ;;
        esac
    done
}

check_updates() {
    show_header
    echo -e "${GREEN}检查更新...${NC}"
    echo "--------------------------------"
    
    VERSION_URL="https://raw.githubusercontent.com/PtHntaeaaa/DessertPtHntaeaaa2/main/Dsh/version.txt"
    
    SCRIPT_URL="https://raw.githubusercontent.com/PtHntaeaaa/DessertPtHntaeaaa2/main/Dsh/sh/DessertPtHntaeaaa-v1.2-.sh"
    
    local latest_version
    latest_version=$(curl -sSL "$VERSION_URL" | head -n1 | tr -d '[:space:]')
    
    if [ -z "$latest_version" ]; then
        echo -e "${YELLOW}无法获取最新版本信息${NC}"
    else
        local current_version="v$SCRIPT_VERSION"
        
        if [ "$current_version" != "$latest_version" ] && 
           [ "$(printf "%s\n%s" "$current_version" "$latest_version" | sort -V | tail -n1)" == "$latest_version" ]; then
            echo -e "${YELLOW}发现新版本: $latest_version${NC}"
            echo -e "当前版本: $current_version"
            read -p "是否更新脚本? [y/N] " yn
            if [[ "$yn" =~ [Yy] ]]; then
                echo "正在更新..."
                if wget -q -O "$0.tmp" "$SCRIPT_URL"; then
                    mv "$0.tmp" "$0"
                    chmod +x "$0"
                    echo -e "${GREEN}更新成功！请重新运行脚本${NC}"
                    exit 0
                else
                    echo -e "${RED}更新失败${NC}"
                    rm -f "$0.tmp"
                fi
            fi
        else
            echo -e "${GREEN}当前已是最新版本 ($current_version)${NC}"
        fi
    fi
    
    read -p "按Enter键返回主菜单..."
}
install_dependencies
main_menu
