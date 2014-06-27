### Echo simple create / update / read test of Hbse 
bin/hbase shell -d <<EOF
create ‘t1’,‘f1’
put ‘t1’, ‘row1’, ‘f1:a’, ‘val1’
scan ‘t1’
EOF
