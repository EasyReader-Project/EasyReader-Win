package com.easy.reader.backend.pojo.entity.shelf;

import com.baomidou.mybatisplus.annotation.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

/**
 * @author ：Star
 * @description ：无描述
 * @date ：2026 7月 12 17:24
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@Accessors(chain = true)
@TableName("shelf_item")
public class ShelfItem {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("shelf_id")
    private Long shelfId;

    @TableField("book_id")
    private Long bookId;

    @TableField("shelf_folder_id")
    private Long shelfFolderId;

    @TableField("sort_order")
    private Integer sortOrder;

    @TableField("is_archived")
    private Boolean isArchived;

    private String notes;

    @TableField("added_at")
    private Long addedAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updatedAt;
}