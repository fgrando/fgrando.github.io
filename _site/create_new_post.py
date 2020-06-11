#!/usr/bin/python3

import os
import sys
import datetime
import shutil

if len(sys.argv) < 2:
    print("provide post name as argument")
    exit(-1)


template='1992-06-04-template'
template_post = '{}.markdown'.format(template)
template_data = '{}.data'.format(template)

root = os.getcwd()
posts_root = os.path.join(root, '_posts')
assets_root = os.path.join(root, 'assets')

# new post settings
title = sys.argv[1]
now = datetime.datetime.now()

date_now = now.strftime('%Y-%m-%d'.format(now))
hour_now = now.strftime('%H:%M:%S'.format(now))

post_name = date_now + '-' + hour_now + '_' + title

print ('Creating post {}'.format(post_name))

# copy post file
post = '{}.markdown'.format(post_name)
template_path = os.path.join(posts_root,template_post)
post_path =  os.path.join(posts_root,post)

print('copy {} to {}'.format(template_path, post_path))
shutil.copyfile(template_path, post_path)



assets = '{}.data'.format(post_name)
template_data_path = os.path.join(assets_root,template_data)
post_data_path =  os.path.join(assets_root,assets)

print('copy {} to {}'.format(template_data_path, post_data_path))
shutil.copytree(template_data_path, post_data_path)


print('run bundle exec jekyll serve')





# now edit to update some fields
fd = open(post_path, 'r')
text = fd.read()
fd.close()

text = text.replace("1992-06-04-template.data", assets)
text = text.replace("Template post for copy-paste", title)
text = text.replace("1992-06-04 12:00:00", "{} {}".format(date_now, hour_now))

fd = open(post_path, 'w')
fd.write(text)
fd.close()


