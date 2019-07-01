# BibleSDK
## Bible SDK for iOS and macOS
BibleSDK is a simple framework to work with Bible texts on iOS and macOS platforms.

# Features

- Multiple Bible translations support
- Raw string into Bible text
- Fast Full Text Search support
- Verse of The Day (Daily verses grouped by similar topic)
- Build-in formatters for plain text, attributed string and HTML
- [WIP] Bible in One Year (Based on Companion by Robert Roberts)

# Installation
Using Carthage:

```sh
$ echo 'git "https://github.com/avdyushin/BibleSDK"' >> Cartfile
$ carthage update
```

# Usage

## Adding Bible Version/Translation

BibleSDK uses SQLite3 as a books/texts storage.
Schemas are described [here](https://github.com/avdyushin/bible-docker-postgres).

An additional virual table for full-text search support required as you can find [here](https://github.com/avdyushin/BibleSDK/blob/master/Addons/rst_fts_verses.sql).

### Create database files

Once you have all you `*.sql` files prepare it's time to create database file itself:

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

For now this SDK has `KJV` Bible as build-in one.

## Get Bible by Version

Use subscript to get Bible by it's Version:

```swift
let kjvBible = bible["kjv"]
```

## Get Book by Abbreviation

The same for the Books:

```swift
let kjvBible = bible["kjv"]
let genesis = kjvBible["gen"]
```

## Verses by string reference

In order to get Bible text by only string reference like `Gen 1:1` use this method:

```swift
let verses = bible.findByReference("Gen 1:1")
```

It will return 1st verse for 1st chapter of Genses book as a Dictionary with Keys as Bible Version.

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
// Create iterator on search results with 10 items by fetch
let iterator = bible.searchIterator(
    string,
    version: version,
    chunks: 10,
    surround: ("<span>", "</span>")
)
// Lazy fetch search results
let verses = iterator.next()
```
