package com.easy.reader.backend.service;


import com.easy.reader.backend.pojo.entity.book.Book;

/**
 * 处理所有与图书本身有关的功能，如图书导入
 */

public interface BookService {
    /**
     * 根据文件路径导入Book
     * @param filePath 文件路径
     * @return 返回图书对象
     */
    Book importEpub(String filePath);
}
