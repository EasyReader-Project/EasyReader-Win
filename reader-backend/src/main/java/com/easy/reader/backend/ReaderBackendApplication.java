package com.easy.reader.backend;

import com.easy.reader.backend.service.BookService;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;


@SpringBootApplication
public class ReaderBackendApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(ReaderBackendApplication.class, args);
        int port = context.getEnvironment().getProperty("local.server.port", Integer.class);
        System.out.println("EASYREADER_PORT=" + port);  // 关键输出行
        BookService bookService = context.getBean(BookService.class);
        bookService.importBook("D:\\Project\\EasyReader\\EasyReader-Win\\reader-backend\\temp\\Test.epub");
    }
}
