#!/bin/sh

fpath="${fpath}"
if [ ! -z $1 ]; then
	fpath=$1
fi

# 中文用戶名 {{{0
# from http://discuss.flarum.org.cn/d/494
sed -i 's#a-z0-9_-#-_a-z0-9\\\x7f-\\\xff#' \
	${fpath}core/src/Core/Validator/UserValidator.php #註冊

sed -i 's#where('username', 'like', $username)#where('username', 'like', rawurldecode($username))#' \
	${fpath}core/src/Core/Repository/UserRepository.php #查看

# 允許@中文用戶名（Mentions插件）{{{1
sed -i 's#a-z0-9_-#-_a-zA-Z0-9\\x7f-\\xff#' \
	${fpath}flarum-ext-mentions/src/Listener/FormatPostMentions.php \
	${fpath}flarum-ext-mentions/src/Listener/FormatUserMentions.php

sed -i "s#getIdForUsername(#getIdForUsername(rawurlencode(#; /getIdForUsername/s/'))/')))/" \
	${fpath}flarum-ext-mentions/src/Listener/FormatUserMentions.php
# 1}}}
# 0}}}

# URL後的slug {{{
sed -i "s/\(id: discussion.id()\) + '-' + discussion.slug(),/\1,/" \
	${fpath}core/js/forum/dist/app.js \
	${fpath}core/js/forum/src/initializers/routes.js

sed -i "s/\('id' => \$discussion->id\) . '-' . \$discussion->attributes->slug/\1/" \
	${fpath}core/views/index.blade.php
# }}}

# 搜索 {{{
# from http://discuss.flarum.org.cn/d/603
# 無法一條寫下（建議使用patch）
sed -i "s/->whereRaw('MATCH (\`content\`) AGAINST (? IN BOOLEAN MODE)', \[\$string\])/->where('content', 'like', '%'.\$string.'%')/" \
	${fpath}core/src/Core/Search/Discussion/Fulltext/MySqlFulltextDriver.php

sed -i "/->orderByRaw('MATCH (\`content\`) AGAINST (?) DESC', \[\$string\])/d" \
	${fpath}core/src/Core/Search/Discussion/Fulltext/MySqlFulltextDriver.php
# }}}

# FontAwesome的CDN {{{
# from http://discuss.flarum.org.cn/d/603
sed -i 's#@fa-font-path: "./fonts";#@fa-font-path: "//cdn.bootcss.com/font-awesome/4.4.0/fonts";#' \
	${fpath}core/less/lib/lib.less
# }}}

# 刪除GooleFonts {{{
# from https://vivaldi.club/d/369
sed -i "/fonts.googleapis.com/d" \
	${fpath}core/views/install/app.php \
	${fpath}core/src/Http/Controller/ClientView.php \
	${fpath}core/src/Http/WebApp/WebAppView.php
# }}}
