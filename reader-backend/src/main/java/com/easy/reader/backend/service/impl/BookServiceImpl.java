package com.easy.reader.backend.service.impl;

import com.easy.reader.backend.exception.NoSuchBookFile;
import com.easy.reader.backend.service.BookService;
import lombok.RequiredArgsConstructor;
import nl.siegmann.epublib.domain.Book;
import nl.siegmann.epublib.domain.Metadata;
import nl.siegmann.epublib.domain.Resource;
import nl.siegmann.epublib.domain.Spine;
import nl.siegmann.epublib.domain.TOCReference;
import nl.siegmann.epublib.domain.TableOfContents;
import nl.siegmann.epublib.epub.EpubReader;
import org.springframework.stereotype.Service;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class BookServiceImpl implements BookService {

    @Override
    public Book importBook(String filePath) {
        try (InputStream fis = new FileInputStream(filePath)) {
            EpubReader reader = new EpubReader();
            Book book = reader.readEpub(fis);

            // 提取元数据
            Metadata metadata = book.getMetadata();
            System.out.println("书名: " + metadata.getFirstTitle());
            System.out.println("作者: " + metadata.getAuthors());

            // 构建资源href -> 标题映射（从目录中提取）
            Map<String, String> titleMap = new HashMap<>();
            TableOfContents toc = book.getTableOfContents();
            for (TOCReference ref : toc.getTocReferences()) {
                buildTitleMap(ref, titleMap);
            }

            // 资源统计
            System.out.println("总资源数: " + book.getResources().size());
            Spine spine = book.getSpine();
            System.out.println(" spine资源数: " + spine.size());

            // 遍历Spine，输出资源标题
            for (int i = 0; i < spine.size(); i++) {
                Resource resource = spine.getResource(i);
                String href = resource.getHref();
                String title = titleMap.getOrDefault(href, null);
                System.out.println("  - 资源 " + (i + 1) + ": " + title);
            }

            return book;

        } catch (IOException e) {
            throw new NoSuchBookFile(filePath, e.getMessage());
        } catch (Exception e) {
            throw new NoSuchBookFile(filePath, "EPUB 解析失败: " + e.getMessage());
        }
    }

    private void buildTitleMap(TOCReference ref, Map<String, String> titleMap) {
        Resource res = ref.getResource();
        if (res != null) {
            String href = res.getHref();
            if (!titleMap.containsKey(href)) {
                titleMap.put(href, ref.getTitle());
            }
        }
        for (TOCReference child : ref.getChildren()) {
            buildTitleMap(child, titleMap);
        }
    }
}