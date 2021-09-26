#!/bin/bash

u15=`find / ! \( -path '/proc*' -o -path '/sys/fs*' -o -path '/usr/local*' -prune \) -perm -2 -type f -exec ls -al {} \;`

if [ -z "$u15" ] ; then
	echo "world writable 파일 점검 ---------------- [양호]"
else
	echo "world writable 파일 점검 ---------------- [위험]"
fi


u16=`find /dev -type f -exec ls -l {} \;`

if [ -z "$u16" ]; then
	echo "/dev에 존재하지 않는 device 파일 점검 --- [양호]"
else
	echo "/dev에 존재하지 않는 device 파일 점검 --- [위험]"
fi

u17_1=`ls -al /etc/ | grep 'hosts.equiv' | awk '{print $1}'`
u17_2=`ls -al $HOME/ | grep '.rhosts' | awk '{print $1}'`
u17_5=0


if [ "$u17_1" != "-rw-------." ]; then
	chown root /etc/hosts.equiv
	chmod 600 /etc/hosts.equiv
fi
if [ "$u17_2" != "-rw-------." ]; then
	chown root $HOME/.rhosts
	chmod 600 $HOME/.rhosts
fi

if  [ "$HOME/.rhosts" != *"+"* ]; then
	if [ "$HOME/.rhosts" != *"+"* ]; then
		echo "$HOME/.rhosts, hosts.equiv 사용 금지 ---- [양호]"
	else
		echo "$HOME/.rhosts 설정 변경 필요"
		u17_5=1
	fi
else
	if [ "$HOME/.rhosts" == *"+"* ]; then
		echo "$HOME/.rhosts 설정 변경 필요"
		u17_5=1
	fi
	echo "/etc/hosts.equiv 설정 변경 필요"
	u17_5=1
fi

if [ "$u17_5" -eq 1 ]; then
	echo "$HOME/.rhosts, hosts.equiv 사용 금지 ---- [위험]"
fi

u19=`ls -al /etc/xinetd.d/ | grep "finger"`

if [ -z "$u19" ]; then
	echo "finger 서비스 비활성화 ------------------ [양호]"
else
	u19_1=`cat /etc/xinetd.d/finger | grep disable | awk '{print $3}'`
	if [ "$u19_1" == "yes" ]; then
		echo "finger 서비스 비활성화 ------------------ [양호]"
	else
		echo "finger 서비스 비활성화 ------------------ [위험]"
	fi
fi

u20=`cat /etc/passwd | grep "ftp"`

if [ -z "$u20" ]; then
	echo "Anonymous FTP 비활성화 ------------------ [양호]"
else
	
	echo "Anonymous FTP 비활성화 ------------------ [양호]"
	userdel ftp
	echo "Anonymous FTP 비활성화 ------------------ [삭제 완료]"
fi


u21=`ls -alL /etc/xinetd.d/ | egrep "rsh|rlogin|rexec" | egrep -v "grep|klogin|kshell|kexec"`
u21_1=`cat /etc/xinetd.d/rlogin 2> /dev/null | grep disable | awk '{print $3}'` 
u21_2=`cat /etc/xinetd.d/rsh 2> /dev/null | grep disable | awk '{print $3}'`
u21_3=`cat /etc/xinetd.d/rexec 2> /dev/null | grep disable | awk '{print $3}'`
u21_4=0

if [ -z "$u21" ]; then
	echo "r 계열 서비스 비활성화 ------------------ [양호]"
else
	if [ "$u21_1" == "yes" ]; then
		if [ "$u21_2" == "yes" ]; then
			if [ "$u21_3" == "yes" ]; then
				echo "r 계열 서비스 비활성화 ------------------ [양호]"
			else
				"$u21_4"=1
			fi
		else
			"$u21_4"=1
		fi
	else
		"$u21_4"=1
	fi
fi
				
if [ "$u21_4" == "1" ]; then
	echo "r 계열 서비스 비활성화 ------------------ [위험]"
fi

u22_1=`ls -al /etc/ | grep 'cron.allow' | awk '{print $1}'`
u22_2=`ls -al /etc/ | grep 'cron.deny' | awk '{print $1}'`

if [ "$u22_1" != "-rw-------." ]; then
	chown root /etc/cron.allow 2> /dev/null
	chmod 600 /etc/cron.allow 2> /dev/null
fi
if [ "$u22_2" != "-rw-------." ]; then
	chown root /etc/cron.deny 2> /dev/null
	chmod 600 /etc/cron.deny 2> /dev/null
fi
echo "cron 파일 소유자 및 권한설정 ------------ [양호]"

u23=`ls -alL /etc/xinetd.d/ | egrep "echo|discard|daytime|chargen"`
u23_1=`cat /etc/xinetd.d/echo 2> /dev/null | grep disable | awk '{print $3}'`
u23_2=`cat /etc/xinetd.d/discard 2> /dev/null | grep disable | awk '{print $3}'`
u23_3=`cat /etc/xinetd.d/daytime 2> /dev/null | grep disable | awk '{print $3}'`
u23_4=`cat /etc/xinetd.d/chargen 2> /dev/null | grep disable | awk '{print $3}'`
u23_5=0

if [ -z "$u23" ]; then
	echo "Dos 공격에 취약한 서비스 비활성화 ------- [양호]"
else
	if [ "$u23_1" == "yes" ]; then
		if [ "$u23_2" == "yes" ]; then
			if [ "$u23_3" == "yes" ]; then
				if [ "$u23_4" == "yes" ]; then
					echo "Dos 공격에 취약한 서비스 비활성화 ------- [양호]"

				else
					"$u23_5"=1
				fi
			else
				"$u23_5"=1
			fi
		else
			"$u23_5"=1
		fi
	else
		"$u23_5"=1
	fi
fi

if [ "$u23_5" == "1" ]; then
	echo "Dos 공격에 취약한 서비스 비활성화 ------- [위험]"
fi

u24=`ps -ef | grep nfsd | awk '{print $8}'`
u24_1=`ps -ef | grep nfsd | awk '{print $2}'`
u24_2=`kill -9 "$24_1" 2> /dev/null`

if [ "$u24" == "/usr/lib/nfs/nfsd" ]; then
	echo "NFS 서비스 비활성화 --------------------- [위험]"
	"$u24_2"
	echo "NFS 서비스 비활성화 --------------------- [비활성화 완료]"
else
	echo "NFS 서비스 비활성화 --------------------- [양호]"
fi



	
