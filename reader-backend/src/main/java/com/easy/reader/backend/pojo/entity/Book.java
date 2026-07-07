package com.easy.reader.backend.pojo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.experimental.Accessors;

@Data
@AllArgsConstructor
@Accessors(chain = true)
@TableName("book")
public class Book {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String fileHash;

    private String title;

    private String author;

    private String publisher;

    private String fileType;

    private Integer wordCount;

    private Integer pageCount;

    private String localPath;

    private Long fileSize;

    private Long lastModified;

    private String coverPath;

    private String readingStatus;

    @TableField(fill = FieldFill.INSERT)
    private Long createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updatedAt;
}