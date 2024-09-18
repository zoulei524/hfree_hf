	//接口
	List<Map<String, Object>> initCodeType(String codeType, String filter);
	List<${entity}> get${entity}List(JSONObject pageData);
<#if config.iscrud>
	public ${entity} get${entity}InfoById(String ${config.pk});
	public void save${entity}Info(JSONObject ${tablename}form);
	public void delete${entity}ById(String ${config.pk});
</#if>
<#if config.exportExcel>
	public String export${entity}Excel(JSONObject pageData) throws AppException;
</#if>
	
	
