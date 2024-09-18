package me.zoulei.dbc.ui.components.north;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;

import me.zoulei.MainApp;
import me.zoulei.dbc.ui.components.MainPanel;
import me.zoulei.dbc.ui.components.center.ExecCP;
import me.zoulei.dbc.ui.components.center.ResultsLogUI;
import me.zoulei.dbc.ui.components.orthers.VersionDialog;

/**
 * 2023年11月27日10:27:49
 * @author zoulei
 * 主面板BorderLayout 北面ui
 */
public class NorthUI extends JPanel{
	
	private static final long serialVersionUID = -8056442308975048131L;

	/**
	 * 2个数据库连接配置，用于比对
	 * 连接后展示选择数据库模式的下拉框控件
	 * @param resultsLog  比对后放日志的三个文本域
	 */
	public NorthUI(ResultsLogUI resultsLog) {
		//数据库连接放在上方 上方位置
		this.setLayout(new FlowLayout());
		
		//添加标题边框
		TitledBorder  blackline = BorderFactory.createTitledBorder("数据库配置");
		blackline.setTitleFont(new Font("黑体", Font.PLAIN,18));
		blackline.setBorder(new LineBorder(new Color(184, 207, 229),2));
		this.setBorder(blackline);
		//设置高度
		this.setPreferredSize(new Dimension(-1, 160));
		//*****************************************************************/
		
		
        
        //第1个连接之后显示模式选择的面板
        JPanel schemaSelectPanel1 = new JPanel(new FlowLayout(FlowLayout.LEFT));
        schemaSelectPanel1.setPreferredSize(new Dimension(700, 45));
        //第2个连接之后显示模式选择的面板
        JPanel schemaSelectPanel2 = new JPanel(new FlowLayout(FlowLayout.CENTER));
        schemaSelectPanel2.setPreferredSize(new Dimension(600, 45));
        
        //数据库配置的界面
        DataConnComponent dcc = new DataConnComponent(schemaSelectPanel1,"选择第1个的数据库模式：");
        //第1个数据库连接
        this.add(dcc);
        //第2个数据库连接
        DataConnComponent dcc2 = new DataConnComponent(schemaSelectPanel2,"选择第2个的数据库模式：");
        this.add(dcc2);
        dcc2.other=dcc;
        dcc.other=dcc2;
        
        
        //第一个连接之后显示模式选择的面板
        this.add(schemaSelectPanel1);
        //第二个连接之后显示模式选择的面板
        this.add(schemaSelectPanel2);
        //第三个放按钮
        JButton execButton = new JButton("执行表结构比对");
        this.add(execButton);
        execButton.addActionListener(new ActionListener() {
	         public void actionPerformed(ActionEvent e) {
	        	 ExecCP execCP = new ExecCP(dcc.schemaSelectComponent,dcc2.schemaSelectComponent,resultsLog);
	        	 execCP.start();
	         }
        });
        //放一个版本信息的按钮
        JPanel jPanel = new JPanel();
        //jPanel.setPreferredSize(new Dimension(100, 40));
        JButton about = new JButton("关于");
        jPanel.add(about);
        this.add(jPanel);
        about.addActionListener(new ActionListener() {
	         public void actionPerformed(ActionEvent e) {
	        	 Map<String,String> caipinMap = new LinkedHashMap<String,String>();
	        	 caipinMap.put("版本","测试1.0.0");
	        	 caipinMap.put("日期","2023年12月1日");
	        	 caipinMap.put("作者","邹磊");
	        	 caipinMap.put("wx","18042307016");        
	        	 String desc = "数据库表结构比对并生成相关日志。";
	        	 VersionDialog d =new VersionDialog(MainPanel.mainFrame, true,caipinMap,360,320,desc);
	        	 d.setVisible(true);
	         }
        });

        
        JButton configButton = new JButton("选择表");
        this.add(configButton);
        configButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
            	try {
					JDialog tableSelectUI = new TableSelectUI(dcc.schemaSelectComponent,dcc2.schemaSelectComponent);
				} catch (Exception e1) {
					JOptionPane.showMessageDialog(MainPanel.mainFrame, "设置失败："+e1.getMessage());
					e1.printStackTrace();
					
				}
            }
        });
        
        JButton runButton = new JButton("生成");
        this.add(runButton);
        runButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                String runSql2 = resultsLog.textAreaLog.getText();  // 获取第二组SQL
                String runSql1 = resultsLog.textAreaDDL1.getText(); // 获取第一组SQL
                String runSchemaIni = System.getProperty("user.dir") + "/replaceSchema.txt"; // 文件路径
                File file = new File(runSchemaIni);

                if (file.exists()) {
                    String schema1 = dcc.schemaSelectComponent.selectSchema; // 获取方案名
                    String currentDate = new SimpleDateFormat("yyyyMMdd").format(new Date()); // 当前日期
                    String outputFileName = schema1 + "同步" + currentDate + ".sql"; // 输出文件名
                    File outputFile = new File(System.getProperty("user.dir") + "/syncSql/" + outputFileName);

                    try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile))) {
                        // 将原始的runSql1和runSql2写入文件
                        writer.write("-- Original SQL Statements\n");
                        writer.write(runSql1);
                        writer.newLine();
                        writer.write(runSql2);
                        writer.newLine();
                        
                        // 读取replaceSchema.txt文件中的每行方案名后缀
                        List<String> schemaSuffixes = Files.readAllLines(Paths.get(runSchemaIni), StandardCharsets.UTF_8);

                        // 循环替换runSql1和runSql2中的方案名，并写入文件
                        for (String suffix : schemaSuffixes) {
                            String modifiedRunSql1 = runSql1.replace(schema1, schema1 + suffix);
                            String modifiedRunSql2 = runSql2.replace(schema1, schema1 + suffix);

                            writer.write("-- SQL Statements for schema: " + schema1 + suffix + "\n");
                            writer.write(modifiedRunSql1);
                            writer.newLine();
                            writer.write(modifiedRunSql2);
                            writer.newLine();
                        }

                        // 提示完成
                        JOptionPane.showMessageDialog(null, "同步方案生成完成，文件已保存到: " + outputFile.getAbsolutePath());
                    } catch (IOException ex) {
                        ex.printStackTrace();
                        JOptionPane.showMessageDialog(null, "文件生成过程中发生错误！");
                    }
                } else {
                    JOptionPane.showMessageDialog(null, "replaceSchema.txt 文件不存在！");
                }
            }
        });
	}

}
