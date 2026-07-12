package com.easy.reader.backend.pojo.entity.book;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * @author ：Star
 * @description ：无描述
 * @date ：2026 7月 12 17:26
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@TableName("book_progress")
public class BookProgress {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("book_id")
    private Long bookId;

    @TableField("progress_json")
    private String progressJson;

    @TableField("current_chapter_title")
    private String currentChapterTitle;

    @TableField("global_percent")
    private Double globalPercent;

    @TableField("total_reading_minutes")
    private Integer totalReadingMinutes;

    @TableField("last_read_at")
    private Long lastReadAt;
}