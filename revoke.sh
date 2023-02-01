#!/bin/sh

# 吊销证书

# openssl 配置文件
OPENSSL_CFG="config/openssl.cfg"

# 已吊销证书列表文件
CRL_FILE="data/crl"

# 待吊销的证书
REVOKE_CRT_FILE="newcerts/02.pem"

# 吊销证书
openssl ca -config ${OPENSSL_CFG} -revoke ${REVOKE_CRT_FILE}
# 生成吊销证书列表文件
openssl ca -config ${OPENSSL_CFG} -gencrl -out ${CRL_FILE}




