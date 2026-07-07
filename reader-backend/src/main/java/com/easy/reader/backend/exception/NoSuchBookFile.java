package com.easy.reader.backend.exception;

/**
 * 表示访问Book文件时，发现无法找到该文件
 */
public class NoSuchBookFile extends RuntimeException {

    public NoSuchBookFile() {
        super();
    }

    public NoSuchBookFile(String filePath, String message) {
        super(String.format("目标Book不存在：%s\n%s", filePath, message));
    }
}
