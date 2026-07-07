package com.easy.reader.backend.pojo.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@TableName("progress")
public class Progress {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("book_id")
    private Long bookId;

    /**
     * 进度 JSON（与 Android 端互通）
     */
    @TableField("progress_json")
    private String progressJson;

    @TableField("current_chapter_title")
    private String currentChapterTitle;

    /**
     * 全局百分比，0.0 ~ 1.0
     */
    @TableField("global_percent")
    private Double globalPercent;

    @TableField("total_reading_minutes")
    private Integer totalReadingMinutes;

    @TableField("last_read_at")
    private Long lastReadAt;
}
