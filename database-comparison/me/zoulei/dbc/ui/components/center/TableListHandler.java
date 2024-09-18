package me.zoulei.dbc.ui.components.center;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.gson.reflect.TypeToken;

import lombok.extern.log4j.Log4j;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;

@Log4j
public class TableListHandler {

    // 保存databaselist到文件，使用UTF-8编码
    public static void saveTableList(List<HashMap<String, String>> databaselist, String fileName) {
        Gson gson = new Gson();
        try (Writer writer = new OutputStreamWriter(new FileOutputStream(fileName), StandardCharsets.UTF_8)) {
            gson.toJson(databaselist, writer);
            log.info("写入库结构方案：" + fileName);
        } catch (IOException e) {
            log.error("写入库结构方案失败：" + fileName, e);
        }
    }

    // 保存databaselist到文件，使用UTF-8编码
    public static void saveTableCreate(HashMap<String, String> databaseCreate, String fileName) {
        Gson gson = new Gson();
        try (Writer writer = new OutputStreamWriter(new FileOutputStream(fileName), StandardCharsets.UTF_8)) {
            gson.toJson(databaseCreate, writer);
            log.info("写入库结构方案：" + fileName);
        } catch (IOException e) {
            log.error("写入库结构方案失败：" + fileName, e);
        }
    }
    
    public static HashMap<String, String> loadTableCreate(String fileName) {
        Gson gson = new Gson();
        try (Reader reader = new InputStreamReader(new FileInputStream(fileName), StandardCharsets.UTF_8)) {
            // 尝试将 JSON 文件解析为一个 HashMap 对象
            HashMap<String, String> databaseCreate = gson.fromJson(reader, new TypeToken<HashMap<String, String>>(){}.getType());
            
            log.info("读取库结构方案：" + fileName);
            return databaseCreate;
        } catch (JsonSyntaxException e) {
            // 如果 JSON 文件格式不匹配，打印错误信息
            log.error("JSON 语法错误，读取库结构方案失败：" + fileName, e);
            return null;
        } catch (IOException e) {
            log.error("读取库结构方案失败：" + fileName, e);
            return null;
        }
    }


    // 从文件中加载databaselist，使用UTF-8编码
    public static List<HashMap<String, String>> loadTableList(String fileName) {
        Gson gson = new Gson();
        try (Reader reader = new InputStreamReader(new FileInputStream(fileName), StandardCharsets.UTF_8)) {
            log.info("读取库结构方案：" + fileName);
            return gson.fromJson(reader, new TypeToken<List<HashMap<String, String>>>(){}.getType());
        } catch (FileNotFoundException e) {
            log.error("库结构方案文件未找到：" + fileName);
            return null;
        } catch (IOException e) {
            log.error("库结构方案读取失败：" + fileName, e);
            return null;
        }
    }
}
