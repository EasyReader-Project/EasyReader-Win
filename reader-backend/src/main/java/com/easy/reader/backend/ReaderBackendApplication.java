package com.easy.reader.backend;

import com.easy.reader.backend.service.BookService;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;


@SpringBootApplication
public class ReaderBackendApplication {

    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(ReaderBackendApplication.class, args);
        String portProperty = context.getEnvironment().getProperty("local.server.port");
        if(portProperty == null) {
            throw new RuntimeException("项目环境属性 'local.server.port' 未设置");
        }
        int port = Integer.parseInt(portProperty);
        System.out.println("EASYREADER_PORT=" + port);  // 关键输出行
        BookService bookService = context.getBean(BookService.class);
        bookService.importEpub("D:\\Project\\EasyReader\\EasyReader-Win\\reader-backend\\temp\\Test.epub");
    }
}
