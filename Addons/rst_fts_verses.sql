DROP TABLE IF EXISTS rst_bible_index;

CREATE VIRTUAL TABLE rst_bible_index USING fts5(book_id, chapter, verse, text, tokenize=porter);

CREATE TRIGGER after_rst_bible_insert AFTER INSERT ON rst_bible BEGIN
    INSERT INTO rst_bible_index (book_id, chapter, verse, text) VALUES
        (new.book_id, new.chapter, new.verse, new.text);
END;
