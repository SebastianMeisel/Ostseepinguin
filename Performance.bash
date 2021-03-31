export LC_ALL=en_US.utf8
S_COLORS=never

vmstat 1 3 | awk '{ print  $13 " " $14 " " $17}' | column -tc3

sar -u -s 10:00 -e 11:00 | awk 'NR > 1 {$6=""; $8=""; print $0}'

sar -P 1,3 -s 10:00 -e 10:20 | awk 'NR > 1 {print $1 " " $2 " " $3 " " $4 " " $6}'

ps -o pid,pcpu | sed -n '2,$p' | sort -rhk2 | head -5

lscpu | grep -m1 'CPU(s)'
echo
echo "vmstat"
vmstat 3 3 | awk 'NR > 1 {print $1}'
echo
echo "sar"
sar -q  3 3 | awk 'NR > 2 {print $2}'
echo
echo "dstat"
dstat -p 3 3 | awk 'NR > 1 {print $1}'

for d in $(find /proc/  -maxdepth 1 -type d -regex '.*[0-9]$') ; \
  do echo -n "$d: " ; \
  cut -f2 -d' ' $d/schedstat 2>/dev/null; \
done | sort -rhk2 | head -5

for d in $(find /proc/  -maxdepth 1 -type d -regex '.*[0-9]$') ; \
    do echo -n "$d: " ; \
    echo $(awk '{print $2 " / " $1}' $d/schedstat 2>/dev/null | bc 2>/dev/null) ; \
done  | egrep -v '0$' | sort -rhk2 | head -5

free -m

vmstat -SM | awk 'NR >  1 { print $3 " " $4 }'

sar -rh -s 15:00 -e 15:30 |\
awk 'NR == 1 { print $4 } \
     NR > 2 {print $1 " " $5}'

dstat -m  1 3 | awk ' NR >= 2 { print $2 }'

sudo slabtop -os c | head -5

ps -eo pid,%mem,vsz,comm | sort -rhk2,3 | column -tc4 | head -5

vmstat -SM | awk 'NR >  1 { print $7 " " $8 }'

sar -B | awk 'NR == 3 {print $1 " " $7 " " $8 } ; END {print $1 " " $7 " " $8 }' | column -tc3

sar -W | sed -n '3p;$p' | column -tc3

cat /proc/33/stat | awk '{print $10}'

journalctl -u earlyoom.service --since 10:20 --until 10:25

dmesg | grep kill | tail -5

ip -s link show wlp1s0 | awk ' BEGIN { i=999 }
                      /^[1-9]/ {print $2} ; \
                      /RX/     {printf "%s", "RX: " ; i=(NR + 1)} ; \
                      /TX/     {printf "%s", "TX: " ; i=(NR + 1)} ; \
		      NR == i  {printf "%2.2f GiB\n", ($1/1024/1024/1024)}'

ifstat -zbT 1 3 |\
    awk 'NR == 1 {print "-" $1 "- -------- -" $2 "- -------- " } ; NR > 1 {print $0}' |\
    sed 's/s /s_/g'

sar -n DEV 1 1 | awk 'NR > 2 && $3 != 0 {print $1 " " $2 " " $3 " " $4 " " $5 " " $6}'

dstat -n 1 3

nicstat -zM | awk '{$9=$10=""; print $0}'

collectl -sn -oT -i05 -c3 | awk 'NR > 2 {print $0}'

cat /proc/net/dev |\
awk 'NR == 1 {print $1 $2" -------- "$4" --------"} ; \
     NR == 2 {print $1 " MBytes packets MBytes packets"}
     NR >  2 {print $1 " " ($2 / 1000000) " " $3 " " ($10 / 1000000) " " $11}'

nicstat | awk '{print $1 " " $10}'

nicstat -x

