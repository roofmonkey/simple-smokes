echo "Cleaning flume source file"
rm -rf /tmp/flume-smoke
echo "Starting flume writes to source file"
for a in `seq 1 50`
do
    sleep 1
    echo "$a hello $a " >> /tmp/flume-smoke
    echo "wrote $a"
done
