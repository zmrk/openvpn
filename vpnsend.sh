#!/bin/bash

title="[CRAZYGUYS]"
myip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $(NF-2)}')

# 파라미터가 없으면 종료 
if [ "$#" -lt 1 ]; then
    echo "$# is Illegal number of parameters."
    echo "Usage: $0 [username]"
    exit 1
fi
#args=("$@")

IFS='-' read -ra name <<< "$1"
mail=${name[0]}@crazyguys.me

# key 체크 후 없으면 생성
if [ -f "$HOME/pki/issued/$1.crt" ]; then
    echo "$1 already exists."
else
    echo "Create $1.."
    /usr/share/easy-rsa/3/easyrsa build-client-full $1 nopass
fi

# openvpn 폴더 생성
mkdir ~/openvpn
cp ~/*.ovpn ~/openvpn/
cp ~/pki/ca.crt ~/openvpn/
cp ~/pki/ta.key ~/openvpn/
cp ~/pki/issued/$1.crt ~/openvpn/client.crt
cp ~/pki/private/$1.key ~/openvpn/client.key

# 압축하고 메일 전송
cd ~/openvpn
tar -czf openvpn.tar.gz *
echo -e "$title[$myip] $1 \n OpenVPN profile 입니다. \n 파일이 유출되지 않도록 조심해주세요. \n https://www.notion.so/crazyguys/OpenVPN-f4cd89aac1c0491caf39cb0674231389" | sudo mail -s "$title[$myip] $1 OpenVPN profile" -a openvpn.tar.gz $mail
echo "Mail sending... $mail"

# 삭제
cd ~
rm -rf ~/openvpn