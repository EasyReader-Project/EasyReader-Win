package com.easy.reader.backend.service.impl;

import com.easy.reader.backend.pojo.entity.Book;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BookServiceImpl implements BookService{
    @Override
    public Book importBook(String filePath) {
        return null;
    }
}
