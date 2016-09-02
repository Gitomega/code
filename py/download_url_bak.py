#coding=utf-8
import time , urllib, os, threading, requests, math, re, random, time
import urllib2
header = {
'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36',
'Cookie': 'AspxAutoDetectCookieSupport=1',
}
#判断第一级文件夹是否存在
first_dir = "tmp/"    #-----需要做修改-----#
if not os.path.exists(first_dir):
	os.makedirs(first_dir)

## 统计文件总数，新建第二级文件夹，每个文件夹保存999个图片文件
pic_file = "1.txt"    #-----需要做修改-----#
count = 0
url_file = open(pic_file, 'rb')
while True:
	buffer = url_file.read(8192*1024)
	if not buffer:
		break
	count += buffer.count('\n')    #统计获取文件总数
url_file.close( )
#count += 1
print "将下载图片总数为:" + str(count)

for second_dir in xrange(1,(count / 999 + 2)):
	print "这是第二级文件夹，文件夹不存在将会创建:" + str(second_dir)
	create_second_dir = "0"+str(second_dir)
	save_dir = str(first_dir) + str(create_second_dir) + "/"
	if not os.path.exists(save_dir):
		os.makedirs(save_dir)

f = open(pic_file, 'r')
num = 1
save_dir = str(first_dir) + "01/"
for url in f.readlines():
	request = urllib2.Request(url, None, header)
	response = urllib2.urlopen(request)
	with open(save_dir + str(num) + ".jpg", "wb") as f:
		f.write(response.read())
		print "Downloading the %d picture ,save in %s dir" % (num ,save_dir)
		num += 1
		time.sleep(2)
		# count_file = 0
		# path = save_dir
		# for root, dirs, files in os.walk(path):
		# 	# print files
		# 	fileLength = len(files)
		# 	fileLength = fileLength + count_file
		# 	print fileLength
		# 	if fileLength == 999:
		# 		second_dir += 1
		# 		print "second_dir :  %d" %second_dir
		# 		break
				#continue

f.close()
print time.strftime("%Y-%m-%d %H:%M:%S")



# f = open(pic_file)
#
# num = 1
#
# for url in f.readlines():
# 	#url="http://www.cfh.ac.cn/data/2009/200906/20090630/thumbnail/29d1554b-3cd9-40d4-a7fb-d9d6ec4338e4.jpg"
# 	request = urllib2.Request(url,None,header)
# 	response = urllib2.urlopen(request)
# 	with open( save_dir+str(num)+".jpg","wb") as f:
# 		f.write(response.read())
# 		print "Downloading the %d picture" %num
# 		num += 1
# 		time.sleep(3)
#
# print "Download the picture finshed... totle %d" % (num-1)
# print time.strftime("%Y-%m-%d %H:%M:%S")
