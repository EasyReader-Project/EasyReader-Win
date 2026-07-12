
-- ============================================
-- File: book\book.sql
-- ============================================

-- ============================================
-- 书籍元数据表 (book)
-- 存储所有书籍的基本信息（去重，通过 file_hash 唯一）
-- ============================================
CREATE TABLE IF NOT EXISTS book (
    id INTEGER PRIMARY KEY AUTOINCREMENT,            -- 自增主键
    file_hash TEXT UNIQUE NOT NULL,                  -- 文件 SHA-256 哈希值（唯一标识）
    title TEXT NOT NULL,                             -- 书名
    author TEXT,                                     -- 作者
    publisher TEXT,                                  -- 出版社
    file_type TEXT NOT NULL CHECK(file_type IN ('epub', 'pdf', 'txt', 'doc', 'docx')), -- 书籍格式
    word_count INTEGER,                              -- 总字数
    page_count INTEGER,                              -- 总页数
    local_path TEXT NOT NULL,                        -- 本地文件路径
    file_size INTEGER,                               -- 文件大小（字节）
    last_modified INTEGER,                           -- 文件修改时间戳（毫秒）
    cover_path TEXT,                                 -- 封面图片路径（仅本端）
    reading_status TEXT DEFAULT 'unread' CHECK(reading_status IN ('unread', 'reading', 'finished')), -- 阅读状态
    created_at INTEGER NOT NULL,                     -- 记录创建时间戳（毫秒）
    updated_at INTEGER NOT NULL                      -- 记录更新时间戳（毫秒）
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
-- 记录用户标记的阅读位置，可附带高亮文本和样式
-- ============================================
CREATE TABLE IF NOT EXISTS book_mark (
    id INTEGER PRIMARY KEY AUTOINCREMENT,            -- 自增主键
    book_id INTEGER NOT NULL,                        -- 所属书籍 ID（外键 → book.id）
    location_json TEXT NOT NULL,                     -- 定位信息（JSON，结构与 progress 一致）
    name TEXT,                                       -- 用户自定义名称（可选）
    selected_text TEXT,                              -- 选中的高亮文本（纯文本）
    color TEXT,                                      -- 高亮颜色（十六进制，如 #FFCC00）
    style TEXT DEFAULT 'highlight' CHECK(style IN ('bookmark', 'highlight', 'underline')), -- 样式类型
    created_at INTEGER NOT NULL,                     -- 创建时间戳（毫秒）
    updated_at INTEGER NOT NULL,                     -- 更新时间戳（毫秒）
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_book_mark_book_id ON book_mark(book_id);
CREATE INDEX IF NOT EXISTS idx_book_mark_created_at ON book_mark(created_at);



-- ============================================
-- File: book\book_note.sql
-- ============================================

-- ============================================
-- 笔记/批注表 (book_note)
-- 用户的文字批注，可依附书签或独立存在
-- ============================================
CREATE TABLE IF NOT EXISTS book_note (
    id INTEGER PRIMARY KEY AUTOINCREMENT,            -- 自增主键
    book_id INTEGER NOT NULL,                        -- 所属书籍 ID（外键 → book.id）
    book_mark_id INTEGER,                            -- 关联的书签 ID（外键 → book_mark.id，可为 NULL）
    content TEXT NOT NULL,                           -- 笔记正文（纯文本或 Markdown）
    location_json TEXT,                              -- 独立定位（仅当 book_mark_id 为空时使用）
    created_at INTEGER NOT NULL,                     -- 创建时间戳（毫秒）
    updated_at INTEGER NOT NULL,                     -- 更新时间戳（毫秒）
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (book_mark_id) REFERENCES book_mark(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_book_note_book_id ON book_note(book_id);
CREATE INDEX IF NOT EXISTS idx_book_note_book_mark_id ON book_note(book_mark_id);
CREATE INDEX IF NOT EXISTS idx_book_note_created_at ON book_note(created_at);



-- ============================================
-- File: book\book_progress.sql
-- ============================================

-- ============================================
-- 阅读进度表 (book_progress)
-- 记录用户在书籍中的精确阅读位置
-- ============================================
CREATE TABLE IF NOT EXISTS book_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,            -- 自增主键
    book_id INTEGER NOT NULL,                        -- 所属书籍 ID（外键 → book.id）
    progress_json TEXT NOT NULL,                     -- 完整进度数据（JSON，包含 location, percent 等）
    current_chapter_title TEXT,                      -- 当前章节标题（冗余，便于展示）
    global_percent REAL CHECK(global_percent >= 0 AND global_percent <= 1), -- 全局阅读百分比（0~1）
    total_reading_minutes INTEGER DEFAULT 0,         -- 累计阅读时长（分钟）
    last_read_at INTEGER NOT NULL,                   -- 最后阅读时间戳（毫秒）
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_book_progress_book_id ON book_progress(book_id);
CREATE INDEX IF NOT EXISTS idx_book_progress_last_read ON book_progress(last_read_at);



-- ============================================
-- File: shelf\shelf.sql
-- ============================================

-- ============================================
-- 书架元数据表 (shelf)
-- 同步的顶层单元，一个书架包含独立的文件夹树和书籍映射
-- ============================================
CREATE TABLE IF NOT EXISTS shelf (
    id INTEGER PRIMARY KEY AUTOINCREMENT,      -- 自增主键
    uuid TEXT UNIQUE NOT NULL,                 -- 跨设备唯一标识（UUID）
    name TEXT NOT NULL,                        -- 书架名称（如“我的小说”）
    cover_path TEXT,                           -- 书架自定义封面路径（可选）
    sort_order INTEGER DEFAULT 0,              -- 在书架列表中的排序位置
    is_default BOOLEAN DEFAULT 0,              -- 是否为默认书架（通常只有一个默认）
    last_sync_at INTEGER,                      -- 上次同步时间戳（毫秒）
    created_at INTEGER NOT NULL,               -- 创建时间戳（毫秒）
    updated_at INTEGER NOT NULL                -- 更新时间戳（毫秒）
);

CREATE INDEX IF NOT EXISTS idx_shelf_uuid ON shelf(uuid);
CREATE INDEX IF NOT EXISTS idx_shelf_default ON shelf(is_default);



-- ============================================
-- File: shelf\shelf_folder.sql
-- ============================================

-- ============================================
-- 书架文件夹表 (shelf_folder)
-- 支持多级嵌套文件夹，属于某个书架
-- ============================================
CREATE TABLE IF NOT EXISTS shelf_folder (
    id INTEGER PRIMARY KEY AUTOINCREMENT,           -- 自增主键
    shelf_id INTEGER NOT NULL,                      -- 所属书架 ID（外键 → shelf.id）
    uuid TEXT UNIQUE NOT NULL,                      -- 跨设备唯一标识（UUID）
    parent_shelf_folder_id INTEGER,                 -- 父文件夹 ID，NULL 表示根目录（自引用 → shelf_folder.id）
    name TEXT NOT NULL,                             -- 文件夹名称
    sort_order INTEGER DEFAULT 0,                   -- 在父目录下的排序位置
    icon TEXT,                                      -- 自定义图标（如 📚 或 emoji）
    is_expanded BOOLEAN DEFAULT 1,                  -- UI 默认是否展开（客户端状态）
    created_at INTEGER NOT NULL,                    -- 创建时间戳（毫秒）
    updated_at INTEGER NOT NULL,                    -- 更新时间戳（毫秒）
    FOREIGN KEY (shelf_id) REFERENCES shelf(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_shelf_folder_id) REFERENCES shelf_folder(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_shelf_folder_shelf_id ON shelf_folder(shelf_id);
CREATE INDEX IF NOT EXISTS idx_shelf_folder_parent ON shelf_folder(parent_shelf_folder_id);
CREATE INDEX IF NOT EXISTS idx_shelf_folder_uuid ON shelf_folder(uuid);



-- ============================================
-- File: shelf\shelf_item.sql
-- ============================================

-- ============================================
-- 书架书籍映射表 (shelf_item)
-- 将 book 表中的书籍关联到具体的书架和文件夹
-- ============================================
CREATE TABLE IF NOT EXISTS shelf_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,     -- 自增主键
    shelf_id INTEGER NOT NULL,                -- 所属书架 ID（外键 → shelf.id）
    book_id INTEGER NOT NULL,                 -- 关联书籍 ID（外键 → book.id）
    shelf_folder_id INTEGER,                  -- 所属文件夹 ID，NULL 表示根目录（外键 → shelf_folder.id）
    sort_order INTEGER DEFAULT 0,             -- 在当前文件夹内的排序位置
    is_archived BOOLEAN DEFAULT 0,            -- 是否归档（隐藏但保留，不影响删除）
    notes TEXT,                               -- 用户备注（如“待二刷”）
    added_at INTEGER NOT NULL,                -- 加入书架的时间戳（毫秒）
    updated_at INTEGER NOT NULL,              -- 更新时间戳（毫秒）
    FOREIGN KEY (shelf_id) REFERENCES shelf(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE CASCADE,
    FOREIGN KEY (shelf_folder_id) REFERENCES shelf_folder(id) ON DELETE SET NULL,
    UNIQUE(shelf_id, book_id)                 -- 同一书架的同一本书只能出现一次
);

CREATE INDEX IF NOT EXISTS idx_shelf_item_shelf ON shelf_item(shelf_id);
CREATE INDEX IF NOT EXISTS idx_shelf_item_book ON shelf_item(book_id);
CREATE INDEX IF NOT EXISTS idx_shelf_item_folder ON shelf_item(shelf_folder_id);
CREATE INDEX IF NOT EXISTS idx_shelf_item_archived ON shelf_item(is_archived);


