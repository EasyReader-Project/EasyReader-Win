package com.easy.reader.backend.pojo.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("note")
public class Note {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("book_id")
    private Long bookId;

    /**
     * 可选关联的书签 ID
     */
    @TableField("bookmark_id")
    private Long bookmarkId;

    /**
     * 笔记正文（不能为空）
     */
    private String content;

    /**
     * 独立定位 JSON（当不关联书签时使用）
     */
    @TableField("location_json")
    private String locationJson;

    @TableField("created_at")
    private Long createdAt;

    @TableField("updated_at")
    private Long updatedAt;
}
