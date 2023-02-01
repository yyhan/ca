# 简介
通过 openssl 自建 CA 的模板代码。 包含一个基本可用的 openssl 配置文件，openssl 生成、签发、吊销证书的脚本。 对配置文件和脚本略作修改后，可作为一个简单的内部使用的 CA 签发中心。

文件列表：

| 文件名 | 说明 |
| ------ | ------ |
| config/openssl.cfg | openssl 配置文件。 |
| config/ext_root.cfg | 根证书签发时，扩展内容文件。 |
| config/ext_client.cfg | 客户端证书签发时，扩展内容文件。 |
| config/ext_server.cfg | 服务端证书签发时，扩展内容文件。 |
| data/crl | 证书吊销列表文件 |
| data/crl_number | 吊销证书的编号 |
| data/crl_number.old | 吊销证书编号文件的备份文件 |
| data/index.txt | 数据库文件 |
| data/index.txt.old | 数据库文件备份文件 |
| data/index.txt.attr | 数据库文件的属性文件 |
| data/index.txt.attr.old | 数据库文件的属性文件的备份文件 |
| ca_root/ca_root_key.pem | CA 根证书 rsa 密钥对。 |
| ca_root/ca_root.crt | CA 根证书（crt 格式）。 |
| certs/ | 生成的证书密钥及签发证书目录 |
| newcerts/ | 已签发的证书目录 |
| init.sh | 初始化脚本 |
| generate.sh | 生成证书的脚本 |
| revoke.sh | 吊销证书脚本 |

# 使用说明
## 初始化

执行 `init.sh` 脚本，生成目录结构以及必要的数据文件。
```bash
bash init.sh
```

## 生成并签发证书
### 生成根证书
必须首先生成根证书，然后才能用该根证书签发其它证书。

生成根证书命令：
```bash
bash generate.sh root
```

### 生成服务端证书
服务端证书一般用于配制 https 服务。

生成服务端证书命令：
```bash
bash generate.sh server
```

### 生成客户端证书
当 web 服务启用客户端证书认证时，浏览器会提示用户选择对应的客户端证书。

生成客户端证书命令：
```bash
bash generate.sh client
```
相比服务端证书，客户端证书生成时会多一个 `p12` 格式的证书文件。而且生成过程中，会在控制台输出证书密码（必须记下该密码，安装证书时将会用到）。 

输出证书密码的文本如下：
```txt
客户端证书密码: +sAP945HebfDZ8GjdnhMtdDfm4c=
```

生成结束后，需要将 `p12` 格式的证书文件 和 `证书密码` 一并发给用户。

## 吊销证书
修改 `revoke.sh` 脚本里的 `REVOKE_CRT_FILE` 变量为待吊销证书文件路径，然后执行以下命令：
```bash
bash revoke.sh
```

# 最佳实践
用于生产环境时，建议将除了 `certs` 目录外的其它所有文件提交到 GIT 仓库管理。

# 注意事项
+ 正式使用后，CA根证书请勿重新生成
+ 签发服务端证书时，必须修改 `config/ext_server.cfg` 中的域名为你的域名。

# 附录
## 参考文档
+ [openssl 官网](https://www.openssl.org/)
+ [openssl-ca 命令](https://www.openssl.org/docs/man3.0/man1/openssl-ca.html)
+ [openssl-genrsa 命令](https://www.openssl.org/docs/man3.0/man1/openssl-ca.html)
+ [openssl-pkcs12 命令](https://www.openssl.org/docs/man3.0/man1/openssl-ca.html)
+ [openssl-req 命令](https://www.openssl.org/docs/man3.0/man1/openssl-ca.html)
+ [nginx ssl 客户端证书认证](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_verify_client)

## 常用 openssl 命令
```bash
# 查看证书内容
openssl x509 -in certs/02_20230201122221.crt -noout -text
# 查看证书信息
openssl x509 -in certs/02_20230201122221.crt -noout -subject
# 查看证书序列号
openssl x509 -in certs/02_20230201122221.crt -noout -serial
# 查看证书签发的有效期
openssl x509 -in certs/02_20230201122221.crt -noout -dates
openssl x509 -in certs/02_20230201122221.crt -noout -startdate -enddate
# 查看证书的 sha1 指纹
openssl x509 -in certs/02_20230201122221.crt -noout -fingerprint -sha1
# 查看证书的 sha256 指纹
openssl x509 -in certs/02_20230201122221.crt -noout -fingerprint -sha256

# 查看 CSR 文件（证书签名请求文件）内容：
openssl req -in certs/02_20230201122221.csr -noout -text

# 使用根证书校验其它证书
openssl verify -CAfile ca_root/ca_root.crt certs/02_20230201122221.crt

# 使用根证书校验 crl 文件
openssl crl -verify -CAfile ca_root/ca_root.crt data/crl
# 输出 crl 文件(查看已吊销证书的序列号)
openssl crl -in ${CRL_FILE} -noout -text
```
