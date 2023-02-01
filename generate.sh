#!/bin/bash

# openssl 配置文件
OPENSSL_CFG="config/openssl.cfg"

# 获取新证书的序列号
CRT_SERIAL=$(cat data/serial)

# 证书名称（必须修改为自己的）
CRT_NAME="${CRT_SERIAL}_$(date +%Y%m%d%H%M%S)"
# 证书有效天数（必须修改为自己的）
CRT_EXPIRE_DAYS=3650
# 证书扩展内容文件（必须修改为自己的）
CRT_EXT_FILE=""
# 证书信息（必须修改为自己的）
CRT_SUBJ=""


ARG_CRT_TYPE=$1

if [ -z $ARG_CRT_TYPE ]
then
    echo ">> 请输入证书类型！ 可选的证书类型： root, server, client."
    exit 1
fi

if [ $ARG_CRT_TYPE == "root" ]
then
    CRT_SUBJ="/C=CN/ST=浙江省/L=杭州市/O=Example/OU=Example CA/CN=Example CA Root"
    CRT_EXT_FILE="config/ext_root.cfg"
elif [ $ARG_CRT_TYPE == "server" ]
then
    CRT_SUBJ="/C=CN/ST=浙江省/L=杭州市/O=Example/OU=Example Server/CN=${CRT_NAME}"
    CRT_EXT_FILE="config/ext_server.cfg"
elif [ $ARG_CRT_TYPE == "client" ]
then
    CRT_SUBJ="/C=CN/ST=浙江省/L=杭州市/O=Example/OU=Example Member/CN=${CRT_NAME}"
    CRT_EXT_FILE="config/ext_client.cfg"
else
    echo ">> 不支持的证书类型：${ARG_CRT_TYPE} ! 可选的证书类型： root, server, client."
    exit 1
fi

echo ">> 【 开始生成证书 】"
echo ">> 证书类型: ${ARG_CRT_TYPE}"

echo "证书信息: $CRT_SUBJ"
echo "证书有效期: ${CRT_EXPIRE_DAYS} 天"

# 1、生成密钥
echo ">> 1、生成密钥"
CRT_KEY_FILE="certs/${CRT_NAME}_key.pem"
openssl genrsa -out ${CRT_KEY_FILE} 2048
echo ">> KEY 文件: ${CRT_KEY_FILE}"

# 2、生成证书签名请求
echo ">> 2、生成证书签名请求"
CRT_CSR_FILE="certs/${CRT_NAME}.csr"
openssl req \
    -new \
    -sha256 \
    -days ${CRT_EXPIRE_DAYS} \
    -utf8 \
    -subj "${CRT_SUBJ}" \
    -key ${CRT_KEY_FILE} \
    -out ${CRT_CSR_FILE}
echo ">> CSR 文件: ${CRT_KEY_FILE}"

# 3、证书签名
echo ">> 3、证书签名"
CRT_FILE="certs/${CRT_NAME}.crt"
if [ $ARG_CRT_TYPE == "root" ]
then
    # 自签名为 CA 证书
    echo ">> 自签名为 CA 证书"
    
    cp ${CRT_KEY_FILE} ca_root/ca_root_key.pem

    openssl ca -config ${OPENSSL_CFG} \
        -selfsign \
        -in ${CRT_CSR_FILE} \
        -out ${CRT_FILE}
    
    # 根证书生成后，需要复制到指定的位置
    cp ${CRT_FILE} ca_root/ca_root.crt
else
    # 使用根证书签名
    echo ">> 使用根证书签名"
    openssl ca \
        -config ${OPENSSL_CFG} \
        -extfile ${CRT_EXT_FILE} \
        -in ${CRT_CSR_FILE} \
        -out ${CRT_FILE}
fi
echo ">> CRT 文件: ${CRT_FILE}"

# 4、将客户端证书转换为 p12 格式
if [ $ARG_CRT_TYPE == "client" ]
then
    echo ">> 4、将客户端证书转换为 p12 格式"
    # 证书密码（随机生成）
    CRT_PASSWORD="$(openssl rand -base64 20)"
    # p12 格式证书路径
    CRT_P12_FILE="certs/${CRT_NAME}.p12"
    # 使用 openssl pkcs12 命令进行转换
    openssl pkcs12 \
        -export -clcerts \
        -password pass:${CRT_PASSWORD} \
        -in ${CRT_FILE} \
        -inkey ${CRT_KEY_FILE} \
        -out ${CRT_P12_FILE}
    echo ">> 客户端证书密码: ${CRT_PASSWORD}"
    echo ">> P12 文件: ${CRT_P12_FILE}"
fi
echo ">> 【 证书生成结束 】"
