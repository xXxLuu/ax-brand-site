# AX 网站：阿里云轻量应用服务器上线包

此目录为 `axmoonlight.com` 准备。备案通过后，使用本目录将当前网站发布到阿里云中国内地轻量应用服务器。

## 先确认四件事

1. ICP 备案已通过，且备案号已取得。
2. 域名 `axmoonlight.com` 的 A 记录已经指向轻量应用服务器公网 IP。
3. 轻量应用服务器防火墙已放行 TCP 端口 `80` 和 `443`。
4. 用 Mac 终端可登录服务器，例如：`ssh root@服务器公网IP`。

## 首次上线（只需一次）

在本机终端进入网站文件夹后执行：

```bash
cd ~/Documents/website
bash deploy/scripts/deploy-to-aliyun.sh root@你的服务器公网IP
```

脚本会上传网站、安装 Nginx、写入网站配置并启动网站。完成后可先通过 `http://axmoonlight.com` 打开网站。

若你的服务器登录账号不是 `root`，请使用具备 sudo 权限的账号，例如：

```bash
bash deploy/scripts/deploy-to-aliyun.sh admin@你的服务器公网IP
```

## 开启 HTTPS（备案通过、域名解析生效后）

网站能通过 HTTP 正常打开后，在本机执行：

```bash
cd ~/Documents/website
bash deploy/scripts/enable-https.sh root@你的服务器公网IP 你的常用邮箱
```

脚本会申请并安装免费 HTTPS 证书，并设置自动续期。完成后使用：

```text
https://axmoonlight.com
```

## 后续更新网站

每次我更新网页后，重复执行首次上线使用的命令即可。脚本只同步网站文件和 Nginx 配置，不会重装系统。

## 服务器上的网站位置

```text
/var/www/axmoonlight.com
```

## 遇到无法访问时先检查

- 域名 A 记录是否是服务器公网 IP。
- 阿里云轻量应用服务器防火墙是否已放行 80 和 443。
- 服务器安全组（如有）是否也已放行 80 和 443。
- 备案通过前，请不要将中国内地服务器正式对外解析为该网站。

> 首次部署后，请将工信部 ICP 备案号和公安联网备案号（如已办理）发给我；我会把它们添加到网站页脚。
