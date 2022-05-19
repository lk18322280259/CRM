package com.crm.settings.service.impl;

import com.crm.settings.domain.DicValue;
import com.crm.settings.mapper.DicValueMapper;
import com.crm.settings.service.DicValueService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service("dicValueService")
public class DicValueServiceImpl implements DicValueService {

    @Resource
    private DicValueMapper dicValueMapper;

    @Override
    public List<DicValue> queryDicValueByTypeCode(String typeCode) {
        return dicValueMapper.selectDicValueByTypeCode(typeCode);
    }
}
