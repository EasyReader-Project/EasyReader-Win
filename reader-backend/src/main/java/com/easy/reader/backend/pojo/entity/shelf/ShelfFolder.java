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
@TableName("shelf_folder")
public class ShelfFolder {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("shelf_id")
    private Long shelfId;

    private String uuid;

    @TableField("parent_shelf_folder_id")
    private Long parentShelfFolderId;

    private String name;

    @TableField("sort_order")
    private Integer sortOrder;

    private String icon;

    @TableField("is_expanded")
    private Boolean isExpanded;

    @TableField(fill = FieldFill.INSERT)
    private Long createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Long updatedAt;
}