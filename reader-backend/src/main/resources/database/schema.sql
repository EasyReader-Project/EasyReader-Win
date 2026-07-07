
-- ============================================
-- File: book.sql
-- ============================================

-- ============================================
-- 书籍元数据表 (book)
-- ============================================
CREATE TABLE IF NOT EXISTS book(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  file_hash TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  author TEXT,
  publisher TEXT,
  format TEXT NOT NULL CHECK(format IN ('epub', 'pdf')),
  word_count INTEGER,
  page_count INTEGER,
  local_path TEXT NOT NULL,
  file_size INTEGER,
  last_modified INTEGER,
  cover_path TEXT,
  reading_status TEXT DEFAULT 'unread' CHECK(
    reading_status IN ('unread', 'reading', 'finished')
  ),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_book_file_hash ON book(file_hash);
CREATE INDEX IF NOT EXISTS idx_book_title ON book(title);
CREATE INDEX IF NOT EXISTS idx_book_author ON book(author);
CREATE INDEX IF NOT EXISTS idx_book_status ON book(reading_status);
CREATE INDEX IF NOT EXISTS idx_book_word_count ON book(word_count);
CREATE INDEX IF NOT EXISTS idx_book_updated_at ON book(updated_at);



-- ============================================
-- File: progress.sql
-- ============================================

-- ============================================
-- 阅读进度表 (progress)
-- ============================================
CREATE TABLE IF NOT EXISTS progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER NOT NULL,
  progress_json TEXT NOT NULL,
  current_chapter_title TEXT,
  global_percent REAL CHECK(
    global_percent >= 0
    AND global_percent <= 1
  ),
  total_reading_minutes INTEGER DEFAULT 0,
  last_read_at INTEGER NOT NULL,
  FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_progress_book_id ON progress(book_id);
CREATE INDEX IF NOT EXISTS idx_progress_last_read ON progress(last_read_at);



-- ============================================
-- File: bookmark.sql
-- ============================================

-- ============================================
-- 书签/高亮表 (bookmark)
-- 记录用户标记的阅读位置，可附带高亮文本和样式
-- ============================================
CREATE TABLE IF NOT EXISTS bookmark (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    
    -- ===== 定位信息（复用 progress_json 的结构） =====
    location_json TEXT NOT NULL,
    
    -- ===== 书签内容 =====
    name TEXT,
    selected_text TEXT,
    
    -- ===== 样式属性 =====
    color TEXT,
    style TEXT DEFAULT 'highlight' CHECK(style IN ('bookmark', 'highlight', 'underline')),
    
    -- ===== 时间戳 =====
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE
);

-- 索引（名称同步改为单数）
CREATE INDEX IF NOT EXISTS idx_bookmark_book_id ON bookmark(book_id);
CREATE INDEX IF NOT EXISTS idx_bookmark_created_at ON bookmark(created_at);



-- ============================================
-- File: note.sql
-- ============================================

-- ============================================
-- 笔记/批注表 (note)
-- 记录用户的文字批注，可关联到书签，也可独立存在
-- ============================================
CREATE TABLE IF NOT EXISTS note (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    bookmark_id INTEGER,                -- 关联到单数表名 bookmark
    
    -- ===== 笔记正文 =====
    content TEXT NOT NULL,
    
    -- ===== 独立定位 =====
    location_json TEXT,
    
    -- ===== 时间戳 =====
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (bookmark_id) REFERENCES bookmark(id) ON DELETE CASCADE
);

-- 索引（名称同步改为单数）
CREATE INDEX IF NOT EXISTS idx_note_book_id ON note(book_id);
CREATE INDEX IF NOT EXISTS idx_note_bookmark_id ON note(bookmark_id);
CREATE INDEX IF NOT EXISTS idx_note_created_at ON note(created_at);


