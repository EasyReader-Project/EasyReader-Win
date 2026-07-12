package com.easy.reader.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.easy.reader.backend.pojo.entity.book.Book;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BookMapper extends BaseMapper<Book> {
}
