
-- ============================================
-- File: book\book.sql
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
  -- //TODO: 应补充其他分类
  file_type TEXT NOT NULL CHECK(file_type IN ('epub', 'pdf','txt','doc','docx')),
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
-- File: book\book_mark.sql
-- ============================================

-- ============================================
-- 书签/高亮表 (book_mark)
-- ============================================
CREATE TABLE IF NOT EXISTS book_mark (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    location_json TEXT NOT NULL,
    name TEXT,
    selected_text TEXT,
    color TEXT,
    style TEXT DEFAULT 'highlight' CHECK(style IN ('bookmark', 'highlight', 'underline')),
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE
);

CREATE INDEX idx_book_mark_book_id ON book_mark(book_id);
CREATE INDEX idx_book_mark_created_at ON book_mark(created_at);



-- ============================================
-- File: book\book_note.sql
-- ============================================

-- ============================================
-- 笔记/批注表 (book_note)
-- ============================================
CREATE TABLE IF NOT EXISTS book_note (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    book_mark_id INTEGER,
    content TEXT NOT NULL,
    location_json TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (book_mark_id) REFERENCES book_mark(id) ON DELETE CASCADE
);

CREATE INDEX idx_book_note_book_id ON book_note(book_id);
CREATE INDEX idx_book_note_book_mark_id ON book_note(book_mark_id);
CREATE INDEX idx_book_note_created_at ON book_note(created_at);



-- ============================================
-- File: book\book_progress.sql
-- ============================================

-- ============================================
-- 阅读进度表 (book_progress)
-- ============================================
CREATE TABLE IF NOT EXISTS book_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    progress_json TEXT NOT NULL,
    current_chapter_title TEXT,
    global_percent REAL CHECK(global_percent >= 0 AND global_percent <= 1),
    total_reading_minutes INTEGER DEFAULT 0,
    last_read_at INTEGER NOT NULL,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE
);

CREATE INDEX idx_book_progress_book_id ON book_progress(book_id);
CREATE INDEX idx_book_progress_last_read ON book_progress(last_read_at);



-- ============================================
-- File: shelf\shelf.sql
-- ============================================

-- ============================================
-- 书架元数据表 (shelf)
-- 同步的顶层单元，一个书架包含独立的文件夹树和书籍映射
-- ============================================
CREATE TABLE IF NOT EXISTS shelf (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- 跨设备唯一标识（使用 UUID，便于多端合并）
    uuid TEXT UNIQUE NOT NULL,
    
    -- 基本信息
    name TEXT NOT NULL,                  -- 书架名称（如“我的小说”）
    cover_path TEXT,                     -- 书架自定义封面（可选）
    
    -- 排序与展示
    sort_order INTEGER DEFAULT 0,        -- 在书架列表中的排序位置
    
    -- 同步与状态
    is_default BOOLEAN DEFAULT 0,        -- 是否为默认书架（通常只有一个默认）
    last_sync_at INTEGER,                -- 上次同步时间戳（毫秒）
    
    -- 时间戳
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_shelf_uuid ON shelf(uuid);
CREATE INDEX IF NOT EXISTS idx_shelf_default ON shelf(is_default);



-- ============================================
-- File: shelf\shelf_folder.sql
-- ============================================

-- ============================================
-- 书架文件夹表 (shelf_folder)
-- ============================================
CREATE TABLE IF NOT EXISTS shelf_folder (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shelf_id INTEGER NOT NULL,
    uuid TEXT UNIQUE NOT NULL,
    parent_shelf_folder_id INTEGER,
    name TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    icon TEXT,
    is_expanded BOOLEAN DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (shelf_id) REFERENCES shelf(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_shelf_folder_id) REFERENCES shelf_folder(id) ON DELETE CASCADE
);

CREATE INDEX idx_shelf_folder_shelf_id ON shelf_folder(shelf_id);
CREATE INDEX idx_shelf_folder_parent ON shelf_folder(parent_shelf_folder_id);
CREATE INDEX idx_shelf_folder_uuid ON shelf_folder(uuid);



-- ============================================
-- File: shelf\shelf_item.sql
-- ============================================

-- ============================================
-- 书架书籍映射表 (shelf_item)
-- ============================================
CREATE TABLE IF NOT EXISTS shelf_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shelf_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    shelf_folder_id INTEGER,
    sort_order INTEGER DEFAULT 0,
    is_archived BOOLEAN DEFAULT 0,
    notes TEXT,
    added_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (shelf_id) REFERENCES shelf(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (shelf_folder_id) REFERENCES shelf_folder(id) ON DELETE SET NULL,
    UNIQUE(shelf_id, book_id)
);

CREATE INDEX idx_shelf_item_shelf ON shelf_item(shelf_id);
CREATE INDEX idx_shelf_item_book ON shelf_item(book_id);
CREATE INDEX idx_shelf_item_folder ON shelf_item(shelf_folder_id);
CREATE INDEX idx_shelf_item_archived ON shelf_item(is_archived);


