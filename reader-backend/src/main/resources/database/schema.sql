
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
-- File: folder.sql
-- ============================================

-- ============================================
-- 文件夹表 (folder)
-- 支持多级嵌套，属于某个书架
-- ============================================
CREATE TABLE IF NOT EXISTS folder (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shelf_id INTEGER NOT NULL,           -- 所属书架
    
    -- 跨设备唯一标识（便于同步时合并）
    uuid TEXT UNIQUE NOT NULL,
    
    -- 父子关系（自引用）
    parent_folder_id INTEGER,            -- 父文件夹 ID，NULL 表示根目录
    
    -- 基本信息
    name TEXT NOT NULL,                  -- 文件夹名称
    sort_order INTEGER DEFAULT 0,        -- 在父目录下的排序位置
    
    -- 可选扩展
    icon TEXT,                           -- 自定义图标（如 📚 或 emoji）
    is_expanded BOOLEAN DEFAULT 1,       -- UI 默认是否展开（仅客户端状态，同步时可选）
    
    -- 时间戳
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    
    FOREIGN KEY (shelf_id) REFERENCES shelf(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_folder_id) REFERENCES folder(id) ON DELETE CASCADE  -- 删除父文件夹时级联删除子文件夹
);

CREATE INDEX IF NOT EXISTS idx_folder_shelf_id ON folder(shelf_id);
CREATE INDEX IF NOT EXISTS idx_folder_parent ON folder(parent_folder_id);
CREATE INDEX IF NOT EXISTS idx_folder_uuid ON folder(uuid);



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
-- File: shelf.sql
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
-- File: shelf_item.sql
-- ============================================

-- ============================================
-- 书架书籍映射表 (shelf_item)
-- 将 book 表中的书籍关联到具体的书架和文件夹
-- ============================================
CREATE TABLE IF NOT EXISTS shelf_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shelf_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,            -- 关联 book 表
    
    -- 定位（可选）：书籍可以放在根目录（folder_id = NULL），或放入某个文件夹
    folder_id INTEGER,
    
    -- 排序与状态
    sort_order INTEGER DEFAULT 0,        -- 在当前文件夹内的排序位置
    is_archived BOOLEAN DEFAULT 0,       -- 是否归档（隐藏但保留在书架中，不影响删除）
    
    -- 自定义备注（可选）
    notes TEXT,                          -- 用户对该书籍在此书架中的备注（如“待二刷”）
    
    -- 时间戳
    added_at INTEGER NOT NULL,           -- 加入书架的时间
    updated_at INTEGER NOT NULL,
    
    FOREIGN KEY (shelf_id) REFERENCES shelf(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (folder_id) REFERENCES folder(id) ON DELETE SET NULL,  -- 删除文件夹时，书籍移至根目录
    
    -- 约束：同一书架的同一本书只能出现一次
    UNIQUE(shelf_id, book_id)
);

CREATE INDEX IF NOT EXISTS idx_shelf_item_shelf ON shelf_item(shelf_id);
CREATE INDEX IF NOT EXISTS idx_shelf_item_book ON shelf_item(book_id);
CREATE INDEX IF NOT EXISTS idx_shelf_item_folder ON shelf_item(folder_id);
CREATE INDEX IF NOT EXISTS idx_shelf_item_archived ON shelf_item(is_archived);


