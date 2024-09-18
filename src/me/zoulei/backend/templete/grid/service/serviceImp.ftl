	
	@Autowired
	HYBeanUtil hybean;
	
	//实现类
	/**
	 * 获取代码
	 */
	@Override
	public List<Map<String, Object>> initCodeType(String codeType, String filter) {
		return dao.initCodeType(codeType, filter);
	}
	
	/**
	 * ====================================================================================================
	 * 方法名称: ${tablecomment}--列表<br>
	 * 方法创建日期: ${time}<br>
	 * 方法创建人员: ${author}<br>
	 * 方法维护信息: <br>
	 * 方法: ●原创○沿用○重构汇
	 * ====================================================================================================
	 */
	@Override
	public List<${entity}> get${entity}List(JSONObject pageData) {
	    List<${entity}> ${tablename}List = dao.get${entity}List(pageData);
	    return ${tablename}List;
	}

<#if config.iscrud>	
	/**
	 * ====================================================================================================
	 * 方法名称: ${tablecomment}--根据id获取数据<br>
	 * 方法创建日期: ${time}<br>
	 * 方法创建人员: ${author}<br>
	 * 方法维护情况: <br>
	 * 方法: ●原创○沿用○重构汇
	 * ====================================================================================================
	 */
	@Override
	public ${entity} get${entity}InfoById(String ${config.pk}) {
		${entity} ${tablename} = session.get(${entity}.class, ${config.pk});
		return ${tablename};
	}
	
	/**
	 * ====================================================================================================
	 * 方法名称: ${tablecomment}--保存修改<br>
	 * 方法创建日期: ${time}<br>
	 * 方法创建人员: ${author}<br>
	 * 方法维护情况: <br>
	 * 方法: ●原创○沿用○重构汇
	 * ====================================================================================================
	 */
	@Override
	@Transactional
	public void save${entity}Info(JSONObject pageData) {
//		JSONObject ${tablename}form = pageData.getJSONObject("${tablename}EntityData");
		
		String ${config.pk} = pageData.getString("${config.pk}");
//      String orgname = currentUserService.getUserOrg().getOrgname();//b0101
//      String b0111 = currentUserService.getUserOrg().getB0111();//机构id
		String userid = currentUserService.getCurrentUserId();//用户id
//		String username = currentUserService.getCurrentUserName();//用户名

		//${entity} ${tablename} = JSON.parseObject(pageData.toJSONString(), ${entity}.class);
		//${entity} ${tablename} = pageData.toJavaObject(${entity}.class);
		//${entity} ${tablename} = hybean.pageElementToBean(pageData, ${entity}.class);
		${entity}Dto ${tablename}Dto = hybean.pageElementToBean(pageData, ${entity}Dto.class);
  		if(StringUtil.isEmpty(${config.pk})) {
			${entity} ${tablename} = new ${entity}();
			BeanUtil.copyProperties(${tablename}Dto, ${tablename}, false);
			${config.pk} = IDGenertor.uuidgenerate();
			
			${tablename}.set${config.pkU}(${config.pk});
			
			${tablename}.set${config.pkU}99("1");
			
			${tablename}.set${config.pkU}91(userid);
			${tablename}.set${config.pkU}92(new Date());
			${tablename}.set${config.pkU}93(userid);
			${tablename}.set${config.pkU}94(new Date());
  			session.save(${tablename});
  		}else {
  			${entity} ${tablename} = session.get(${entity}.class, ${config.pk});
  			
  			//BeanUtil.copyProperties(${tablename}Dto, ${tablename}, false);
  			//写上需要修改的列
  			
  			${tablename}.set${config.pkU}93(userid);
			${tablename}.set${config.pkU}94(new Date());
			
  			session.update(${tablename});
  		}
	}
	
	/**
	 * ====================================================================================================
	 * 方法名称: ${tablecomment}--根据主键id删除<br>
	 * 方法创建日期: ${time}<br>
	 * 方法创建人员: ${author}<br>
	 * 方法维护情况: <br>
	 * 方法: ●原创○沿用○重构汇
	 * ====================================================================================================
	 */
	@Override
	public void delete${entity}ById(String ${config.pk}) {
		try {
			${entity} ${tablename} = session.get(${entity}.class, ${config.pk});
			session.delete(${tablename});
			
			//批量删除
			if(StringUtil.isNotEmpty(${tablename}00s)) {
	        	String[] ${tablename}00Arr = ${tablename}00s.split(",");
	        	for (int i = 0; i < ${tablename}00Arr.length; i++) {
	        		String ${tablename}00 = ${tablename}00Arr[i];
	        		${entity} ${tablename} = session.get(${entity}.class, ${tablename}00);
	    			session.delete(${tablename});
	    			//删除子表
	    			//session.executeUpdate("delete from ${tablename}x where ${tablename}00=?",new Object[] {${tablename}00});
				}
	        }
		} catch (Exception e) {
			throw new ServiceException("删除失败！");
		}
	}
</#if>	

<#if config.exportExcel>
	/**
	 * ====================================================================================================
	 * 方法名称: ${tablecomment}--导出全部数据到excel<br>
	 * 方法创建日期: ${time}<br>
	 * 方法创建人员: ${author}<br>
	 * 方法维护情况: <br>
	 * 方法: ●原创○沿用○重构汇
	 * ====================================================================================================
	 */
	@Override
	public String export${entity}Excel(JSONObject pageData) throws AppException {
		//导出excel绝对路径
		String path = DownFileDirUtil.getTempFilePath(EHyFile.DOWNLOAD).getAbsolutePath()+"/export.xlsx";
		
		//设置分页信息从第1页开始，导出total全部数据
		JSONObject pageInfo = pageData.getJSONObject("pageInfo");
		pageInfo.put("currentPage",1);
		int total = pageInfo.getIntValue("total");
		pageInfo.put("pageSize",total);
		
		//通过分页方法获取数据
		List<Map<String,Object>> ${tablename}List = dao.get${entity}MapList(pageData);
		try {
			${tablename}Excel.writeSheetData(path, ${tablename}List);
		} catch (Exception e) {
			e.printStackTrace();
			throw new AppException("导出失败：" + e.getMessage());
		}
		
		return path;
	}
	
	


</#if>