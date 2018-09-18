

curl -O http://mirrors.shu.edu.cn/apache/pig/pig-0.16.0/pig-0.16.0.tar.gz

### /opt/pig-0.17.0
processed = load'/dataguru/week8/sport/out/part-r-00000' as (category:chararray,doc:chararray);
test = sample processed 0.2;
jnt = join processed by (category,doc) left outer, test by (category,doc);
filt_test = filter jnt by test::category is null;
train = foreach filt_test generate processed::category as category,processed::doc as doc;
store test into '/dataguru/week8/test';
store train into '/dataguru/week8/train';