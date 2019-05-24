DROP TABLE IF EXISTS kjv_bible_index;

CREATE VIRTUAL TABLE kjv_bible_index USING fts5(book_id, chapter, verse, text, tokenize=porter);

CREATE TRIGGER after_kjv_bible_insert AFTER INSERT ON kjv_bible BEGIN
    INSERT INTO kjv_bible_index (book_id, chapter, verse, text) VALUES
        (new.book_id, new.chapter, new.verse, new.text);
END;