ip -s link show wlp1s0 | awk ' BEGIN { i=999 ; j=999}
                      /^[1-9]/ {print $2} ; \
                      /RX/     {printf "%s", "RX: " ; i=(NR + 1)} ; \
                      /TX/     {printf "%s", "TX: " ; j=(NR + 1)} ; \
		      NR == i  {printf "Dropped: %d Overrun: %d \n", $4, $5 } ; \
		      NR == j  {printf "Dropped: %d", $4 } '

sar -n EDEV -s 19:30 -e 20:00 | awk 'NR > 2 {print $6 " " $7 " " $10 " " $11}'

ss -tuam | sed -E 's/skmem[:(].*?d([0-9]+)[)]/Dropped: \1/g;
                  s/\b0\b/--/g;
                  s/([0-9]{1,3})(.([0-9]{1,3})){3,3}/⌷⌷⌷.⌷⌷⌷.⌷⌷⌷.⌷⌷⌷/g' |\
head

cat /proc/net/dev |\
awk 'NR == 1 {print $1 $2 " -- " $4 " -- "};\
     NR == 2 {print $1 " RX-drops RX-overrun TX_drops RX-overrun" };\
     NR >  2 {print $1 " " $5 " " $6 " " $14 " " $15}'

egrep '[0-9]+' /sys/class/net/*/statistics/* |\
egrep '(drop|fifo)' |& \
sed 's|:|/|g'|\
awk -F '/' 'BEGIN     {DEV = ""};\
            DEV != $5 {print $5 "-------------- ---"} ; \
                      {print " *" $7 " " $8 ; DEV = $5}' ;

ip -s link show wlp1s0 | awk 'BEGIN { i=999 }
                /^[1-9]/ {print $2} ; \
                /RX/    {printf "%s", "RX-errors: " ; i=(NR + 1)} ; \
                /TX/    {printf "%s", "TX-errors: " ; i=(NR + 1)} ; \
		NR == i {print $3}'

sar -n EDEV 1 1 | awk 'NR > 2 {print $1 " " $2 " " $3 " " $4}'

nicstat -x | awk '{print $1 " " $6 " " $7}'

cat /proc/net/dev |\
awk 'NR == 1 {print $1 $2 " " $4 };\
     NR == 2 {print $1 " RX_Errors TX_Errors" };\
     NR >  2 {print $1 " " $4 " " $13}'

egrep '[0-9]+' /sys/class/net/*/statistics/*_errors |\
sed 's/:/\//' |\
awk -F '/' 'BEGIN     {DEV = ""};\
            DEV != $5 {print $5 "-------------- ---"} ; \
                      {print " *" $7 " " $8 ; DEV = $5}' |\
head -14

iostat -xz 1 1 | awk 'NR == 6 {print $1 " " $NF}
                               NR > 6 && $(NF) != 0 && $0 != "" {print  $1 " " $NF }'

sar -d -s 15:00 -e 15:30 |\
awk 'NR == 3            {print $1 " " $2 " " $NF};
     NR > 3 && $NF != 0 {print $1 " " $2 " " $NF}'

sudo iotop -ob -n 2 -d 1

pidstat -d | sed -n '3,9p'

\
iostat -hxz 1 1 |\
awk 'NR > 5 && $5 != 0 && NF > 3 {print $5 " " $NF};
     NF == 3 && $1 != 0           {print $1 " " $NF}'|\
grep -v loop

\
sar -hd -s 11:00 -e 11:20 |\
awk '($7 > 0 || $8 >0)  && NR > 2 {print $1 " " $7 " " $8 " " $NF}'

sudo smartctl -l error /dev/sda

find /sys/devices/ -iname 'ioerr_cnt' |\
 xargs cat | sed 's/0x//' | xargs echo 'ibase=16; ' | bc

\
df -h -x tmpfs -x devtmpfs -x squashfs

\
du -d 1 -h | sort -h | sed -En '/[0-9]G/p' |\
sed -E 's|/[.a-zA-Z@]+|********|'
