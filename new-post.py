#!/bin/python3

import sys
import datetime
import os
import re

if len(sys.argv) < 2:
    print("please input a title for this post")
    exit(1)

# timestamp is the prefix for this post
now = datetime.datetime.now()
timestamp = now.strftime('%Y.%m.%d-%H.%M.%S'.format(now))
date = now.strftime("%d/%b/%Y".format(now))

# the post title
title = sys.argv[1]
title_filtered = re.sub('[^0-9a-zA-Z]+', '_', title)


# create post files
# use / as separator
summary  =  'src/SUMMARY.md'
posts    =  'src/posts.md'
new_dir  = f'src/posts/{timestamp}'
new_file = f'src/posts/{timestamp}/{title_filtered}.md'
summary_entry = f'- [{title}](posts/{timestamp}/{title_filtered}.md)'
posts_entry = f'- [{date}: {title}](posts/{timestamp}/{title_filtered}.md)'

print('Changes:')
print(f'Create folder {new_dir}')
print(f'Create post at {new_file}')
print(f'Append an entry in summary: {summary_entry}')
print(f'Append an entry in posts: {posts_entry}')
proceed = input('proceed? [y/N] ')
if proceed != 'y' and proceed != 'Y':
    print(f'cancelled by user...')
    exit(0)

os.makedirs(new_dir)
with open(new_file,'w') as f:
    f.write(f'# {title}\n')
    f.write(f'{date}\n')

# update the SUMMARY page
with open(summary,'a') as f:
    f.write(summary_entry + '\n')

# update the POSTS page
with open(posts,'a') as f:
    f.write(posts_entry + '\n')
