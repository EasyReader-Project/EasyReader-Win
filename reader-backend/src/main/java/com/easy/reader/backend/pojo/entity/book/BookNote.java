package com.easy.reader.backend.pojo.entity.book;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * @author ：Star
 * @description ：无描述
 * @date ：2026 7月 12 17:25
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@TableName("book_note")
public class BookNote {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("book_id")
    private Long bookId;

    @TableField("book_mark_id")
    private Long bookMarkId;

    private String content;

    @TableField("location_json")
    private String locationJson;

    @TableField(fill = FieldFill.INSERT)
    private Long createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updatedAt;
}