# BibleSDK
## Bible SDK for iOS and macOS
BibleSDK is a simple framework to work with Bible texts on iOS and macOS platforms.

# Features

- Multiple Bible translations support
- Verses parser from raw string to Bible texts
- Fast full text search
- Daily verses
- [WIP] Bible in one year daily readings

# Installation
Using Carthage:

```sh
$ echo 'git "https://github.com/avdyushin/BibleSDK"' >> Cartfile
$ carthage update
```

# Usage

## Adding Bible Version/Translation

BibleSDK uses SQLite3 as a books/texts storage.
Schemas are described in this [repo](https://github.com/avdyushin/bible-docker-postgres).

Apart with base sql files here is addon virual table for full-text search support should be creates.
Here is [example](https://github.com/avdyushin/BibleSDK/blob/master/Addons/rst_fts_verses.sql).

### Create database files

```sh
sqlite3 niv.db < niv_bible_books.sql # books tables and data
sqlite3 niv.db < niv_bible_verses_table.sql # verses tables
sqlite3 niv.db < niv_fts_verses.sql # vitual verses tables
sqlite3 niv.db < niv_bible_verses_data.sql # verses data
```

## Loading Custom Bible Version

```swift
import BibleSDK

let bible = BibleSDK()
let path = Bundle(for: type(of: self)).path(forResource: "niv", ofType: "db")!
try! bible.load(version: Version("niv"), filename: path)
```

## List loaded Bible Versions

```swift
let versions = bible.availableVersion
```

## Get Bible by Version

```swift
let kjvBible = bible["kjv"]
```

## Get Book by Abbreviation

```swift
let kjvBible = bible["kjv"]
let genesis = kjvBible["gen"]
```

## Verses by string reference

```swift
let verses = bible.findByReference("Gen 1:1")
```

## Fetching Daily Verses

```swift
let daily = bible.dailyReading(Date(), version: "niv")
```

## Search by string

```swift
let string = "For GOD"

// Get first matching translation
guard
    let (version, total) = bible.searchCount(string).first(where: { $0.value > 0 }),
    total > 0 else {
        return
}
// Create iterator on search results with 10 item by fetch
let iterator = bible.searchIterator(
    string,
    version: version,
    chunks: 10,
    surround: ("<span>", "</span>")
)
// Lazy fetch search results
let verses = iterator.next()
```
