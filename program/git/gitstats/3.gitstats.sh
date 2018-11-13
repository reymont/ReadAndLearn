

### 1 安装
yum install -y gitstats
### 2 帮助手册
man gitstats
gitstats
# Usage: gitstats [options] <gitpath..> <outputpath>

# Options:
# -c key=value     Override configuration value

# Default config values:
# {'linear_linestats': 1, 'style': 'gitstats.css', 'commit_end': 'HEAD', 'max_authors': 20, 'commit_begin': '', 'max_ext_length': 10, 'project_name': '', 'authors_top': 5, 'merge_authors': {}, 'max_domains': 10}

# Please see the manual page for more details.
EXAMPLES
       Generates statistics from a git repository in "foo" and outputs the result in a directory "foo_stats":
             gitstats foo foo_stats

       As above, but only analyzes the last 10 commits:
             gitstats -c commit_begin='HEAD~10' foo foo_stats