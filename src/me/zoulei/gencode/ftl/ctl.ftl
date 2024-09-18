package ${config.outputpackage}.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.insigma.business.components.hyfield.HYBeanUtil;
import com.insigma.business.QGGWY.QGGWY_PUB001.QGGWY_PUB001_0004.enums.SupportECODE;
import com.insigma.business.util.EhCacheUtil;
import com.insigma.business.util.FilePathStoreUtil;
import com.insigma.framework.ResponseMessage;
import com.insigma.framework.exception.AppException;
import com.insigma.framework.util.Base64;
import com.insigma.sys.common.CurrentUserService;

import ${config.outputpackage}.entity.${entity};
import ${config.outputpackage}.dto.${entity}Dto;
import ${config.outputpackage}.dao.${name}Dao;
import ${config.outputpackage}.service.${name}Service;

/**
 * 
 * @author generated by hfree
 * @date ${time}
 */
@RestController
@RequestMapping("/${(config.outputpackage)?replace('.','/')}/${name}")
public class ${name}Controller {
	
	private Log log = LogFactory.getLog(this.getClass());

	@Autowired
	private CurrentUserService currentUserService;
	
	@Autowired
	private ${name}Service service;
	
	@Autowired
	private ${name}Dao dao;

${content}

}
