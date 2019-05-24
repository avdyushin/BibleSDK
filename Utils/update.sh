#!/bin/sh

sqlite3 ../BibleSDK/Sources/Data/kjv_daily.db < ../Data/data/kjv_bible_daily_roberts.sql
sqlite3 ../BibleSDK/Sources/Data/kjv_daily.db < ../Data/data/kjv_bible_daily_verses.sql

sqlite3 ../BibleSDK/Sources/Data/kjv.db < ../Data/data/kjv_bible_books.sql
sqlite3 ../BibleSDK/Sources/Data/kjv.db < ../Data/data/kjv_bible_verses_table.sql
sqlite3 ../BibleSDK/Sources/Data/kjv.db < ../Addons/kjv_fts_verses.sql
sqlite3 ../BibleSDK/Sources/Data/kjv.db < ../Data/data/kjv_bible_verses_data.sql

sqlite3 ../BibleSDK/BibleSDK\ iOS\ Tests/Resources/rst.db < ../Data/data/rst_bible_books.sql
sqlite3 ../BibleSDK/BibleSDK\ iOS\ Tests/Resources/rst.db < ../Data/data/rst_bible_verses_data.sql
sqlite3 ../BibleSDK/BibleSDK\ iOS\ Tests/Resources/rst.db < ../Addons/rst_fts_verses.sql
sqlite3 ../BibleSDK/BibleSDK\ iOS\ Tests/Resources/rst.db < ../Data/data/rst_bible_verses_table.sql
