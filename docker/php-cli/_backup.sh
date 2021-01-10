DS=`date +%Y%m%d` && \
mysqldump -h mysql -uroot -proot default > /backup/db$DS.sql && \
echo 1 && \
exit
