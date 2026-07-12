package com.easy.reader.backend.pojo.entity.book;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * @author ：Star
 * @description ：无描述
 * @date ：2026 7月 12 17:51
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@TableName("book")
public class Book {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("file_hash")
    private String fileHash;

    private String title;

    private String author;

    private String publisher;

    @TableField("file_type")
    private String fileType;

    @TableField("word_count")
    private Integer wordCount;

    @TableField("page_count")
    private Integer pageCount;

    @TableField("local_path")
    private String localPath;

    @TableField("file_size")
    private Long fileSize;

    @TableField("last_modified")
    private Long lastModified;

    @TableField("cover_path")
    private String coverPath;

    @TableField("reading_status")
    private String readingStatus;

    @TableField(fill = FieldFill.INSERT)
    private Long createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updatedAt;
}